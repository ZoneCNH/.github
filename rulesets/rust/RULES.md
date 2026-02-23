# Rust 全局规则

> 适用范围：组织下所有 Rust 项目
> 本文件为 Rust 核心编码规范。专项规则见同目录下其他文件。

---

## 错误处理

- 库代码使用 `thiserror` 定义错误枚举，应用代码使用 `anyhow`
- 每个 crate/模块定义自己的 Error 类型，禁止直接返回 `String` 或 `anyhow::Error`
- **禁止裸 `unwrap()`**，必须使用 `expect("原因")` 或 `?` 操作符
- 错误消息必须包含上下文：`anyhow!("处理 {} 失败: {}", name, err)`
- 错误必须保留 `source` 链（否则排障会断链）
- 捕获错误必须处理，禁止吞错（至少日志记录）

> 详细规则见 [api-design.md](./api-design.md) 第 5 节

## 代码风格

- `cargo fmt` 必须通过（CI 强制检查）
- `cargo clippy -- -D warnings` 零警告
- 公共 API（`pub fn`、`pub struct`）必须有文档注释
- 注释使用中文
- 编码格式 UTF-8
- 禁止 `println!`/`eprintln!`/`dbg!`（使用 `tracing` 宏）

## 命名约定

| 元素         | 风格                       | 示例                       |
| ------------ | -------------------------- | -------------------------- |
| 类型         | `PascalCase`               | `OrderService`             |
| 函数/方法    | `snake_case`               | `create_order`             |
| 常量         | `SCREAMING_SNAKE_CASE`     | `MAX_RETRY_COUNT`          |
| 模块         | `snake_case` 单数          | `handler`（非 `handlers`） |
| Feature flag | `with-` 前缀, `kebab-case` | `with-serde`               |
| Crate        | `kebab-case`               | `my-crate`                 |

## 依赖管理

- 新增依赖必须说明理由（引入原因、替代方案、维护状态）
- 优先使用标准库功能，避免不必要的第三方依赖
- `Cargo.toml` 中依赖按字母排序
- 使用 workspace dependencies 统一版本（`[workspace.dependencies]`）
- 禁止循环依赖
- CI 使用 `cargo deny` 检查许可证和漏洞

## 项目结构

```
crate/
├── src/
│   ├── lib.rs        # 库入口，只做模块 re-export
│   ├── main.rs       # 应用入口（如适用）
│   ├── config.rs     # 配置（结构体 + schema + 校验）
│   ├── error.rs      # 错误定义（thiserror）
│   └── <module>/     # 功能模块
├── tests/            # 集成测试
├── benches/          # 基准测试
└── Cargo.toml
```

- 每个模块一个文件，超过 300 行考虑拆分
- 单元测试放在同文件的 `#[cfg(test)] mod tests {}` 中
- 对外导出统一在 `lib.rs` 管控，禁止 `pub use crate::*`

## 配置管理

- 所有配置必须有「结构体定义 + schema/校验 + 文档」
- 配置加载优先级：默认值 < 文件 < env < 远端覆盖
- 配置校验失败必须在启动时 fail-fast（禁止带病运行）
- 超时、端口、endpoint 等必须可配置，禁止硬编码
- 敏感信息（Token/Secret）走环境变量或 secret provider

## 安全约束

- 禁止 `unsafe` 代码，除非有 `// SAFETY:` 注释说明
- 禁止 `#[allow(unused)]` 全局属性
- 数据库查询必须使用参数化查询，禁止字符串拼接 SQL
- 敏感数据禁止硬编码，禁止出现在日志和错误消息中
- 默认开启 TLS 校验

> 详细规则见 [security.md](./security.md)

## 性能指南

- 优先使用 `&str` 而非 `String` 作为函数参数
- 大集合使用 `iter()` 链式调用而非 `for` 循环 + `push`
- 避免不必要的 `clone()`，优先使用借用
- 异步代码使用 `tokio`，同步绝不 `block_on`
- 禁止无界队列/无界缓存

> 详细规则见 [async-runtime.md](./async-runtime.md)

## 日志规范

- 使用 `tracing` crate（不用 `log`/`println!`）
- 错误日志：`error!(error = %e, "描述")`
- 关键路径：`info!`
- 调试信息：`debug!`
- 热路径：`trace!`

> 详细规则见 [observability.md](./observability.md)

---

## 规则导航

| 文件                                   | 职责                              |
| -------------------------------------- | --------------------------------- |
| [RULES.md](./RULES.md)                 | ⬅ 本文件：核心编码规范            |
| [security.md](./security.md)           | 安全基线（禁 unwrap/unsafe/阻塞） |
| [async-runtime.md](./async-runtime.md) | 异步/并发/重试/熔断               |
| [testing.md](./testing.md)             | 测试策略与 flaky 管理             |
| [observability.md](./observability.md) | 日志/指标/追踪                    |
| [api-design.md](./api-design.md)       | API 设计/错误类型/配置            |
| [release.md](./release.md)             | SemVer/Feature Flag/Changelog     |
| [clippy.md](./clippy.md)               | Clippy lint 分级                  |
| [ci.md](./ci.md)                       | CI/CD 质量门禁                    |
| [cheatsheet.md](./cheatsheet.md)       | 一页速查卡                        |
