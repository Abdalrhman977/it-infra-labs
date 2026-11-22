# IT Infrastructure Home Labs

Hands-on labs for Windows Server, Active Directory, networking, Linux and Azure, built in
**VMware Workstation** and documented like real change tickets: goal → build → verification → what broke → lessons.

> ⚠️ Home lab environment for learning. Not production. No real credentials are stored in this repo.

## Lab index

| # | Lab | What it covers | Status |
|---|---|---|---|
| 01 | [Active Directory](01-ad-lab/) | Domain controller, DNS, OUs, users/groups, client join, DHCP, file shares, PowerShell automation, GPOs, FSRM quotas, backup, second DC | ✅ Weeks 1-3 (paused) |
| 02 | [Networking](02-network-lab/) | Subnetting, VLANs, routing | 🗓️ Planned |
| 03 | [Wireshark](03-wireshark/) | Capturing and reading DHCP, DNS, ARP, TCP traffic | 🗓️ Planned |
| 04 | [Linux](04-linux/) | Users, permissions, services, SSH | 🗓️ Planned |
| 05 | [Azure notes](05-azure-notes/) | Entra ID, VMs, virtual networks | 🗓️ Planned |
| - | [scripts](scripts/) | PowerShell automation used in the labs | ✅ |

## Highlights so far

- **Built a new AD forest** (`lab.local`) on Windows Server 2022, verified with `dcdiag` and `nslookup`
- **Designed an OU structure** (Company > Users / Computers / Groups / Servers) ready for GPOs
- **15 users and role-based groups** (IT, Sales, HR); joined a Windows 11 client and logged in as a domain user
- **DHCP** installed and authorized, scope `192.168.10.100-200` with DNS option
- **File shares** secured through groups with share + NTFS permissions; tested that each user can only open their own department's share
- **PowerShell script** that bulk-creates users from CSV: idempotent (skips existing users), per-user CREATED / SKIP / FAILED output, password prompted at runtime
- **Troubleshooting documented** for every week (e.g. NTFS vs share permission conflict, dcdiag DNS timeouts after boot)

## Lab topology

```
                 ┌───────────── labnet  192.168.10.0/24 (isolated LAN segment) ─────────────┐
                 │                                                                          │
   ┌─────────────┴──────────────┐                                      ┌────────────────────┴───┐
   │ DC01 · Windows Server 2022 │                                      │ CLIENT01 · Windows 11  │
   │ 192.168.10.10 (static)     │◄──── DHCP lease / DNS / AD logon ────│ 192.168.10.100 (DHCP)  │
   │ AD DS · DNS · DHCP · Files │                                      │ joined to lab.local    │
   └────────────────────────────┘                                      └────────────────────────┘
          │ second NIC: NAT (internet for updates)
```

## Skills demonstrated

`Active Directory` `Windows Server 2022` `DNS` `DHCP` `Group-based access control` `NTFS / share permissions`
`PowerShell` `VMware Workstation` `Snapshots` `dcdiag` `Troubleshooting` `Technical documentation`

## How each lab is documented

Every week's write-up follows the same structure:

1. **Goal**: what this week should achieve
2. **Environment**: VMs, IPs, roles
3. **What I did**: numbered steps (with snapshot names so any step can be rolled back)
4. **Verification**: screenshots proving it works
5. **Problems and fixes**: symptom / cause / fix table
6. **Lessons**: what I'd tell someone doing it next

## Roadmap

- [x] AD week 1: domain controller + OU design
- [x] AD week 2: users, groups, client join, DHCP, shares, PowerShell
- [ ] AD week 3: Group Policy, file server, backup, second DC
- [ ] Networking lab
- [ ] Wireshark captures of the AD lab traffic (DHCP DORA, DNS SRV lookups, Kerberos)
- [ ] Linux lab
- [ ] Azure: extend the lab with Entra ID
