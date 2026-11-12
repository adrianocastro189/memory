"""Runs the Lua test suite under Lua 5.1 using lupa (pip install lupa).

    python tests/run.py
"""
import os
import sys

try:
    import lupa.lua51 as lupa
except ImportError:
    sys.exit("lupa is required: pip install -r requirements-dev.txt")

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
os.chdir(ROOT)

lua = lupa.LuaRuntime(unpack_returned_tuples=True)
lua.execute("RUN_EMBEDDED = true")
with open(os.path.join("tests", "run.lua"), encoding="utf-8") as handle:
    failed = lua.execute(handle.read())
sys.exit(1 if failed else 0)
