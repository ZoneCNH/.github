# Rust 开发规范速查卡

> 适用范围：所有 Rust 项目
> 来源：提取自 `cheatsheet.md`（去除项目特定内容）

---

## 🚫 禁止清单

```
❌ unwrap() 在非测试代码       → 用 ? 或 expect("理由")
❌ panic! 在库代码             → 返回 Result
❌ println!/eprintln!         → 用 tracing 宏
❌ 无超时的网络请求             → 必须设 timeout
❌ unbounded_channel           → 用有界 channel
❌ std::thread::sleep 在 async → 用 tokio::time::sleep
❌ 字符串拼接 SQL               → 用参数化查询
❌ 英文注释/文档               → 中文（铁律）
❌ 跳过 CI 直接合并             → 必须通过 fmt+clippy+test
❌ 无界缓存                     → 必须有上限+淘汰策略
❌ pub use crate::*            → 显式导出
```

---

## ✅ 必须做

```
✅ cargo fmt --check            提交前
✅ cargo clippy -- -D warnings  提交前
✅ cargo test --workspace        提交前
✅ 公共 API 有 /// 文档注释
✅ 公共 enum 用 #[non_exhaustive]
✅ unsafe 块有 // SAFETY 注释
✅ 网络请求设超时 + 重试
✅ 每个 crate 定义自己的 Error
✅ 服务实现优雅关闭
✅ JoinHandle 必须保留并 await
```

---

## 命名速查

| 项目       | 规则              | 示例              |
| ---------- | ----------------- | ----------------- |
| 变量/函数  | `snake_case`      | `max_connections` |
| 类型/Trait | `PascalCase`      | `ConnectionPool`  |
| 常量       | `SCREAMING_SNAKE` | `MAX_RETRY_COUNT` |
| 模块       | `snake_case` 单数 | `handler`         |
| Crate      | `kebab-case`      | `my-crate`        |
| Feature    | `with-` 前缀      | `with-redis`      |

---

## 错误处理

```rust
// 每个 crate 定义自己的错误
#[derive(thiserror::Error, Debug)]
#[non_exhaustive]
pub enum MyError { ... }

pub type Result<T> = std::result::Result<T, MyError>;

// 传播用 ?，禁止 unwrap
let data = fetch().await?;
```

---

## 异步规则

```rust
// 阻塞 → spawn_blocking
let r = tokio::task::spawn_blocking(|| heavy_work()).await?;

// Channel 必须有界
let (tx, rx) = mpsc::channel::<Msg>(1024);

// 保留 JoinHandle
let handle = tokio::spawn(task());
handle.await??;

// 跨 .await 不持有 Mutex
{
    let guard = mutex.lock().await;
} // ← guard 在这里释放
do_async().await; // ← 安全
```

---

## 提交信息

```
<type>(<scope>): <中文标题>

type: feat|fix|refactor|docs|test|chore|perf|ci
scope: crate 名或模块名
```

---

## 工具链

```bash
cargo fmt --all                           # 格式化
cargo clippy --workspace --all-targets    # Lint
cargo test --workspace                    # 测试
cargo doc --workspace --open              # 文档
cargo audit                               # 安全
cargo deny check                          # 许可证/漏洞
```
