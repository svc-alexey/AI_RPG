#!/usr/bin/env python3
"""Audit servers for optimization opportunities."""

from __future__ import annotations

import paramiko


VPS_HOST = "153.80.247.32"
VPS_USER = "root"
VPS_PASSWORD = "REDACTED"

HOME_HOST = "192.168.1.68"
HOME_USER = "alexeyko"
HOME_PASSWORD = "REDACTED"


def ssh(host: str, user: str, password: str) -> paramiko.SSHClient:
    c = paramiko.SSHClient()
    c.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    c.connect(host, username=user, password=password, timeout=20)
    return c


def run(client: paramiko.SSHClient, cmd: str, timeout: int = 60) -> tuple[int, str]:
    stdin, stdout, stderr = client.exec_command(cmd, timeout=timeout)
    out = stdout.read().decode("utf-8", "replace")
    err = stderr.read().decode("utf-8", "replace")
    status = stdout.channel.recv_exit_status()
    return status, out + err


def header(text: str) -> None:
    print(f"\n{'-'*60}")
    print(f"  {text}")
    print(f"{'-'*60}")


def audit(name: str, host: str, user: str, pwd: str) -> None:
    print(f"\n{'='*60}")
    print(f"  AUDIT: {name} ({user}@{host})")
    print(f"{'='*60}")

    c = ssh(host, user, pwd)

    commands = {
        "Disk usage": "df -h / /home /var 2>/dev/null",
        "Docker system df": "docker system df 2>/dev/null || echo 'Docker not available'",
        "Docker images": "docker images --format 'table {{.Repository}}\\t{{.Tag}}\\t{{.Size}}\\t{{.CreatedAt}}' 2>/dev/null | head -20",
        "Dangling images": "docker images -f 'dangling=true' --format '{{.ID}} {{.Size}} {{.CreatedAt}}' 2>/dev/null",
        "Stopped containers": "docker ps -a --filter 'status=exited' --format '{{.ID}} {{.Names}} {{.Status}}' 2>/dev/null | head -15",
        "Docker volumes": "docker volume ls -q 2>/dev/null | head -10 ; docker system df -v 2>/dev/null | grep -A3 'Local Volumes'",
        "Temp dirs size": "du -sh /tmp /var/tmp /var/log 2>/dev/null",
        "Journal logs": "journalctl --disk-usage 2>/dev/null || echo 'no journalctl'",
        "Package cache": "du -sh /var/cache/apt /var/cache/pacman 2>/dev/null; echo '---'; apt list --installed 2>/dev/null | wc -l || true",
        "AI-RPG git size": "cd /home/alexeyko/ai-rpg/app 2>/dev/null && git count-objects -vH && du -sh .git || echo 'not found'",
        "Docker compose PS": "cd /home/alexeyko/ai-rpg/app 2>/dev/null && docker compose -f docker-compose.prod.yml ps 2>/dev/null || docker compose ps 2>/dev/null || echo 'not found'",
    }

    for label, cmd in commands.items():
        header(label)
        s, o = run(c, cmd)
        if o.strip():
            print(o.strip())
        else:
            print("(empty)")

    # Large files separately - different on each server
    header("Large files >50MB")
    s, o = run(c, "find /var/lib/docker -type f -size +50M -exec ls -lh {} \\; 2>/dev/null | sort -k5 -h -r | head -15")
    if o.strip():
        print(o.strip())
    else:
        print("(none)")

    s, o = run(c, "find /home -type f -size +20M -exec ls -lh {} \\; 2>/dev/null | sort -k5 -h -r | head -20")
    if o.strip():
        print(o.strip())
    else:
        print("(none)")

    # Container logs
    header("Container log sizes")
    s, o = run(c, "for cid in $(docker ps -q 2>/dev/null); do name=$(docker inspect --format='{{.Name}}' $cid | sed 's|^/||'); log=$(docker inspect --format='{{.LogPath}}' $cid); if [ -f \"$log\" ]; then du -sh \"$log\" | sed \"s|$log|$name|\"; fi; done")
    if o.strip():
        print(o.strip())
    else:
        print("(none)")

    # Large overlay2 directories
    header("Docker overlay2 top layers")
    s, o = run(c, "du -sh /var/lib/docker/overlay2/*/ 2>/dev/null | sort -h -r | head -10")
    if o.strip():
        print(o.strip())
    else:
        print("(none)")

    c.close()


def main():
    audit("HOME SERVER", HOME_HOST, HOME_USER, HOME_PASSWORD)
    audit("VPS", VPS_HOST, VPS_USER, VPS_PASSWORD)


if __name__ == "__main__":
    main()
