# 贡献指南

> 本文件为组织下所有仓库提供统一的贡献指南。

## 开发前准备

### 工具链

```bash
# Rust 项目
rustup update stable
cargo install cargo-deny cargo-audit

# Python 项目
pip install ruff mypy pytest
```

### 克隆并设置

```bash
git clone git@github.com:ZoneCNH/<repo>.git
cd <repo>
```

## 开发流程

1. **创建分支**：`git checkout -b feat/<描述>`
2. **编写代码**：遵循 [全局规则](./rulesets/README.md)
3. **本地验证**：

    ```bash
    # Rust
    cargo fmt --check && cargo clippy -- -D warnings && cargo test

    # Python
    ruff check . && ruff format --check . && pytest
    ```

4. **提交**：`git commit -m "feat(scope): 中文描述"`
5. **推送并创建 PR**：`git push origin feat/<描述>`
6. **等待 CI 通过 + 审查**

## Commit Message 格式

```
<type>(<scope>): <中文标题>

type: feat|fix|refactor|docs|test|chore|perf|ci
scope: crate 名或模块名
```

## PR 规范

- 一个 PR 解决一个问题
- 标题使用中文
- 破坏性变更在描述中标注 `BREAKING`
- CI 必须全部通过

## 语言规范

- 代码注释：**中文**
- 文档：**中文**
- 编码格式：**UTF-8**
