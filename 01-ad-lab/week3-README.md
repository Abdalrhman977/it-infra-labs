# Week 3: GPOs, File Server, DC02, Failover (Home Lab)

> Home lab built in VMware Workstation. Not a production environment.

## Goal
Add Group Policy, a file server with quotas, backup and a second DC, then prove the domain
keeps working when DC01 is down.

## What I built
- Password/lockout policy and three GPOs (Sales drive + wallpaper, deny removable storage)
- FS1 file server with FSRM 500 MB hard quotas on the hr and sales shares
- System-state backup with `wbadmin` and an AD Recycle Bin restore
- DC02 as a second DC, GC and DNS server, replicating with 0 failures
- DHCP hot-standby failover DC01 â†’ DC02 and a second DNS server for clients

## IP table
| Host | Role | IPv4 | DNS servers |
|---|---|---|---|
| DC01 | DC, DNS, DHCP active | 192.168.10.10 static | 192.168.10.10 |
| DC02 | DC, DNS, GC, DHCP standby | 192.168.10.11 static | ::1, .11, .10 |
| FS1 | File server, FSRM | 192.168.10.12 static | 192.168.10.10 |
| CLIENT01 | Windows 11 client | 192.168.10.50 static during the DC01-down test, then DHCP 192.168.10.100 | .10, .11 |

DHCP scope: 192.168.10.100-200, no gateway.

## Users, groups, OUs
```
lab.local
â””â”€â”€ Company
    â”œâ”€â”€ Users      15 users + "test user"
    â”œâ”€â”€ Computers
    â”œâ”€â”€ Groups     HR, IT, Sales (global security)
    â””â”€â”€ Servers
```

## GPOs
| GPO | Settings |
|---|---|
| Default Domain Policy, password | History 24, max age 42 days, min age 1 day, **min length 3**, complexity disabled |
| Default Domain Policy, lockout | 5 invalid attempts, 30 min lockout, counter resets after 30 min |
| `sales-drive-wallpaper` | Maps the Sales share, sets wallpaper to `wall.jpg` in SYSVOL |
| Deny removable storage | "All Removable Storage classes: Deny all access" = Enabled |

Min length 3 with complexity off is a lab-only setting, kept simple on purpose.

## Shares and permissions
Share and NTFS permissions both apply; the most restrictive one wins.

| Share | Server / path | Share permission | NTFS | Quota |
|---|---|---|---|---|
| Sales | DC01, `\\DC01\Sales` (Week 2) | Sales: Full Control | Sales: Modify | none |
| hr | FS1, `D:\share\hr` | HR: Change | Administrators, SYSTEM: Full; HR: Modify; inheritance off | 500 MB hard |
| sales | FS1, `D:\share\sales` | not captured | not captured | 500 MB hard |

## FS1: file server and FSRM
- File Server + FSRM on FS1. Custom template "Hard Quota" = 500 MB, hard.
- Applied to `D:\Share\HR` and `D:\Share\Sales`.
- Test: copying 125 MB into the hr share was blocked with "not enough space".

## Backup and Recycle Bin
- `wbadmin` system-state backup to disk E: completed; `wbadmin get versions` lists System State.
- Recycle Bin is on. Deleted two users, restored both from Deleted Objects.

## DC02 and replication
- DC02 is a second DC and GC (both listed in Domain Controllers).
- `repadmin /replsummary`: 0 / 5 failures both ways, on 21 Nov and again on 22 Nov.

## DC01 failover test
With DC01 down:
- CLIENT01 logged on through DC02: `echo %logonserver%` = `\\DC02`,
  `nltest /dsgetdc:lab.local` returned `\\DC02.lab.local`, and the hr share on FS1 still opened.
- `nslookup lab.local 192.168.10.11` answered from DC02.
- DHCP failover: relationship `dc01.lab.local-192.168.10.11`, hot standby, DC01 active,
  5% of addresses reserved for standby, max client lead time 1 h. DC02 has the same scope.
- After `ipconfig /release` + `/renew`, CLIENT01 got 192.168.10.100 from DHCP server
  192.168.10.11 (DC02), with DNS servers .10 and .11 (scope option 006).

## What broke and how I fixed it
| Symptom | Cause | Fix | Evidence |
|---|---|---|---|
| `nslookup lab.local` failed, server 8.8.8.8 | Client DNS pointed to a public DNS | Set client DNS to DC01; `nslookup` answered from DC01 | screenshot 21 |
| Clients would lose DHCP when DC01 is down | DHCP ran only on DC01 | DHCP hot-standby failover to DC02 | screenshots 24-26 |
| Client had only DC01 as DNS | Scope option 006 had one server | Added 192.168.10.11 as second DNS | screenshots 22, 26 |

Earlier fixes: wrong time zone breaking `dcdiag` is in [Week 1](week1-README.md#problems-and-fixes),
wrong NTFS on the Sales share is in [Week 2](week2-README.md#what-broke-and-how-i-fixed-it).

## Lessons
- Single points of failure: DHCP and DNS lived only on DC01. A second DC alone is not enough;
  DHCP failover and a second DNS server in option 006 are what kept the client working.
- GPO paths matter: the wallpaper is in SYSVOL, so it replicates to DC02, but the Sales drive
  map points to `\\DC01\Sales` and depends on DC01 being up.
- `nltest /dsgetdc` and `%logonserver%` quickly show which DC a client is really using.
- Share + NTFS: the most restrictive wins, so keep the share open and control access with NTFS.

## Screenshots
### GPOs
1. Default Domain Policy, password policy
   ![Password policy](images/3-01-gpo-password-policy.png)
2. Default Domain Policy, account lockout policy
   ![Account lockout](images/3-02-gpo-account-lockout.png)
3. "All Removable Storage classes: Deny all access" enabled
   ![Deny removable storage](images/3-03-gpo-deny-removable-storage.png)
4. GPO `sales-drive-wallpaper`, Desktop Wallpaper setting, `wall.jpg` in SYSVOL
   ![GPO sales-drive-wallpaper](images/3-04-gpo-sales-drive-wallpaper.png)
5. CLIENT01 with the Sales share mapped (shows twice, as S: and Z:)
   ![Sales drive mapped](images/3-05-client01-sales-drive-mapped.png)

### File server FS1
6. FS1 `ipconfig /all`: static 192.168.10.12, DNS 192.168.10.10
   ![FS1 ipconfig](images/3-06-fs1-ipconfig.png)
7. FS1 shares (hr, sales) and the hr quota in Server Manager
   ![FS1 shares](images/3-07-fs1-shares-and-quota.png)
8. hr share permissions: HR = Change
   ![Share permissions](images/3-08-fs1-hr-share-permissions.png)
9. hr NTFS permissions: HR = Modify, inheritance off
   ![NTFS permissions](images/3-09-fs1-hr-ntfs-permissions.png)
10. FSRM quota templates with the custom 500 MB "Hard Quota"
    ![Quota template](images/3-10-fsrm-quota-template.png)
11. FSRM quotas on `D:\Share\HR` and `D:\Share\Sales`
    ![Quotas](images/3-11-fsrm-quotas-hr-sales.png)
12. Quota blocks a 125 MB copy to the hr share
    ![Quota blocked copy](images/3-12-fsrm-quota-hr-copy-blocked.png)

### Backup and Recycle Bin
13. System-state backup completed, `wbadmin get versions`
    ![wbadmin backup](images/3-13-wbadmin-system-state-backup.png)
14. "Enable Recycle Bin" greyed out, so it is already on
    ![Recycle Bin enabled](images/3-14-recycle-bin-enabled.png)
15. Deleted users in ADAC > Deleted Objects
    ![Deleted Objects](images/3-15-recycle-bin-deleted-objects.png)
16. Restored users back in Company > Users
    ![Users restored](images/3-16-recycle-bin-users-restored.png)

### DC02
17. DC02 `ipconfig /all`: static 192.168.10.11
    ![DC02 ipconfig](images/3-17-dc02-ipconfig.png)
18. DC01 and DC02 in Domain Controllers, both GC
    ![Domain Controllers](images/3-18-dc02-domain-controllers.png)
19. `repadmin /replsummary` on 21 Nov: 0 failures
    ![replsummary](images/3-19-dc02-repadmin-replsummary.png)
20. `repadmin /replsummary` on 22 Nov: 0 failures
    ![Replication healthy](images/3-20-repadmin-replsummary-healthy.png)

### Failover and troubleshooting
21. Client DNS set to 8.8.8.8 fails, then works against DC01
    ![Wrong DNS then fixed](images/3-21-client01-wrong-dns-then-fixed.png)
22. DC01 down: `nltest /dsgetdc:lab.local` returns DC02, `nslookup` via DC02
    ![nltest DC02](images/3-22-client01-dc01-down-nltest-dc02.png)
23. DC01 down: `%logonserver%` = `\\DC02`, hr share still opens
    ![Logon server DC02](images/3-23-client01-logonserver-dc02-hr-share.png)
24. DHCP failover: hot standby, DC01 active, partner 192.168.10.11
    ![DHCP failover](images/3-24-dhcp-failover-hot-standby.png)
25. Scope 192.168.10.100-200 on DC02
    ![Scope on DC02](images/3-25-dhcp-scope-on-dc02.png)
26. CLIENT01 lease 192.168.10.100 from DHCP server 192.168.10.11
    ![Lease from DC02](images/3-26-client01-dhcp-lease-from-dc02.png)

## Next
The lab is paused here. Ideas for later are in [Future plans](README.md#future-plans).
