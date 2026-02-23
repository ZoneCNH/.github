# Python CI/CD 标准配置

> 所有 Python 项目的 CI 质量门禁标准。
> 与 Reusable Workflow 配合使用。

## 必须通过的检查

| 检查项   | 命令                    | 失败策略 |
| -------- | ----------------------- | -------- |
| Lint     | `ruff check .`          | 阻断合并 |
| 格式化   | `ruff format --check .` | 阻断合并 |
| 类型检查 | `mypy src/`             | 阻断合并 |
| 单元测试 | `pytest --cov=src/`     | 阻断合并 |

## 可选检查

| 检查项     | 命令                         | 适用场景              |
| ---------- | ---------------------------- | --------------------- |
| 安全审计   | `pip-audit`                  | 有外部依赖            |
| 依赖检查   | `deptry .`                   | 检测未使用/缺失的依赖 |
| 覆盖率门禁 | `pytest --cov-fail-under=80` | 核心库                |
| 文档构建   | `mkdocs build --strict`      | 有文档的项目          |

## Python 版本

- 默认支持 Python 3.11 + 3.12
- CI matrix 测试两个版本
- `.python-version` 文件锁定项目版本

## Ruff 配置

推荐的 `pyproject.toml` 配置：

```toml
[tool.ruff]
target-version = "py311"
line-length = 88

[tool.ruff.lint]
select = [
    "E",    # pycodestyle errors
    "W",    # pycodestyle warnings
    "F",    # pyflakes
    "I",    # isort
    "N",    # pep8-naming
    "UP",   # pyupgrade
    "B",    # flake8-bugbear
    "SIM",  # flake8-simplify
    "S",    # flake8-bandit (security)
    "RUF",  # ruff-specific
]
ignore = ["E501"]  # 行长度由 formatter 处理

[tool.ruff.lint.per-file-ignores]
"tests/**/*.py" = ["S101"]  # 测试允许 assert
```
