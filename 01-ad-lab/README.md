# 01 · Active Directory Lab

Windows Server 2022 domain `lab.local` built from scratch in VMware Workstation.

> Home lab, not production.

| Week | Topic | Key outcomes |
|---|---|---|
| [Week 1](week1-README.md) | Domain build | DC01 promoted to new forest, DNS verified with `dcdiag` / `nslookup`, OU structure created |
| [Week 2](week2-README.md) | Users, client, DHCP, shares, PowerShell | 15 users + IT/Sales/HR groups, CLIENT01 domain-joined, DHCP scope, share + NTFS permissions tested per group, [CSV bulk-user script](../scripts/) |
| Week 3 | GPOs, file server, backup, second DC | 🛠️ In progress |

📋 Day-by-day notes: [progress-log.md](progress-log.md)

## Environment

| Item | Value |
|---|---|
| Hypervisor | VMware Workstation |
| DC01 | Windows Server 2022 · 192.168.10.10 · AD DS, DNS, DHCP, file shares |
| CLIENT01 | Windows 11 Enterprise eval · DHCP (192.168.10.100) |
| Network | LAN segment `labnet` 192.168.10.0/24 + NAT adapter on DC01 |
| Domain | `lab.local` (new forest) |
