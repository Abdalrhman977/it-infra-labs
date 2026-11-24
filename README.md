# IT Infrastructure Home Labs

Hands-on labs for Windows Server, Active Directory, networking, Linux and Azure, built in
**VMware Workstation** and documented like real change tickets: goal → build → verification → what broke → lessons.

> ⚠️ Home lab environment for learning. Not production. No real credentials are stored in this repo.

## Lab index

| # | Lab | What it covers | Status |
|---|---|---|---|
| 01 | [Active Directory](01-ad-lab/) | Domain controller, DNS, OUs, users/groups, client join, DHCP, file shares, PowerShell automation, GPOs, FSRM quotas, backup, second DC, DHCP failover | ✅ Weeks 1-3 done |
| 02 | [Networking](02-network-lab/) | Subnetting, VLANs, routing | 🗓️ Planned |
| 03 | [Wireshark](03-wireshark/) | Capturing and reading DHCP, DNS, TCP and TLS traffic, HTTP vs HTTPS, display filter cheat sheet | 🚧 Home-network captures done, AD lab captures next |
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
- **Group Policy**: password/lockout policy, Sales drive map + wallpaper, removable storage blocked
- **File server FS1** with FSRM 500 MB hard quotas; a 125 MB copy over the limit was blocked
- **System-state backup** with `wbadmin` and an **AD Recycle Bin** restore of two deleted users
- **Second DC (DC02)** replicating with 0 failures (`repadmin /replsummary`)
- **Failover test**: with DC01 down, the client logged on via DC02 and got its DHCP lease from DC02 (hot-standby failover)
- **Troubleshooting documented** for every week (e.g. NTFS vs share permission conflict, dcdiag DNS timeouts after boot, wrong client DNS)
- **Wireshark packet analysis** on the home network: DHCP Discover/Offer/Request/ACK, a DNS AAAA lookup and the TCP three-way handshake, plus an HTTP vs HTTPS comparison (HTTP readable in full, HTTPS showing only the server and SNI) and a 15-filter cheat sheet

## Lab topology

```
                 labnet 192.168.10.0/24 (isolated LAN segment)
   ┌───────────────┬───────────────┬───────────────┬───────────────┐
 DC01 .10        DC02 .11        FS1 .12         CLIENT01 .50
 AD DS, DNS      AD DS, DNS, GC  File server     Windows 11
 DHCP active  ◄─ hot standby ─►  FSRM            joined to lab.local
                 DHCP standby
```

DHCP scope 192.168.10.100-200 with hot-standby failover between DC01 and DC02.
DC01 also has a NAT adapter for internet updates. Details: [01-ad-lab](01-ad-lab/README.md#topology).

## Skills demonstrated

`Active Directory` `Windows Server 2022` `DNS` `DHCP failover` `Group Policy` `FSRM`
`NTFS / share permissions` `Backup / Recycle Bin` `repadmin / dcdiag` `PowerShell`
`Wireshark` `TCP/IP` `TLS / HTTPS`
`VMware Workstation` `Troubleshooting` `Technical documentation`

## How each lab is documented

Each write-up covers:

1. **Goal / overview**: what the week should achieve
2. **Environment**: VMs, IPs, roles
3. **What I did**: the build steps
4. **Verification**: screenshots proving it works
5. **Problems and fixes**: symptom / cause / fix table
6. **Lessons**: what I'd tell someone doing it next

## Roadmap

- [x] AD week 1: domain controller + OU design
- [x] AD week 2: users, groups, client join, DHCP, shares, PowerShell
- [x] AD week 3: Group Policy, file server, backup, second DC, DHCP failover
- [ ] Networking lab
- [ ] Wireshark captures of the AD lab traffic (DHCP DORA, DNS SRV lookups, Kerberos)
- [ ] Linux lab
- [ ] Azure: extend the lab with Entra ID
