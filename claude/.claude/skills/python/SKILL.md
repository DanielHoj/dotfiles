---
name: python
description: >
  Python development skill covering coding standards, debugging, and testing.
  Use when the user is working on Python files, writing Python code, debugging
  Python errors, or writing tests for Python projects.
---

## Toolchain

All Python projects use the Astral stack. These are non-negotiable defaults:

| Tool | Purpose | Replaces |
|------|---------|----------|
| `uv` | Package management, venvs, running scripts | pip, pip-tools, pipenv, poetry |
| `ruff` | Linting and formatting | black, isort, flake8, pycodestyle |
| `ty` | Type checking | mypy, pyright |

Minimum Python version: **3.13**.

## Coding Standards

Follow these conventions in all Python code:

1. **Style**: PEP 8. Always enforce with `ruff`.
2. **Type hints**: Add type hints to all function signatures. Use modern
   syntax (`str | None` over `Optional[str]`, `list[int]` over `List[int]`).
   Use the `type` statement for type aliases (3.12+).
   Do not use `from __future__ import annotations` — Python 3.13+ has
   deferred evaluation natively via PEP 649.
3. **Imports**: Group as stdlib, third-party, local. Prefer absolute imports.
   Remove unused imports. Let `ruff` sort via the `I` rule set.
4. **Naming**: `snake_case` for functions/variables, `PascalCase` for classes,
   `UPPER_SNAKE` for constants. Prefix private members with `_`.
5. **Docstrings**: Use Google-style docstrings for public functions and classes.
   Skip docstrings for obvious one-liners and private helpers.
6. **Data classes**: Prefer `dataclasses` or `pydantic` models over raw dicts
   for structured data. Use `NamedTuple` for lightweight immutable records.
7. **Error handling**: Catch specific exceptions, never bare `except:`.
   Use custom exception classes for domain errors.
8. **f-strings**: Prefer f-strings over `.format()` or `%` formatting.
9. **Pathlib**: Use `pathlib.Path` over `os.path` for file path manipulation.
10. **Context managers**: Use `with` for file I/O and resource management.

## Enforcement

After writing or modifying Python files, always run these checks:

```bash
ruff check --fix <files>
ruff format <files>
ty check
```

If any check fails, fix the issues before considering the task done.

### Recommended ruff config for new projects

When scaffolding a new project or if no ruff config exists yet, add this
to `pyproject.toml`:

```toml
[tool.ruff]
line-length = 88

[tool.ruff.lint]
select = [
    "E",    # pycodestyle errors
    "F",    # pyflakes
    "W",    # pycodestyle warnings
    "I",    # isort
    "UP",   # pyupgrade — modernize syntax for target Python version
    "B",    # flake8-bugbear
    "C4",   # flake8-comprehensions
    "SIM",  # flake8-simplify
    "PTH",  # flake8-use-pathlib
    "RET",  # flake8-return
    "TC",   # flake8-type-checking — move imports into TYPE_CHECKING blocks
    "ICN",  # flake8-import-conventions
]

[tool.ruff.format]
quote-style = "double"
indent-style = "space"
```

## Running & Debugging

When running or debugging Python code:

1. **Detect the environment** before running:
   - Check for `pyproject.toml` and `uv.lock` to understand project structure
   - Use the project's virtual environment if one exists
2. **Running scripts**: Use `uv run <script>` or `uv run python -m <module>`.
   Prefer the project's task runner if configured (e.g., `make`, `just`).
3. **Dependency management**: Always use `uv`.
   - `uv add <package>` to add dependencies
   - `uv add --dev <package>` for dev dependencies
   - `uv sync` to install from lockfile
   - `uv lock` to update the lockfile
   - Never install packages globally unless asked
4. **Debugging errors**:
   - Read the full traceback bottom-up
   - Identify the exception type and the line that raised it
   - Check for common causes: missing imports, wrong types, None values,
     off-by-one errors, async/await issues
   - Suggest targeted fixes, not rewrites
5. **Virtual environments**: If no venv exists and dependencies are needed,
   create one with `uv venv`. Use `uv run` to execute commands within
   the project environment without manual activation.

## Testing

When writing or running tests:

1. **Framework**: Use `pytest` unless the project already uses `unittest`.
2. **Running tests**:
   - `uv run pytest` for the full suite
   - `uv run pytest path/to/test_file.py::test_name` for a specific test
   - `uv run pytest -x` to stop on first failure
   - `uv run pytest --tb=short` for concise tracebacks
3. **Writing tests**:
   - Name test files `test_*.py`, test functions `test_*`
   - One assert per test when practical; test one behavior per function
   - Use `pytest.fixture` for shared setup; prefer factory fixtures over
     complex setup
   - Use `pytest.mark.parametrize` to cover multiple inputs
   - Use `unittest.mock.patch` or `pytest-mock` for mocking; mock at the
     boundary, not deep internals
4. **Coverage**: Run `uv run pytest --cov=<package>` when asked. Focus coverage
   on business logic, not boilerplate.
5. **Test organization**: Mirror the source tree under `tests/`. If the project
   uses a flat layout, keep tests in `tests/` at the repo root.

## New Project Scaffold

When creating a new Python project, use `uv init`:

```bash
uv init <project-name>
cd <project-name>
uv add --dev ruff pytest
```

Then add the recommended ruff config to `pyproject.toml` (see Enforcement
section above).
