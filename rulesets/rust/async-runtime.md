# 异步运行时与并发规则

> 适用范围：所有使用异步的 Rust 项目
> 来源：提取自 `RUNTIME_POLICY`

---

## 1. 运行时统一（P0）

- Workspace 统一异步运行时（`tokio`）
- 禁止多 runtime 混用（除非走例外流程）
- 禁止在库中擅自 `block_on` 或创建私有 runtime（会导致死锁）

---

## 2. 异步代码规范（P0）

### 禁止隐式阻塞

- async 函数内禁止直接调用阻塞 I/O：
    - ❌ `std::thread::sleep` → ✅ `tokio::time::sleep`
    - ❌ `std::fs::read` → ✅ `tokio::fs::read`
    - ❌ `std::net::TcpStream` → ✅ `tokio::net::TcpStream`
- 必要的阻塞调用使用 `spawn_blocking` 包装

### Mutex 跨 await 安全

```rust
// ✅ 正例：guard 在 await 前释放
{
    let guard = mutex.lock().await;
    // 用完立即 drop
} // ← guard 在这里释放
do_async().await; // ← 安全

// ❌ 反例：guard 跨越 await 点
let guard = mutex.lock().await;
do_async().await; // 死锁风险！
```

### JoinHandle 必须保留

- `tokio::spawn` 返回的 `JoinHandle` 必须保留并 await
- 禁止 fire-and-forget（忽略任务结果和 panic）

---

## 3. 背压与资源控制（P0）

### 有界队列

- 禁止无界队列作为默认通道
- 必须有：有界队列 + overflow 策略（drop/timeout/backoff）

```rust
// ✅ 正例：有界 channel
let (tx, rx) = mpsc::channel::<Msg>(1024);

// ❌ 反例：无界 channel
let (tx, rx) = mpsc::unbounded_channel::<Msg>();
```

### 无界缓存禁止

- 禁止无界缓存（必须有上限 + 淘汰策略）
- 禁止日志无限刷屏（必须限速/采样）

---

## 4. 重试与熔断

### 重试策略

- 网络/队列/存储 client 必须具备重试策略
- 使用指数退避 + 抖动（jitter）
- 区分可重试错误与不可重试错误
- 记录重试次数与最终失败原因

```rust
// 推荐参数
RetryPolicy {
    max_retries: 3,
    initial_delay: Duration::from_millis(100),
    max_delay: Duration::from_secs(5),
    backoff_multiplier: 2.0,
}
```

### 熔断与限流

- 熔断/限流触发必须可观测（metrics + log）
- 所有外部调用必须设置 timeout

### 幂等性

- 明确标注哪些操作可重试（幂等 vs 非幂等）

---

## 5. 超时参考值

| 场景     | 连接超时 | 请求超时 |
| -------- | -------- | -------- |
| 数据库   | 5s       | 30s      |
| 缓存     | 2s       | 5s       |
| 消息队列 | 5s       | 10s      |
| HTTP API | 5s       | 15s      |

---

## 6. 关闭顺序

```
启动: Config → Log → DB → Cache → Service → API
关闭: API → Service → Cache → DB → Log → Config（倒序）
```

- 所有长时间运行的服务必须实现优雅关闭
- 关闭时先停止接收新请求，再处理完队内请求
