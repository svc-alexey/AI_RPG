#!/usr/bin/env python3
"""Safe server cleanup after audit."""

from __future__ import annotations

import paramiko


VPS_HOST = "153.80.247.32"
VPS_USER = "root"
VPS_PASSWORD = "REDACTED"

HOME_HOST = "192.168.1.68"
HOME_USER = "alexeyko"
HOME_PASSWORD = "REDACTED"


def ssh(host: str, user: str, pwd: str) -> paramiko.SSHClient:
    c = paramiko.SSHClient()
    c.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    c.connect(host, username=user, password=pwd, timeout=20)
    return c


def run(client: paramiko.SSHClient, cmd: str, timeout: int = 120) -> tuple[int, str]:
    stdin, stdout, stderr = client.exec_command(cmd, timeout=timeout)
    out = stdout.read().decode("utf-8", "replace")
    err = stderr.read().decode("utf-8", "replace")
    status = stdout.channel.recv_exit_status()
    return status, out + "\n" + err


def section(title: str) -> None:
    print(f"\n{'='*60}")
    print(f"  {title}")
    print(f"{'='*60}")


def do(client, desc: str, cmd: str) -> None:
    print(f"\n>>> {desc}")
    print(f"    $ {cmd}")
    s, o = run(client, cmd)
    print(o.strip()[:500] if o.strip() else "(no output)")
    if s != 0:
        print(f"    WARNING: exit code {s}")


def cleanup_home() -> None:
    section("HOME SERVER CLEANUP")
    c = ssh(HOME_HOST, HOME_USER, HOME_PASSWORD)

    do(c, "Docker build cache prune (~17GB)", "docker builder prune -a -f 2>&1")
    do(c, "Docker image prune dangling", "docker image prune -f 2>&1")
    do(c, "Remove unused Docker volume (ai-rpg_postgres_data)", "docker volume rm ai-rpg_postgres_data 2>&1 || echo 'already gone or in use'")
    do(c, "Remove incomplete model download (192MB)", "rm -f /home/alexeyko/ai-rpg/app/backend/symmetry/models/models--intfloat--multilingual-e5-base/blobs/*.incomplete 2>&1 && echo 'removed'")
    do(c, "Remove old worktree backup (127MB)", "rm -f /home/alexeyko/ai-rpg/backups/app_worktree_20260424T181141Z.tar.gz 2>&1 && echo 'removed'")
    do(c, "Git garbage collection", "cd /home/alexeyko/ai-rpg/app && git gc --aggressive 2>&1")
    do(c, "APT cache clean", "sudo apt clean 2>&1 || echo 'no sudo'")
    do(c, "Journal vacuum to 100MB", "sudo journalctl --vacuum-size=100M 2>&1 || echo 'no sudo'")
    do(c, "Clean /tmp old files", "find /tmp -type f -atime +1 -delete 2>&1 && echo 'cleaned old tmp files'")
    do(c, "Clean old Docker logs", "find /var/lib/docker/containers -name '*.log' -size +10M -exec truncate -s 0 {} \\; 2>&1 && echo 'truncated large container logs'")

    section("HOME SERVER AFTER CLEANUP")
    s, o = run(c, "df -h / && echo '---' && docker system df 2>/dev/null")
    print(o.strip())

    c.close()


def cleanup_vps() -> None:
    section("VPS CLEANUP")
    c = ssh(VPS_HOST, VPS_USER, VPS_PASSWORD)

    do(c, "Journal vacuum to 100MB", "journalctl --vacuum-size=100M 2>&1")
    do(c, "APT cache clean", "apt clean 2>&1")
    do(c, "Clean old logs in /var/log", "find /var/log -type f -name '*.log.*' -delete 2>&1; find /var/log -type f -name '*.gz' -delete 2>&1 && echo 'cleaned rotated logs'")
    do(c, "Clean /tmp", "find /tmp -type f -atime +1 -delete 2>&1 && echo 'cleaned old tmp files'")

    section("VPS AFTER CLEANUP")
    s, o = run(c, "df -h / && echo '---' && du -sh /var/log /var/cache/apt 2>/dev/null")
    print(o.strip())

    c.close()


def main():
    cleanup_home()
    cleanup_vps()
    section("DONE")


if __name__ == "__main__":
    main()
