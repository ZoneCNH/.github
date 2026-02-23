# 新仓库接入标准流程

## 前置条件

- [x] Organization Rulesets 已配置（自动生效，无需操作）
- [x] `.github` 仓库已包含全局 `CLAUDE.md` 和社区文件
- [x] 全局规则已配置（`rulesets/rust/` 10 篇 + `rulesets/python/` 2 篇）

---

## Step 0：配置全局规则（仅首次）

首次使用组织规则前，需要将全局规则 symlink 到用户级 Claude Code 目录：

```bash
# 克隆组织配置仓库
git clone git@github.com:ZoneCNH/.github.git ~/org-config

# 创建 symlinks
mkdir -p ~/.claude/rules
ln -sf ~/org-config/rulesets/rust/RULES.md ~/.claude/rules/rust.md
ln -sf ~/org-config/rulesets/python/RULES.md ~/.claude/rules/python.md
ln -sf ~/org-config/rulesets/agent-discipline.md ~/.claude/rules/agent-discipline.md
ln -sf ~/org-config/rulesets/agent-workflow.md ~/.claude/rules/agent-workflow.md
```

> 配置一次后，所有新旧仓库自动生效。更新规则只需 `cd ~/org-config && git pull`。

详见 [全局规则分发机制](./global-rules-distribution.md)。

---

## Step 1：创建仓库

```bash
# 通过 CLI 或 GitHub UI 创建
gh repo create ZoneCNH/<repo-name> --private --clone
cd <repo-name>
```

## Step 2：接入 Reusable Workflow

根据项目语言，创建对应的 CI 配置：

### Rust 项目

```yaml
# .github/workflows/ci.yml
name: CI
on:
  push:
    branches: [main]
  pull_request:
    branches: [main]
jobs:
  ci:
    uses: ZoneCNH/.github/.github/workflows/reusable-rust-ci.yml@main
```

### Python 项目

```yaml
# .github/workflows/ci.yml
name: CI
on:
  push:
    branches: [main]
  pull_request:
    branches: [main]
jobs:
  ci:
    uses: ZoneCNH/.github/.github/workflows/reusable-python-ci.yml@main
```

### Node.js 项目

```yaml
# .github/workflows/ci.yml
name: CI
on:
  push:
    branches: [main]
  pull_request:
    branches: [main]
jobs:
  ci:
    uses: ZoneCNH/.github/.github/workflows/reusable-node-ci.yml@main
```

## Step 3：添加项目级 Agent 配置（可选）

如果项目需要特定的 Agent 规则：

```bash
mkdir -p .claude .agent/rules

# 项目级 Claude Code 配置
cat > .claude/settings.json << 'EOF'
{
  "permissions": {
    "allow": [
      "Bash(cargo test *)",
      "Bash(cargo clippy *)"
    ]
  }
}
EOF

# 项目级规则
cat > .agent/rules/project.md << 'EOF'
# 项目规则

## 技术栈
- 语言：Rust
- 最低版本：1.75

## 约定
- 所有 pub 函数必须有文档注释
- 错误处理使用 thiserror
EOF
```

## Step 4：首次提交

```bash
git add .
git commit -m "init: 初始化项目结构，接入组织级 CI"
git push origin main
```

## Step 5：验证

- [ ] CI Workflow 运行成功
- [ ] 尝试直接 push 到 main → 应被 Rulesets 拒绝
- [ ] 创建 PR → CI 自动触发
- [ ] `CONTRIBUTING.md` 等社区文件从 `.github` 仓库继承

## 验证命令

```bash
# 验证 Rulesets 生效（应被拒绝）
echo "test" >> README.md
git add README.md
git commit -m "test: 验证 Rulesets"
git push origin main  # 期望：被拒绝

# 正确方式：通过 PR
git checkout -b test/verify-rulesets
git push origin test/verify-rulesets
gh pr create --title "test: 验证 Rulesets 生效" --body "验证组织级规则"
```

---

## Checklist 速查

新仓库接入完成度检查：

| #   | 项目                   | 状态 |
| --- | ---------------------- | ---- |
| 1   | CI Workflow 已配置     | ⬜   |
| 2   | CI 在 PR 上自动运行    | ⬜   |
| 3   | Rulesets 阻止直推 main | ⬜   |
| 4   | 社区文件正确继承       | ⬜   |
| 5   | Agent 规则按需配置     | ⬜   |
