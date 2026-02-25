# Agent 模型路由规则

> 适用范围：所有 Agent 会话（Claude Code / Codex / OpenCode）、所有项目、所有团队
> 级别：🔥 P0（强制，不可覆盖）
> 互补规则：[agent-discipline.md](./agent-discipline.md)（执行纪律）、[agent-workflow.md](./agent-workflow.md)（工作流编排）

---

## 1. 双引擎分工（P0 铁律）

| 任务类别                           | 执行引擎                                  | 禁止事项                                   |
| ---------------------------------- | ----------------------------------------- | ------------------------------------------ |
| 编码（Implement / Refactor / Fix） | **Codex CLI**（GPT-5.3 High）             | Claude Code **不得**直接提交生产代码       |
| 设计 / 推理 / 架构 / 计划         | **Claude Code**（Opus 4.6）主导 + Codex 协作审查 | Codex **不得**私自变更需求或架构           |

### 1.1 Claude Code 强制处理的任务

以下任务**必须**由 Claude Code 执行，**禁止**委派给 Codex：

- 架构设计（`architecture_design`）
- 任务规划（`planning`）
- 决策分析（`decision_analysis`）
- 技术设计文档（`technical_design`）
- 需求文档（`requirements_doc`）
- 跨域分析与评估（`cross_domain_analysis`）
- 战略性规划（`strategy_planning`）

### 1.2 Codex CLI 强制处理的任务

以下任务**必须**由 Codex CLI 执行，Claude Code 仅负责规划和验证：

- 代码生成（`code_generation`）
- 代码审查（`code_review`）
- 重构（`complex_refactor`）
- 自动化脚本（`scripting`）
- Bug 修复（`bug_fix`）
- 单元测试生成（`test_generation`）
- 批量重构（`batch_refactor`）

---

## 2. Agent Teams 模型路由（P0）

使用 Agent Teams（claude-teams MCP）时，模型路由规则如下：

### 2.1 Teammate 编码委派

编码类 teammate 的 prompt **必须**包含 Codex 委派指令：

```
你是编码执行者。所有代码编写、修改、重构任务必须通过 ask_codex 工具执行。
你自身只负责：理解任务 → 调用 ask_codex → 验证结果。
禁止直接编写生产代码。
```

### 2.2 spawn_teammate 路由表

| 任务性质       | backend_type | prompt 注入                                    |
| -------------- | ------------ | ---------------------------------------------- |
| 编码实现       | `claude`     | 注入 Codex 委派指令，编码通过 `ask_codex` 执行 |
| 设计 / 规划    | `claude`     | 标准 Claude Code 推理，禁止直接编码             |
| 代码审查       | `claude`     | 注入 Codex 委派指令，审查通过 `ask_codex` 执行 |
| 文档生成       | `claude`     | Claude Code 直接执行                            |

### 2.3 Team Lead 职责

Team Lead（主 Agent）在 Agent Teams 中的角色：

1. **规划** — 拆解任务、分配 teammate、定义验收标准
2. **路由** — 根据任务性质选择正确的执行引擎
3. **验证** — 汇总结果、运行质量门禁（fmt + clippy + test）
4. **禁止** — 不得直接编写生产代码，必须委派给 Codex

---

## 3. 降级策略（P0）

```
Codex CLI 执行
    ↓ 失败/超时（120s）
自动重试（最多 1 次）
    ↓ 仍然失败
回退到 Claude Code 执行
    ↓ 记录降级事件
```

- 每次降级**必须**记录：任务 ID、失败原因、降级时间、最终执行方
- 降级后 Claude Code 可直接编码（豁免 §1 禁令），但必须标注 `[FALLBACK]`

---

## 4. 决策速查

```
任务进入
    │
    ├─ 需要写/改代码？
    │   ├─ 是 → Codex CLI（ask_codex / codex_parallel.py）
    │   └─ 否 → 下一判断
    │
    ├─ 需要设计/规划/推理？
    │   ├─ 是 → Claude Code（直接执行）
    │   └─ 否 → 下一判断
    │
    └─ 其他 → Claude Code（默认）
```

---

## 5. 项目级扩展

各项目可在 `.agent/rules/global/model-routing.md` 中继承本规则并添加项目特有细化（如 Codex 并发槽位、crate 粒度路由），但**不得**违反 §1 和 §2 的强制约束。
