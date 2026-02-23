# 全局规则分发机制

## 问题

GitHub `.github` 仓库的文件继承**仅限特定社区文件**（`CONTRIBUTING.md`、`CODE_OF_CONDUCT.md` 等）。`.github/rulesets/rust/` 下的规则文件**不会自动同步**到组织下所有 repo 的本地克隆。

需要一个机制把规则从 Source of Truth 分发到每个开发环境。

## 三层存储架构

```
┌─────────────────────────────────────────────────────────┐
│  Source of Truth（版本控制）                               │
│  .github/rulesets/rust/RULES.md  （+ 9 篇专项规则）      │
│  .github/rulesets/python/RULES.md                        │
│  → 组织仓库中存储，Git 版本化，PR 审查变更               │
└──────────────────────┬──────────────────────────────────┘
                       │ 分发机制（三选一）
                       ▼
┌─────────────────────────────────────────────────────────┐
│  用户级生效（跨所有项目）                                  │
│  ~/.claude/rules/rust.md  → symlink 到 Source of Truth   │
│  → Claude Code 自动读取，对本机所有项目生效               │
│  → 一人公司最佳选择：一份文件，所有 repo 全部生效         │
└──────────────────────┬──────────────────────────────────┘
                       │ 项目可覆盖
                       ▼
┌─────────────────────────────────────────────────────────┐
│  项目级覆盖（可选）                                        │
│  repo/.claude/rules/project-rust.md                      │
│  → 特定项目的额外规则或覆盖                               │
│  → 例：某项目允许 unsafe、某项目使用 log 而非 tracing     │
└─────────────────────────────────────────────────────────┘
```

## 分发方式对比

| 方式                           | 适合场景    | 同步成本         | 实时性                 |
| ------------------------------ | ----------- | ---------------- | ---------------------- |
| **方式 A：`~/.claude/rules/`** | ⭐ 一人公司 | O(1) 一次配置    | 手动 pull 更新         |
| **方式 B：Git Submodule**      | 团队协作    | 每个 repo 初始化 | `git submodule update` |
| **方式 C：GitHub Action 同步** | 大型组织    | 自动化           | PR 自动推送            |

### 方式 A：用户级规则（推荐）

**最适合一人公司。** Claude Code 支持 `~/.claude/rules/` 目录，其中文件对本机所有项目自动生效。

```bash
# 1. 克隆 .github 仓库（仅首次）
git clone git@github.com:ZoneCNH/.github.git ~/org-config

# 2. 创建 symlink（一次配置，永久生效）
mkdir -p ~/.claude/rules
ln -sf ~/org-config/rulesets/rust/RULES.md ~/.claude/rules/rust.md
ln -sf ~/org-config/rulesets/python/RULES.md ~/.claude/rules/python.md
ln -sf ~/org-config/rulesets/agent-discipline.md ~/.claude/rules/agent-discipline.md
ln -sf ~/org-config/rulesets/agent-workflow.md ~/.claude/rules/agent-workflow.md
ln -sf ~/org-config/rulesets/agent-safety.md ~/.claude/rules/agent-safety.md
ln -sf ~/org-config/rulesets/agent-context.md ~/.claude/rules/agent-context.md

# 3. 更新规则时
cd ~/org-config && git pull
# symlink 自动指向最新版本，无需额外操作
```

**优势**：

- 零配置：一次 symlink，所有 repo 全部生效
- 零维护：`git pull` 即更新
- 无侵入：不修改任何项目仓库

### 方式 B：Git Submodule

```bash
# 在每个 repo 中添加 submodule
git submodule add git@github.com:ZoneCNH/.github.git .shared-rules

# CLAUDE.md 中引用
# 参考 .shared-rules/rulesets/rust/RULES.md 中的 Rust 编码规范
```

### 方式 C：GitHub Action 自动同步

```yaml
# .github/.github/workflows/sync-rules.yml
name: Sync Rules to All Repos
on:
  push:
    paths: ["rulesets/**"]
jobs:
  sync:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Sync to all repos
        run: |
          REPOS=$(gh repo list ZoneCNH --json name -q '.[].name')
          for REPO in $REPOS; do
            gh api repos/ZoneCNH/$REPO/contents/.claude/rules/rust.md \
              --method PUT \
              -f message="sync: 更新全局 Rust 规则" \
              -f content=$(base64 -w 0 rulesets/rust/RULES.md) \
              2>/dev/null || true
          done
        env:
          GH_TOKEN: ${{ secrets.ORG_TOKEN }}
```

## 推荐方案

**一人公司用方式 A（`~/.claude/rules/` + symlink）**，理由：

1. **O(1) 管理成本**：六个 symlink 覆盖所有项目
2. **立即生效**：`git pull` 后所有项目自动使用新规则
3. **零侵入**：不需要修改任何项目仓库的文件
4. **降级安全**：即使 symlink 断了，项目级 `.claude/rules/` 仍然可以工作
5. **与四层架构完美对齐**：用户级 = 宪法层的本地映射

## 初始化脚本

```bash
#!/bin/bash
# setup-global-rules.sh
# 一键配置全局 Rust + Python 规则

ORG_CONFIG_DIR="$HOME/org-config"
CLAUDE_RULES_DIR="$HOME/.claude/rules"

# 1. 克隆/更新组织配置
if [ -d "$ORG_CONFIG_DIR" ]; then
  echo "🔄 更新组织配置..."
  cd "$ORG_CONFIG_DIR" && git pull
else
  echo "📥 克隆组织配置..."
  git clone git@github.com:ZoneCNH/.github.git "$ORG_CONFIG_DIR"
fi

# 2. 创建 symlinks
mkdir -p "$CLAUDE_RULES_DIR"

# Rust 规则
ln -sf "$ORG_CONFIG_DIR/rulesets/rust/RULES.md" "$CLAUDE_RULES_DIR/rust.md"
echo "🔗 已链接 Rust 规则"

# Python 规则
ln -sf "$ORG_CONFIG_DIR/rulesets/python/RULES.md" "$CLAUDE_RULES_DIR/python.md"
echo "🔗 已链接 Python 规则"

# Agent 执行纪律
ln -sf "$ORG_CONFIG_DIR/rulesets/agent-discipline.md" "$CLAUDE_RULES_DIR/agent-discipline.md"
echo "🔗 已链接 Agent 执行纪律"

# Agent 工作流编排
ln -sf "$ORG_CONFIG_DIR/rulesets/agent-workflow.md" "$CLAUDE_RULES_DIR/agent-workflow.md"
echo "🔗 已链接 Agent 工作流编排"

# Agent 安全护栏
ln -sf "$ORG_CONFIG_DIR/rulesets/agent-safety.md" "$CLAUDE_RULES_DIR/agent-safety.md"
echo "🔗 已链接 Agent 安全护栏"

# Agent 上下文管理
ln -sf "$ORG_CONFIG_DIR/rulesets/agent-context.md" "$CLAUDE_RULES_DIR/agent-context.md"
echo "🔗 已链接 Agent 上下文管理"

echo "✅ 全局规则配置完成！"
echo "📂 规则目录：$CLAUDE_RULES_DIR"
ls -la "$CLAUDE_RULES_DIR"
```
