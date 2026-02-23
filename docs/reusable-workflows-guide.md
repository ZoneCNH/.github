# Reusable Workflows 使用指南

## 概念区分

| 特性     | Workflow Templates    | Reusable Workflows     |
| -------- | --------------------- | ---------------------- |
| 存放位置 | `workflow-templates/` | `.github/workflows/`   |
| 使用方式 | 手动选择，生成副本    | `uses:` 引用，实时拉取 |
| 后续同步 | ❌ 不同步             | ✅ 每次运行拉取最新版  |
| 适用场景 | 新 repo 快速起步      | 86 repo 持续统一       |

> **一句话**：Templates 是"复制粘贴"，Reusable Workflows 是"引用链接"。

## 可用 Reusable Workflows

### Rust CI

**调用方式**：

```yaml
# .github/workflows/ci.yml
name: CI
on: [push, pull_request]
jobs:
    ci:
        uses: ZoneCNH/.github/.github/workflows/reusable-rust-ci.yml@main
        with:
            rust-version: "stable" # 可选，默认 stable
            features: "--all-features" # 可选，默认 --all-features
```

**包含步骤**：`cargo fmt --check` → `cargo clippy` → `cargo test` → `cargo doc`

### Python CI

```yaml
name: CI
on: [push, pull_request]
jobs:
    ci:
        uses: ZoneCNH/.github/.github/workflows/reusable-python-ci.yml@main
        with:
            python-version: "3.12" # 可选，默认 3.12
```

**包含步骤**：`ruff check` → `ruff format --check` → `mypy` → `pytest --cov`

### Node.js CI

```yaml
name: CI
on: [push, pull_request]
jobs:
    ci:
        uses: ZoneCNH/.github/.github/workflows/reusable-node-ci.yml@main
        with:
            node-version: "20" # 可选，默认 20
```

**包含步骤**：`npm ci` → `npm run lint` → `npm test` → `npm run build`

## 传递 Secrets

如果 Workflow 需要 secrets（如部署 Token），使用 `secrets: inherit`：

```yaml
jobs:
    deploy:
        uses: ZoneCNH/.github/.github/workflows/reusable-deploy.yml@main
        secrets: inherit
```

或显式传递：

```yaml
jobs:
    deploy:
        uses: ZoneCNH/.github/.github/workflows/reusable-deploy.yml@main
        secrets:
            DEPLOY_TOKEN: ${{ secrets.DEPLOY_TOKEN }}
```

## 版本锁定

生产环境建议锁定到 commit SHA 而非 branch：

```yaml
# 开发环境 — 跟踪最新
uses: ZoneCNH/.github/.github/workflows/reusable-rust-ci.yml@main

# 生产环境 — 锁定版本
uses: ZoneCNH/.github/.github/workflows/reusable-rust-ci.yml@abc1234
```

## 调试

如果 Reusable Workflow 未触发，检查：

1. **Visibility**：`.github` 仓库必须是 `internal` 或 `public`（`private` 需要在 Settings → Actions 中显式允许）
2. **Trigger**：调用方必须用 `workflow_call`（不是 `workflow_dispatch`）
3. **Path**：`uses:` 路径格式为 `org/repo/.github/workflows/file.yml@ref`
