# Week 2: Users, Client, DHCP, Shares, PowerShell
> Home lab (VMware), not production.

## What I built
- 15 users (first.last) in OU Company > Users, created by hand and by script
- 3 groups: IT, Sales, HR, with members
- CLIENT01 joined to lab.local, domain login tested
- DHCP on DC01, authorized, scope for the client
- 3 shared folders (IT Tools, Sales, HR) with share + NTFS permissions via groups
- PowerShell script that creates users from a CSV

## Groups
| Group | Purpose |
|---|---|
| IT | IT staff |
| Sales | Sales team |
| HR | HR team |

## DHCP scope
| Setting | Value |
|---|---|
| Network | 192.168.10.0/24 |
| Range | 192.168.10.100 - 192.168.10.200 |
| DNS option | 192.168.10.10 |
| Gateway | none (isolated lab segment) |
| Static IPs outside scope | DC01 .10 |

CLIENT01 receives 192.168.10.100 from the scope.

## Permission table
| Folder | Group | Share | NTFS |
|---|---|---|---|
| IT Tools | IT | Full Control | Modify |
| Sales | Sales | Full Control | Modify |
| HR | HR | Full Control | Modify |

Rule: share and NTFS permissions combine, and the most restrictive one wins.
Share level is left open on purpose; NTFS does the real access control.
NTFS inheritance is disabled on each folder, leaving only Administrators,
SYSTEM and the matching group.

Test results: each user can open only their own group's share and gets
"access denied" on the others.

## Script
`scripts/New-UsersFromCsv.ps1` reads `newusers.csv`, skips users that already
exist, creates the rest, adds them to their group, and prints
CREATED / SKIP / FAILED per user. The password is prompted at runtime and
never stored in the repo. Re-running it on existing users prints SKIP for each
(see screenshot), so it is safe to run twice.

## What broke and how I fixed it
| Symptom | Cause | Fix |
|---|---|---|
| ADUC didn't show a new user | Console view was stale | Refreshed with F5 |
| Sales share would not open for a Sales user | NTFS permissions on the Sales folder were wrong (share permission alone was not enough) | Corrected NTFS: Sales group with Modify, re-tested with a Sales user |

## Lessons
- Opening a share needs BOTH layers to allow access. Check NTFS first when
  the share permissions look correct but access is still denied.
- After changing group membership, log off and on again before testing,
  because the access token updates at logon.

## Screenshots
![DHCP address leases](screenshots/w2-01-dhcp-leases.png)
![DHCP address pool](screenshots/w2-02-dhcp-pool.png)
![Sales share permissions](screenshots/w2-03-share-permissions-sales.png)
![Sales NTFS permissions](screenshots/w2-04-ntfs-sales.png)
![Script re-run showing SKIP](screenshots/w2-05-script-rerun.png)
![ADUC groups](screenshots/w2-06-aduc-groups.png)
![ADUC users](screenshots/w2-07-aduc-users.png)
![CLIENT01 joined to lab.local](screenshots/w2-08-client-domain-joined.png)
<!-- TODO: add w2-09-dhcp-scope-options.png and w2-10-group-members.png -->
