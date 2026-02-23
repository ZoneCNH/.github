# 测试策略

> 适用范围：所有 Rust 项目
> 来源：提取自 `TESTING_POLICY`

---

## 1. 测试分层

### 单元测试

- 核心逻辑必须覆盖
- 重试/限流/序列化/配置合并等关键路径必须有测试
- 放在同文件的 `#[cfg(test)] mod tests {}` 中

### 集成测试

- 对外部依赖（DB/MQ/HTTP）必须有可选集成测试
- 使用 mock 或 testcontainers
- 通过 feature/标签控制，不影响普通 `cargo test`

### 故障注入测试

- 关键模块必须具备故障注入测试
- 场景：超时、断连、重试耗尽、限流触发

---

## 2. 测试命名规范

```rust
#[test]
fn test_<模块>_<场景>_<期望结果>() {
    // 例：test_connection_pool_exhausted_returns_timeout_error
}
```

- 测试函数名描述「做什么」+「期望什么」
- 使用中文注释说明测试意图

---

## 3. 断言规范

- 使用精确断言，禁止 `assert!(result.is_ok())`
- 优先使用 `assert_eq!`、`assert_matches!`
- 错误路径测试：验证具体错误类型，而非仅检查 `is_err()`

```rust
// ✅ 正例
assert_eq!(result.unwrap_err().kind(), ErrorKind::Timeout);

// ❌ 反例
assert!(result.is_err());
```

---

## 4. 测试隔离

- 每个测试必须独立，不依赖其他测试的执行顺序
- 不依赖共享可变状态
- 异步测试使用 `#[tokio::test]`

---

## 5. Flaky 测试管理

- Flaky 测试必须标注 `#[ignore]` 并记录原因
- 不得长期默默跳过，必须有修复 owner 与期限
- 使用 `cargo nextest` 检测 flaky（多次运行）

---

## 6. 覆盖率

- 核心模块覆盖率目标 ≥ 80%
- 使用 `cargo llvm-cov` 生成报告
- CI 可设置覆盖率门禁（建议，非强制）
