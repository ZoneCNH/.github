# 安全基线规则

> 适用范围：所有 Rust 项目
> 来源：提取自 `R-SEC-001/002/003` + `SECURITY_POLICY`

---

## 1. 禁止 Panic（P0）

### R-SEC-001：禁止 unwrap

- **触发条件**：编写非测试 Rust 代码
- **判定逻辑**：
    - IF 代码中出现 `.unwrap()`、`.expect()`、`panic!()`（测试代码除外）
    - THEN 判定为**违规**
- **处置**：
    - 必须使用 `?` 操作符或 `map_err` 处理错误
    - 禁止 `unwrap_or_else(|| panic!(...))` 变相 panic
- **例外**：
    - `#[cfg(test)]` 模块内可使用
    - 启动时初始化（必须有 `// PANIC:` 注释说明原因）

### R-SEC-002：unsafe 必须有 SAFETY 注释

- **触发条件**：代码包含 `unsafe` 块
- **判定逻辑**：
    - IF `unsafe` 块上方没有 `// SAFETY:` 注释
    - OR 注释未解释为何安全
    - THEN 判定为**违规**
- **处置**：
    - 必须补充 SAFETY 注释说明不变量
    - 优先考虑安全替代方案

### R-SEC-003：异步禁止阻塞调用

- **触发条件**：在 `async fn` 中编写代码
- **判定逻辑**：
    - IF 调用 `std::thread::sleep`、`std::fs::*`、`std::net::*` 等同步 I/O
    - THEN 判定为**违规**
- **处置**：
    - 必须使用 `tokio::time::sleep`、`tokio::fs::*` 等异步替代
    - 必要的阻塞调用使用 `spawn_blocking` 包装

---

## 2. 网络安全（P0）

### TLS 校验

- 默认开启 TLS 校验，禁止默认跳过证书验证
- 禁止默认使用明文凭据、明文连接

### 依赖安全扫描

- CI 必须有漏洞扫描（`cargo audit` 或等价）
- 高危漏洞必须阻塞合并（除非走例外流程）

---

## 3. 敏感信息保护（P0）

### 日志脱敏

- 禁止日志输出 token/secret/password
- 所有敏感字段必须脱敏显示（只显示前后 2-4 位）

### 错误消息脱敏

- 禁止在错误消息中暴露敏感信息
- Token/Secret 不得进入 panic 信息

### 密钥管理

- Secret 存取必须走统一接口（secret provider / env）
- 禁止在代码中硬编码密钥

---

## 4. 示例

```rust
// ✅ 正例：安全的错误处理
pub async fn connect(&self) -> Result<Connection, DbError> {
    let conn = self.pool.get().await?;
    Ok(conn)
}

// ❌ 反例：危险的 unwrap
pub async fn connect(&self) -> Connection {
    self.pool.get().await.unwrap() // panic!
}

// ✅ 正例：带 SAFETY 注释的 unsafe
// SAFETY: buffer 已通过 validate_buffer() 验证长度足够
unsafe { std::ptr::copy_nonoverlapping(src, dst, len) }

// ❌ 反例：无注释的 unsafe
unsafe { std::ptr::copy_nonoverlapping(src, dst, len) }
```

## 5. 自动检查

```bash
# Clippy lint
cargo clippy -- -D clippy::unwrap_used

# 搜索裸 unsafe
grep -rn "unsafe {" --include="*.rs" | grep -v "SAFETY"
```
