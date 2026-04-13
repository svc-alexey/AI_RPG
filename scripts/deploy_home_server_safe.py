#!/usr/bin/env python3
"""Safe home-server deploy for AI_RPG."""

from __future__ import annotations

import argparse
import getpass
import json
import os
import posixpath
import tarfile
import tempfile
from pathlib import Path

import paramiko


DEFAULT_HOST = "192.168.1.68"
DEFAULT_USER = "alexeyko"
DEFAULT_APP_ROOT = "/home/alexeyko/ai-rpg/app"


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser()
    parser.add_argument("--host-name", default=DEFAULT_HOST)
    parser.add_argument("--user", default=DEFAULT_USER)
    parser.add_argument("--app-root", default=DEFAULT_APP_ROOT)
    parser.add_argument("--site-url", default="https://beyondtheverge.online")
    parser.add_argument(
        "--password",
        default=os.environ.get("AI_PRG_HOME_SERVER_PASSWORD", ""),
    )
    parser.add_argument(
        "--build-web-dir",
        default=str(Path(__file__).resolve().parents[1] / "build" / "web"),
    )
    return parser.parse_args()


def load_version_metadata(build_web_dir: Path) -> dict[str, str]:
    version_path = build_web_dir / "version.json"
    if not version_path.exists():
        raise FileNotFoundError(
            f"Missing {version_path}. Build web first with tool/build_web_release.ps1."
        )
    return json.loads(version_path.read_text(encoding="utf-8"))


def create_web_archive(build_web_dir: Path) -> Path:
    temp_dir = Path(tempfile.mkdtemp(prefix="ai_rpg_web_deploy_"))
    archive_path = temp_dir / "web_bundle.tar.gz"
    with tarfile.open(archive_path, "w:gz") as tar:
        for path in build_web_dir.rglob("*"):
            arcname = path.relative_to(build_web_dir).as_posix()
            tar.add(path, arcname=arcname, recursive=False)
    return archive_path


def ensure_remote_dir(sftp: paramiko.SFTPClient, remote_dir: str) -> None:
    current = remote_dir
    parts: list[str] = []
    while current not in ("", "/"):
        parts.append(current)
        current = posixpath.dirname(current)
    for part in reversed(parts):
        try:
            sftp.stat(part)
        except FileNotFoundError:
            sftp.mkdir(part)


def run_remote(client: paramiko.SSHClient, command: str, timeout: int = 1800) -> None:
    stdin, stdout, stderr = client.exec_command(command, timeout=timeout)
    output = stdout.read().decode("utf-8", "replace")
    error = stderr.read().decode("utf-8", "replace")
    if output:
        print(output, end="" if output.endswith("\n") else "\n")
    if error:
        print(error, end="" if error.endswith("\n") else "\n")
    status = stdout.channel.recv_exit_status()
    if status != 0:
        raise RuntimeError(f"Remote command failed with exit code {status}")


def main() -> int:
    args = parse_args()
    build_web_dir = Path(args.build_web_dir).resolve()
    if not build_web_dir.exists():
        raise FileNotFoundError(f"Missing build directory: {build_web_dir}")

    metadata = load_version_metadata(build_web_dir)
    archive_path = create_web_archive(build_web_dir)
    remote_upload_dir = posixpath.join(posixpath.dirname(args.app_root), "uploads")
    remote_archive_path = posixpath.join(remote_upload_dir, archive_path.name)

    password = args.password or getpass.getpass(
        f"SSH password for {args.user}@{args.host_name}: "
    )

    print(f"Connecting to {args.user}@{args.host_name} ...")
    client = paramiko.SSHClient()
    client.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    client.connect(
        args.host_name,
        username=args.user,
        password=password,
        timeout=20,
    )

    try:
        sftp = client.open_sftp()
        ensure_remote_dir(sftp, remote_upload_dir)
        print(f"Uploading {archive_path.name} ...")
        sftp.put(str(archive_path), remote_archive_path)
        sftp.close()

        release_id = metadata["release_id"]
        released_at = metadata["released_at"]
        app_version = metadata["app_version"]
        asset_version = metadata["asset_version"]

        remote_script = f"""
set -euo pipefail

APP_ROOT="{args.app_root}"
UPLOAD_TAR="{remote_archive_path}"
WEB_TMP_DIR="$APP_ROOT/deploy/web.new_{release_id}"
ENV_FILE="$APP_ROOT/backend/symmetry/.env"

cd "$APP_ROOT"

if [[ ! -f "$ENV_FILE" ]]; then
  echo "ERROR: missing $ENV_FILE" >&2
  exit 1
fi

mkdir -p .git/info
touch .git/info/exclude
for pattern in "deploy/web/*" "!deploy/web/.gitkeep" "deploy/web.bak_codex_*" ".codex_backup_*"; do
  grep -qxF "$pattern" .git/info/exclude || echo "$pattern" >> .git/info/exclude
done

echo "Fetching latest origin/master without proxy ..."
env HTTPS_PROXY= HTTP_PROXY= ALL_PROXY= NO_PROXY=github.com git fetch origin --prune

echo "Resetting tracked files to origin/master ..."
git reset --hard origin/master

echo "Cleaning untracked files that do not belong to the deploy cache ..."
git clean -fd

echo "Installing fresh web bundle ..."
rm -rf "$WEB_TMP_DIR"
mkdir -p "$WEB_TMP_DIR"
tar -xzf "$UPLOAD_TAR" -C "$WEB_TMP_DIR"
rm -rf deploy/web.bak_codex_current
if [[ -d deploy/web ]]; then
  mv deploy/web deploy/web.bak_codex_current
fi
mv "$WEB_TMP_DIR" deploy/web
touch deploy/web/.gitkeep

python3 - <<'PY'
from pathlib import Path

env_path = Path("{args.app_root}/backend/symmetry/.env")
updates = {{
    "SYMMETRY_RELEASE_ID": "{release_id}",
    "SYMMETRY_RELEASED_AT": "{released_at}",
    "SYMMETRY_WEB_LATEST_VERSION": "{app_version}",
    "SYMMETRY_WEB_MINIMUM_SUPPORTED_VERSION": "{app_version}",
    "SYMMETRY_WEB_ASSET_VERSION": "{asset_version}",
}}

lines = env_path.read_text(encoding="utf-8").splitlines()
seen = set()
result = []
for line in lines:
    replaced = False
    for key, value in updates.items():
        prefix = key + "="
        if line.startswith(prefix):
            result.append(prefix + value)
            seen.add(key)
            replaced = True
            break
    if not replaced:
        result.append(line)

for key, value in updates.items():
    if key not in seen:
        result.append(f"{{key}}={{value}}")

env_path.write_text("\\n".join(result) + "\\n", encoding="utf-8")
PY

echo "Rebuilding production stack ..."
docker compose -f docker-compose.prod.yml up -d --build --force-recreate symmetry-api symmetry-worker web

echo "--- docker compose ps ---"
docker compose -f docker-compose.prod.yml ps

echo "Waiting for /health ..."
for attempt in $(seq 1 40); do
  if curl -fsS http://127.0.0.1:8081/health >/tmp/ai_rpg_health.json 2>/dev/null; then
    cat /tmp/ai_rpg_health.json
    echo
    break
  fi
  if [[ "$attempt" -eq 40 ]]; then
    echo "ERROR: /health did not become ready in time" >&2
    docker compose -f docker-compose.prod.yml logs --tail=80 symmetry-api web >&2 || true
    exit 1
  fi
  sleep 3
done

echo "--- /version ---"
curl -fsS http://127.0.0.1:8081/version
echo

echo "--- deploy/web/version.json ---"
cat deploy/web/version.json
echo

rm -f "$UPLOAD_TAR"
"""

        run_remote(client, remote_script)
        print(f"Deploy complete for {release_id}")
    finally:
        client.close()
        try:
            archive_path.unlink(missing_ok=True)
            archive_path.parent.rmdir()
        except OSError:
            pass

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
