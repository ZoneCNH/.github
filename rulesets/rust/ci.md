# Rust CI/CD 标准配置

> 适用范围：所有 Rust 项目
> 与 Reusable Workflow 配合使用

---

## 必须通过的检查（PR 合并门禁）

| 检查项   | 命令                                                       | 失败策略 |
| -------- | ---------------------------------------------------------- | -------- |
| 格式化   | `cargo fmt --all -- --check`                               | 阻断合并 |
| 静态分析 | `cargo clippy --all-targets --all-features -- -D warnings` | 阻断合并 |
| 单元测试 | `cargo test --all-features`                                | 阻断合并 |
| 文档编译 | `cargo doc --no-deps --all-features`                       | 阻断合并 |
| 安全审计 | `cargo deny check`                                         | 阻断合并 |

## 可选检查（建议开启）

| 检查项   | 命令                    | 适用场景           |
| -------- | ----------------------- | ------------------ |
| 漏洞扫描 | `cargo audit`           | 有外部依赖         |
| 无用依赖 | `cargo udeps`           | nightly job        |
| 重复依赖 | `cargo tree -d`         | 定期排查           |
| 最低版本 | `cargo msrv verify`     | 发布为 crate       |
| 覆盖率   | `cargo llvm-cov --lcov` | 核心库（≥ 80%）    |
| 基准测试 | `cargo bench`           | 性能敏感项目       |
| Miri     | `cargo miri test`       | 使用 unsafe 的项目 |
| 加速测试 | `cargo nextest run`     | 大型测试套件       |

## Rust 工具链

- 默认使用 `stable` 工具链
- CI 额外测试 `nightly`（仅警告，不阻断）
- MSRV：各项目在 `Cargo.toml` 中声明 `rust-version`

## CI 执行顺序

```
fmt → clippy → test → doc → deny
      ↓ (失败即终止，不浪费后续步骤)
```

- 格式化最先（最快反馈）
- deny 最后（耗时最长）

## Flaky 测试

- CI 中 flaky 测试必须标注 `#[ignore]` 并有修复 owner
- 使用 `cargo nextest` 的 `--retries` 检测 flaky
- 不得长期跳过，必须有修复期限

## Release 流程

1. 版本号遵循 SemVer
2. `CHANGELOG.md` 使用 Keep a Changelog 格式
3. Tag 格式：`v{major}.{minor}.{patch}`
4. Tag 由 Organization Rulesets 保护，创建后不可变
