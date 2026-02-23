# 可观测性规范

> 适用范围：所有 Rust 项目
> 来源：提取自 `OBSERVABILITY_POLICY`

---

## 1. 结构化日志（P0）

### 统一日志门面

- 统一使用 `tracing` crate 作为日志门面
- 禁止使用 `println!`/`eprintln!`/`dbg!`（测试除外）
- 禁止使用 `log` crate（除非第三方依赖要求）
- 日志格式统一为 JSON（生产）或字段化（开发）

### 日志级别

| 级别     | 用途               | 示例               |
| -------- | ------------------ | ------------------ |
| `error!` | 需要立即处理的错误 | 数据库连接失败     |
| `warn!`  | 潜在问题但可恢复   | 重试成功           |
| `info!`  | 关键业务事件       | 服务启动、请求完成 |
| `debug!` | 开发调试           | 函数参数、中间状态 |
| `trace!` | 热路径详细跟踪     | 循环迭代、缓存命中 |

### 日志模板

```rust
// 错误日志：带 error 源
error!(error = %e, operation = "connect", "数据库连接失败");

// 业务日志：带结构化字段
info!(user_id = %id, action = "login", "用户登录成功");

// Span 注入
#[tracing::instrument(skip(self))]
async fn process_order(&self, order_id: u64) -> Result<()> {
    // 自动追踪函数入口/出口/耗时
}
```

---

## 2. I/O 可追踪（P0）

所有外部 I/O（HTTP/DB/MQ/通知/存储）必须：

- 注入 `tracing` span（至少包含：系统名/操作名/trace_id）
- 错误必须结构化（统一 Error 类型 + context）
- 支持 `trace_id`/`span_id`（分布式追踪）

---

## 3. 指标规范

### 关键指标（P0）

| 指标     | 类型             | 用途         |
| -------- | ---------------- | ------------ |
| 请求量   | counter          | QPS 监控     |
| 延迟     | histogram        | P50/P95/P99  |
| 错误率   | counter + labels | 错误分类统计 |
| 重试次数 | counter          | 重试频率监控 |
| 熔断触发 | counter          | 服务健康度   |

### 指标命名

- 必须遵循统一前缀规范
- 防止标签基数爆炸（避免高基数维度如 user_id）

---

## 4. 错误可观测性

- 统一 Error 类型 + context
- 保留 `source` 错误链（否则排障会断链）
- 错误必须包含足够上下文用于定位问题
