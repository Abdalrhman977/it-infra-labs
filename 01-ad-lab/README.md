# 01 · Active Directory Lab

A Windows Server 2022 domain (`lab.local`) built from scratch in VMware Workstation over three
weeks: from one domain controller to two DCs, a file server and a client that keeps working
when DC01 is down.

> Home lab, not production.

## Weeks
| Week | Topic | Key outcomes |
|---|---|---|
| [Week 1](week1-README.md) | Domain build | DC01 promoted to a new forest, DNS verified with `dcdiag` / `nslookup`, OU structure |
| [Week 2](week2-README.md) | Users, client, DHCP, shares, PowerShell | 15 users + IT/Sales/HR groups, CLIENT01 joined, DHCP scope, share + NTFS permissions per group, [CSV bulk-user script](../scripts/) |
| [Week 3](week3-README.md) | GPOs, file server, DC02, failover | Password/lockout and GPOs, FS1 with FSRM quotas, system-state backup, Recycle Bin restore, DC02 replicating with 0 failures, DHCP hot-standby failover, client works with DC01 down |

📋 Day-by-day notes: [progress-log.md](progress-log.md)

## Final topology
```
                labnet 192.168.10.0/24 (no gateway)
   ┌──────────────┬──────────────┬──────────────┬──────────────┐
 DC01 .10       DC02 .11       FS1 .12        CLIENT01
 AD, DNS,       AD, DNS, GC,   file server,   DHCP lease from
 DHCP active    DHCP standby   FSRM           .100-200, DNS .10 + .11
```

| Host | OS | IP | Roles |
|---|---|---|---|
| DC01 | Windows Server 2022 | 192.168.10.10 | AD DS, DNS, DHCP (active), Sales share |
| DC02 | Windows Server 2022 | 192.168.10.11 | AD DS, DNS, GC, DHCP (standby) |
| FS1 | Windows Server 2022 | 192.168.10.12 | File server, FSRM (hr, sales shares) |
| CLIENT01 | Windows 11 Enterprise eval | DHCP | Domain client |

Domain `lab.local` (single forest). DC01 also has a NAT adapter for internet access.

## Skills practiced
- **AD DS:** forest build, OUs, users/groups, second DC, replication checks (`dcdiag`, `repadmin`)
- **DNS:** SRV records, reverse zone, client DNS troubleshooting, second DNS server
- **DHCP:** scope, authorization, hot-standby failover
- **Group Policy:** password/lockout, drive mapping, wallpaper, removable-storage block
- **File services:** share vs NTFS permissions, FSRM quotas
- **Recovery:** system-state backup, AD Recycle Bin restore
- **PowerShell:** bulk user creation from CSV

## Future plans
The lab is paused here. Ideas for when I come back:

**Not tested yet**
- [ ] Restore from the system-state backup (only the backup was done, not a restore).
- [ ] Troubleshooting scenarios: Kerberos clock skew, broken computer trust and rejoin,
      GPO with a disabled link, locked-out user.
- [ ] Capture CLIENT01 getting 169.254.x.x when no DHCP server answers.
- [ ] Document share and NTFS permissions on the FS1 `sales` share.

**Next ideas**
- [ ] DFS Namespace so drive maps don't depend on one server name.
- [ ] Separate admin accounts and tiering (no daily use of Domain Admin).
- [ ] LAPS for local admin passwords on the client.

## Folder layout
```
01-ad-lab/
├── README.md           this page
├── week1-README.md     domain build
├── week2-README.md     users, client, DHCP, shares, script
├── week3-README.md     GPOs, FS1, backup, DC02, failover
├── progress-log.md     day-by-day notes
└── images/             Week 3 screenshots (3-01 … 3-26)
```
