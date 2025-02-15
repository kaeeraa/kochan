from pathlib import Path
from typing import Any

from Cython.Build import cythonize  # type: ignore
from setuptools import Extension


def build(setup_kwargs: Any):
    """Cython build function

    Args:
        setup_kwargs (Any): kwargs for setup
    """
    source_dir = Path("src/kochan")

    sources = [str(p) for p in source_dir.rglob("*.py") if not p.name.startswith("__init__")]

    extensions = [
        Extension(name=str(p.with_suffix("")).replace("/", "."), sources=[str(p)], language="c")  # type: ignore
        for p in sources
    ]

    setup_kwargs.update(
        {  # type: ignore
            "ext_modules": cythonize(
                extensions, compiler_directives={"language_level": "3str", "embedsignature": True}, nthreads=4
            ),
            "script_args": ["--verbose"],
        }
    )
