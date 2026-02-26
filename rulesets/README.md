# Organization Rulesets — 跨项目全局规则

> 本目录是**所有语言、所有项目**的全局规则中心。
> 包含 GitHub Rulesets 配置（代码级强制）和语言级编码规范（文件级约定）。

---

## 目录结构

```
rulesets/
├── agent-discipline.md          # Agent 执行纪律（跨语言）
├── agent-workflow.md            # Agent 工作流编排（跨语言）
├── agent-safety.md              # Agent 安全护栏（跨语言）
├── agent-context.md             # Agent 上下文管理（跨语言）
├── agent-model-routing.md       # Agent 模型路由（Claude/Codex 分工，P0 强制）
├── agent-codex.md               # Agent Codex 效率最大化（Prompt 工程/三阶段流水线/并行调度，P0 强制）
├── agent-teams.md               # Agent Teams 效率最大化（波次调度/文件隔离/并行纪律，P0 强制）
├── main-protection.json          # GitHub Ruleset：默认分支保护
├── release-tag-protection.json   # GitHub Ruleset：Release Tag 不可变
│
├── rust/                         # Rust 全局规则（10 篇）
│   ├── RULES.md                  #   核心编码规范（入口）
│   ├── security.md               #   安全基线
│   ├── async-runtime.md          #   异步/并发/重试/熔断
│   ├── testing.md                #   测试策略与 flaky 管理
│   ├── observability.md          #   日志/指标/追踪
│   ├── api-design.md             #   API 设计/错误类型/配置
│   ├── release.md                #   SemVer/Feature Flag/Changelog
│   ├── clippy.md                 #   Clippy lint 分级配置
│   ├── ci.md                     #   CI/CD 质量门禁标准
│   └── cheatsheet.md             #   一页速查卡
│
└── python/                       # Python 全局规则（8 篇）
    ├── RULES.md                  #   核心编码规范（入口）
    ├── security.md               #   安全基线 + 供应链安全
    ├── testing.md                #   测试策略与覆盖率
    ├── observability.md          #   日志/可观测性/链路追踪
    ├── config.md                 #   配置/密钥管理/错误处理
    ├── release.md                #   SemVer/Changelog/发布
    ├── ci.md                     #   CI/CD 质量门禁 + Ruff 配置
    └── cheatsheet.md             #   工具栈一页速查卡
```

## 两类规则

| 类型                | 文件                  | 强制力        | 执行方       |
| ------------------- | --------------------- | ------------- | ------------ |
| **GitHub Rulesets** | `*.json`              | ⚡ 代码级强制 | GitHub 平台  |
| **Agent 纪律**      | `agent-discipline.md` | 🛡️ 执行级约束 | Agent 自觉   |
| **Agent 工作流**    | `agent-workflow.md`   | 🛡️ 流程级约束 | Agent 自觉   |
| **Agent 安全**      | `agent-safety.md`     | 🛡️ 防御级约束 | Agent 自觉   |
| **Agent 上下文**    | `agent-context.md`    | 🛡️ 认知级约束 | Agent 自觉   |
| **Agent 模型路由**  | `agent-model-routing.md` | 🔥 P0 强制  | Agent 自觉   |
| **Agent Codex**     | `agent-codex.md`         | 🔥 P0 强制  | Agent 自觉   |
| **Agent Teams**     | `agent-teams.md`         | 🔥 P0 强制  | Agent 自觉   |
| **语言规则**        | `rust/`、`python/`    | 📄 文件级约定 | Agent / 人类 |

## 规则来源

Rust 全局规则从以下项目级文档提取通用部分：

| 全局规则           | 来源                                                     |
| ------------------ | -------------------------------------------------------- |
| `security.md`      | `rules/security.md` + `SECURITY_POLICY.md`               |
| `async-runtime.md` | `RUNTIME_POLICY.md`                                      |
| `testing.md`       | `TESTING_POLICY.md`                                      |
| `observability.md` | `OBSERVABILITY_POLICY.md`                                |
| `api-design.md`    | `API_POLICY.md` + `ERROR_POLICY.md` + `CONFIG_POLICY.md` |
| `release.md`       | `RELEASE_POLICY.md`                                      |
| `RULES.md`         | 综合提取                                                 |
| `cheatsheet.md`    | `cheatsheet.md`（去除项目特定内容）                      |

## 分发到开发环境

```bash
# 一键配置：symlink 到用户级 Claude Code 规则目录
mkdir -p ~/.claude/rules
ln -sf ~/org-config/rulesets/rust/RULES.md ~/.claude/rules/rust.md
ln -sf ~/org-config/rulesets/python/RULES.md ~/.claude/rules/python.md
ln -sf ~/org-config/rulesets/agent-discipline.md ~/.claude/rules/agent-discipline.md
ln -sf ~/org-config/rulesets/agent-workflow.md ~/.claude/rules/agent-workflow.md
ln -sf ~/org-config/rulesets/agent-safety.md ~/.claude/rules/agent-safety.md
ln -sf ~/org-config/rulesets/agent-context.md ~/.claude/rules/agent-context.md
ln -sf ~/org-config/rulesets/agent-teams.md ~/.claude/rules/agent-teams.md
ln -sf ~/org-config/rulesets/agent-codex.md ~/.claude/rules/agent-codex.md
```

## GitHub Rulesets 配置

通过 GitHub UI 或 REST API 配置，JSON 文件为 IaC 备份：

```bash
# 创建
curl -X POST \
  -H "Authorization: Bearer $GITHUB_TOKEN" \
  https://api.github.com/orgs/{org}/rulesets \
  -d @main-protection.json

# 导出
curl -H "Authorization: Bearer $GITHUB_TOKEN" \
  https://api.github.com/orgs/{org}/rulesets | jq '.' > exported.json
```
