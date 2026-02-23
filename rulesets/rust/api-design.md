# API 设计规则

> 适用范围：所有 Rust 项目
> 来源：提取自 `API_POLICY`

---

## 1. 稳定性分级

对外 API 必须标注稳定性：

| 级别           | 含义     | 约束                                     |
| -------------- | -------- | ---------------------------------------- |
| `stable`       | 稳定     | 遵循 SemVer，破坏性变更只能在 major      |
| `beta`         | 可能变动 | 仍需 changelog                           |
| `experimental` | 随时变动 | 必须隔离在 `experimental` 模块或 feature |

---

## 2. 最小暴露面

### 默认私有

- 默认 `pub(crate)`，只在需要时公开 `pub`
- 禁止暴露内部实现类型
- 公共 API 优先返回 trait / 抽象句柄 / 结构化 DTO

### 导出面控制

- 对外导出统一在 `lib.rs` / `mod.rs` 管控
- 禁止随手 `pub use crate::*` 扩散导出面

---

## 3. 配置驱动

- 任何可变行为必须可配置（env / file / remote），并提供默认值
- 禁止在代码里硬编码 endpoint、token、路径、端口
- 配置结构体必须有「结构体定义 + schema/校验 + 文档」
- 配置加载优先级：默认值 < 文件 < env < 远端覆盖
- 配置校验失败必须在启动时 fail-fast（禁止带病运行）

---

## 4. 破坏性变更管理

### 变更记录

任何破坏性变更必须：

1. 更新 CHANGELOG
2. 在 PR 描述中标注 `BREAKING`
3. 遵守 SemVer（破坏性 = major 版本）

### 兼容策略

- 配置结构变更使用「新增字段 + 默认值」而非重命名/删除
- trait 变更优先新增 trait / 扩展 trait，而非直接破坏旧 trait
- 公共 enum 使用 `#[non_exhaustive]`

---

## 5. 错误设计

- 每个 crate/模块定义自己的 Error 类型
- 使用 `thiserror` 派生，实现 `Display`、`Debug`、`Error`
- 必须实现 `source()` 保留错误链
- 禁止在公共 API 直接返回 `String` 或 `anyhow::Error`
- `anyhow` 仅允许在 bin/应用层

```rust
#[derive(thiserror::Error, Debug)]
#[non_exhaustive]
pub enum MyError {
    #[error("连接失败: {0}")]
    Connection(#[source] std::io::Error),

    #[error("配置无效: {field}")]
    InvalidConfig { field: String },
}

pub type Result<T> = std::result::Result<T, MyError>;
```

---

## 6. 生命周期与泛型

- 公共 API 的生命周期参数必须有意义的命名
- 泛型约束使用 `where` 子句（超过 2 个约束时）
- 优先使用 `impl Trait` 简化签名
