# 全局 Claude Code 规则

> 本文件由组织级 `.github` 仓库提供，所有组织下的仓库自动继承。
> 详细规则见 [`rulesets/`](./rulesets/README.md) 目录。

---

## 铁律（P0，不可覆盖）

1. **中文强制**：代码注释、文档、commit message 使用中文
2. **编码格式**：统一使用 UTF-8
3. **CI 门禁**：提交前必须通过 `fmt` + `clippy` + `test`
4. **禁止裸 unwrap()**：使用 `?` 操作符或 `expect("原因")`
5. **unsafe 必须有 SAFETY 注释**
6. **敏感信息禁止硬编码**：Token/Secret 走环境变量

## Agent 执行纪律

所有 Agent 会话（不分语言）必须遵守 [执行纪律规则](./rulesets/agent-discipline.md)：

- **说了就要做** — 声明动作必须同轮执行
- **实时播报** — 每批工具调用前 1-3 句进度
- **验证是隐式的** — 禁止把 test/lint 放进 todo
- **未验证不关闭** — 声称完成前必须跑 test/build

工作流编排见 [agent-workflow.md](./rulesets/agent-workflow.md)：

- **Plan 模式默认** — ≥3 步骤或架构决策必须先规划
- **子代理策略** — 调研/探索/并行分析下放子代理
- **自我改进** — 被纠正后更新 lessons，无情迭代
- **追求优雅** — 非简单改动先问"有没有更优雅的做法"

安全护栏见 [agent-safety.md](./rulesets/agent-safety.md)：

- **证据优先** — 完成声明必须附带验证输出
- **先读后改** — 编辑前必须读取目标文件
- **三击升级** — 3 次同一失败换策略
- **阶段守卫** — 禁止跨阶段行为

上下文管理见 [agent-context.md](./rulesets/agent-context.md)：

- **注意力刷新** — 长任务重读计划
- **文件即状态** — 关键信息持久化到文件
- **双阶段审查** — 需求合规 → 代码质量

模型路由见 [agent-model-routing.md](./rulesets/agent-model-routing.md)：

- **编码 → Codex CLI** — Implement/Refactor/Fix 必须由 Codex 执行，Claude Code 不得直接提交生产代码
- **设计 → Claude Code** — 架构/规划/推理由 Claude Code 主导，Codex 不得私自变更需求或架构
- **Agent Teams 路由** — 编码类 teammate 必须通过 `ask_codex` 委派，Team Lead 只做规划和验证
- **降级兜底** — Codex 失败 → 重试 1 次 → 回退 Claude Code（标注 `[FALLBACK]`）

## Rust 项目

参考以下全局规则（按优先级排序）：

1. [核心编码规范](./rulesets/rust/RULES.md) — 错误处理、命名、依赖、配置
2. [安全基线](./rulesets/rust/security.md) — 禁 unwrap/unsafe/阻塞
3. [异步运行时](./rulesets/rust/async-runtime.md) — tokio/并发/重试/熔断
4. [API 设计](./rulesets/rust/api-design.md) — 稳定性分级、错误类型
5. [测试策略](./rulesets/rust/testing.md) — 分层测试、flaky 管理
6. [可观测性](./rulesets/rust/observability.md) — tracing/指标/追踪
7. [发布策略](./rulesets/rust/release.md) — SemVer/Feature Flag
8. [CI/CD 门禁](./rulesets/rust/ci.md) — 质量检查标准
9. [速查卡](./rulesets/rust/cheatsheet.md) — 一页纸快速参考

## Python 项目

参考以下全局规则：

1. [核心编码规范](./rulesets/python/RULES.md) — 代码风格、命名、安全
2. [CI/CD 门禁](./rulesets/python/ci.md) — Ruff + mypy + pytest

## 分支与 PR 规范

- 默认分支：`main`（Organization Rulesets 强制保护）
- 合并方式：squash merge
- 必须通过 CI 检查才能合并
- Release Tag（`v*`）创建后不可变

## 治理架构

本组织遵循四层治理架构（详见 [architecture.md](./docs/architecture.md)）：

1. **强制层** — Organization Rulesets（代码级，不可绕过）
2. **宪法层** — 本文件 + `rulesets/`（文件级，Agent/人类读取）
3. **法律层** — 项目级 `.claude/` `.agent/`（项目特定覆盖）
4. **执行层** — `.agent/roles/`（角色级指令）
