# 发布策略

> 适用范围：所有 Rust 项目
> 来源：提取自 `RELEASE_POLICY`

---

## 1. 语义化版本（SemVer）

- stable API 严格遵循 SemVer
- 破坏性变更只能在 major 版本
- beta/experimental 可更快迭代，但仍要 changelog

---

## 2. Feature Flag 规范

### 命名

- 可选集成使用 `with-` 前缀：`with-redis` / `with-kafka` / `with-telegram`
- 默认 feature 必须尽量小，避免「全家桶」

### 安全性

- Feature 只改变「实现选择」，不改变「语义」
- 禁止 feature 开启导致行为变化（除性能/依赖外）
- Feature 必须可组合（任意组合不 panic）

---

## 3. 变更记录（Changelog）

- 任何对外行为变化必须写入 CHANGELOG（包括配置项、默认值变化）
- Breaking change 必须显式标注并给迁移说明
- 使用 [Keep a Changelog](https://keepachangelog.com/) 格式

---

## 4. Tag 规范

- 格式：`v{major}.{minor}.{patch}`（如 `v0.3.1`）
- 多 crate workspace：`{crate-name}-v{version}`（如 `common-v1.2.0`）
- Tag 创建后不可变（由 Organization Rulesets 强制）

---

## 5. 文档语言

- README、架构说明、规范、变更说明：**全部中文**
- 代码注释：中文
- 公共 API 的 `///` 文档注释：中文
