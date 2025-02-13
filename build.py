from setuptools import Extension
from Cython.Build import cythonize  # type: ignore
from pathlib import Path


def build(setup_kwargs):  # type: ignore
    source_dir = Path("src/kochan")

    sources = [
        str(p) for p in source_dir.rglob("*.py")
        if not p.name.startswith("__init__")
    ]

    extensions = [
        Extension(
            name=str(p.with_suffix("")).replace("/", "."),  # type: ignore
            sources=[str(p)],
            language="c"
        )
        for p in sources
    ]

    setup_kwargs.update({  # type: ignore
        "ext_modules": cythonize(
            extensions,
            compiler_directives={
                "language_level": "3str",
                "embedsignature": True
            },
            nthreads=4
        ),
        "script_args": ["--verbose"]
    })
