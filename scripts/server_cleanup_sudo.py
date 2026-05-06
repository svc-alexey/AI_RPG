#!/usr/bin/env python3
"""Run remaining cleanup tasks that need sudo."""

from __future__ import annotations

import paramiko

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
    return status, out + err


SUDO = f"echo '{HOME_PASSWORD}' | sudo -S "

def do(client, desc: str, cmd: str) -> None:
    print(f"\n>>> {desc}")
    s, o = run(client, cmd)
    print(o.strip()[:800] if o.strip() else "(no output)")
    if s != 0:
        print(f"    WARNING: exit code {s}")


def main():
    c = ssh(HOME_HOST, HOME_USER, HOME_PASSWORD)

    print("=" * 50)
    print("  HOME SERVER — SUDO CLEANUP")
    print("=" * 50)

    # Disk before
    print("\n--- Before ---")
    s, o = run(c, "df -h / && echo '---' && du -sh /var/cache/apt /var/log /tmp 2>/dev/null")
    print(o.strip())

    do(c, "APT cache clean", f"{SUDO}apt clean 2>&1")
    do(c, "Autoremove old packages", f"{SUDO}apt autoremove -y 2>&1")
    do(c, "Journal vacuum to 100MB", f"{SUDO}journalctl --vacuum-size=100M 2>&1")
    do(c, "Clean /tmp systemd-private dirs", f"{SUDO}find /tmp -type d -name 'systemd-private-*' -exec rm -rf {{}} \\; 2>&1 && echo 'done'")
    do(c, "Truncate large container logs", f"{SUDO}find /var/lib/docker/containers -name '*.log' -size +10M -exec truncate -s 0 {{}} \\; 2>&1 && echo 'done'")

    # Disk after
    print("\n--- After ---")
    s, o = run(c, "df -h / && echo '---' && docker system df 2>/dev/null")
    print(o.strip())

    c.close()
    print("\nDone.")


if __name__ == "__main__":
    main()
