# Python 全局规则

> 适用范围：组织下所有 Python 项目
> 分发方式：`ln -sf ~/org-config/.github/rulesets/python/ ~/.claude/rules/python/`

---

## 代码风格

- 使用 `ruff` 作为 linter 和 formatter（替代 flake8 + black + isort）
- `ruff check .` 零错误
- `ruff format --check .` 必须通过
- 类型标注：`mypy --strict`（新项目）或 `mypy`（迁移项目）
- 注释使用中文
- 编码格式 UTF-8

## 命名约定

| 元素      | 风格                   | 示例              |
| --------- | ---------------------- | ----------------- |
| 类        | `PascalCase`           | `OrderService`    |
| 函数/方法 | `snake_case`           | `create_order`    |
| 常量      | `SCREAMING_SNAKE_CASE` | `MAX_RETRY_COUNT` |
| 模块/包   | `snake_case`           | `order_handler`   |
| 私有属性  | `_prefix`              | `_internal_state` |

## 项目结构

```
project/
├── src/
│   └── package_name/
│       ├── __init__.py
│       ├── config.py
│       ├── models.py
│       └── <module>/
├── tests/
│   ├── conftest.py
│   ├── test_*.py
│   └── ...
├── pyproject.toml       # 唯一配置文件（不用 setup.py）
├── README.md
└── .python-version      # 锁定 Python 版本
```

## 依赖管理

- `pyproject.toml` 作为唯一配置入口（PEP 621）
- 不使用 `setup.py`、`setup.cfg`、`requirements.txt`（遗留项目除外）
- 开发依赖放在 `[project.optional-dependencies] dev = [...]`
- 锁定版本：使用 `uv.lock` 或 `poetry.lock`

## 错误处理

- 自定义异常继承 `Exception`，不继承 `BaseException`
- 禁止裸 `except:`，必须指定异常类型
- 异常消息包含上下文：`raise ValueError(f"用户 {user_id} 不存在")`
- 使用 `logging` 记录异常：`logger.exception("处理失败")`

## 安全约束

- 禁止 `eval()`、`exec()`
- SQL 查询必须使用参数化查询，禁止 f-string 拼接
- 敏感数据使用环境变量，禁止硬编码
- 文件操作使用 `pathlib.Path`，禁止 `os.path` 字符串拼接

## 日志规范

- 使用标准 `logging` 模块或 `structlog`
- 日志级别：`ERROR` → `WARNING` → `INFO` → `DEBUG`
- 格式：`%(asctime)s [%(levelname)s] %(name)s: %(message)s`

## 测试

- 使用 `pytest` 作为测试框架
- 测试文件命名：`test_<module>.py`
- fixtures 放在 `conftest.py`
- 覆盖率目标：核心模块 ≥ 80%
