# 四层治理架构

## 架构总览

```
⚡ 强制层 ─ Organization Rulesets（GitHub 平台执行，无人可绕过）
📜 宪法层 ─ .github 仓库（全局规则、CI/CD 模板、Agent 规范）
📋 法律层 ─ 各 repo .claude/ .agent/（项目特定规则）
🔧 执行层 ─ 各 repo .agent/roles/（角色级 Sub-Agent 指令）
```

## 各层职责

### 强制层：Organization Rulesets

**配置位置**：GitHub Organization Settings → Rules → Rulesets

**特点**：代码级强制执行，即使 Repo Admin 也无法绕过。

| Ruleset                  | 目标     | 核心规则                            |
| ------------------------ | -------- | ----------------------------------- |
| `main-protection`        | 默认分支 | 强制 PR、CI 必须通过、禁止强推/删除 |
| `release-tag-protection` | `v*` Tag | 创建后不可变，仅 Org Admin 可绕过   |

**配置文件**：[`../rulesets/`](../rulesets/)

---

### 宪法层：.github 仓库

**配置位置**：组织下名为 `.github` 的仓库

**自动继承范围**：组织下所有仓库（无需额外配置）

| 文件/目录            | 作用                        | 继承方式                         |
| -------------------- | --------------------------- | -------------------------------- |
| `CLAUDE.md`          | AI Agent 全局规则入口       | Agent 自动读取                   |
| `rulesets/rust/`     | Rust 全局编码规范（10 篇）  | Agent 通过 CLAUDE.md 引用        |
| `rulesets/python/`   | Python 全局编码规范（2 篇） | Agent 通过 CLAUDE.md 引用        |
| `rulesets/*.json`    | GitHub Rulesets IaC 备份    | API/UI 配置，JSON 版本化         |
| `.github/workflows/` | Reusable Workflows          | 子 repo `uses:` 引用（实时同步） |
| `CONTRIBUTING.md`    | 贡献指南                    | 自动作为默认社区文件             |
| `SECURITY.md`        | 安全报告流程                | 自动作为默认社区文件             |
| `ISSUE_TEMPLATE/`    | Issue 模板                  | 自动作为默认模板                 |
| `docs/`              | 架构/接入/分发文档（6 篇）  | 人工查阅                         |

> **注意**：社区文件的继承规则是"缺省继承" — 如果子 repo 有同名文件，使用子 repo 的；没有则使用 `.github` 仓库的。

---

### 法律层：项目级配置

**配置位置**：各 repo 根目录

| 文件/目录           | 作用                                        |
| ------------------- | ------------------------------------------- |
| `.claude/`          | 项目特定的 Claude Code 配置（可覆盖宪法层） |
| `.agent/rules/`     | 项目编码规则                                |
| `.agent/workflows/` | 项目工作流定义                              |
| `.agent/skills/`    | 项目可用技能集                              |

---

### 执行层：角色级配置

**配置位置**：各 repo `.agent/roles/`

| 文件       | 作用                               |
| ---------- | ---------------------------------- |
| `*.md`     | Sub-Agent 角色指令                 |
| 各角色配置 | 上下文隔离、工具绑定、专业领域限定 |

## 继承与覆盖规则

```
Rulesets（不可覆盖）
  └→ .github 仓库全局规则（缺省继承，可覆盖）
       └→ 项目级 .claude/（项目内生效）
            └→ 角色级 .agent/roles/（角色内生效）
```

1. **Rulesets 规则不可覆盖** — 这是硬性约束
2. **社区文件缺省继承** — 子 repo 有同名文件则使用子 repo 的
3. **CLAUDE.md 叠加生效** — 组织级 + 项目级同时生效（项目级补充而非替代）
4. **角色指令最窄范围** — 仅在对应 Sub-Agent 会话中生效
