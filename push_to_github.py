#!/usr/bin/env python3
"""Stage, commit, and push this folder to the biostats GitHub repository."""

import os
import shlex
import subprocess
import sys
from pathlib import Path


ROOT = Path(__file__).resolve().parent
REMOTE_URL = "git@github.com:manishdatt-edu/biostats.git"
PRIVATE_KEY = ROOT / "deploy_key"


def run_git(arguments, *, env=None, capture_output=False):
    try:
        return subprocess.run(
            ["git", *arguments],
            cwd=ROOT,
            env=env,
            check=False,
            text=True,
            capture_output=capture_output,
        )
    except FileNotFoundError:
        print("Git was not found on PATH.", file=sys.stderr)
        return None


def main():
    if not PRIVATE_KEY.is_file():
        print(f"SSH private key not found: {PRIVATE_KEY}", file=sys.stderr)
        return 1

    environment = os.environ.copy()
    key_path = PRIVATE_KEY.as_posix()
    environment["GIT_SSH_COMMAND"] = (
        f"ssh -i {shlex.quote(key_path)} -o IdentitiesOnly=yes"
    )

    if not (ROOT / ".git").exists():
        result = run_git(["init"])
        if result is None or result.returncode != 0:
            return 1

    remote = run_git(["remote", "get-url", "origin"], capture_output=True)
    if remote is None:
        return 1
    remote_command = (
        ["remote", "set-url", "origin", REMOTE_URL]
        if remote.returncode == 0
        else ["remote", "add", "origin", REMOTE_URL]
    )
    result = run_git(remote_command)
    if result is None or result.returncode != 0:
        return 1

    result = run_git(["add", "-A"])
    if result is None or result.returncode != 0:
        return 1

    staged = run_git(["diff", "--cached", "--quiet"])
    if staged is None or staged.returncode not in (0, 1):
        return 1
    if staged.returncode == 1:
        result = run_git(["commit", "-m", "Update biostats files"])
        if result is None or result.returncode != 0:
            return 1
    else:
        print("No changes to commit.")

    result = run_git(["branch", "-M", "main"])
    if result is None or result.returncode != 0:
        return 1

    result = run_git(["push", "-u", "origin", "main"], env=environment)
    if result is None or result.returncode != 0:
        print(
            "Push failed. Check the output and verify the deploy key has write access.",
            file=sys.stderr,
        )
        return 1

    print("Push completed successfully.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())