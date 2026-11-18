
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

DHCP address leases <img width="1234" height="1245" alt="Screenshot 2026-11-18 083612" src="https://github.com/user-attachments/assets/1728dae4-6d81-4391-9259-7d7b5fe7ab1d" />
DHCP address pool <img width="1258" height="1192" alt="Screenshot 2026-11-18 083632" src="https://github.com/user-attachments/assets/b95d5a51-e293-474d-a36e-df7a7b21a924" />

Sales share permissions <img width="819" height="871" alt="Screenshot 2026-11-18 083831" src="https://github.com/user-attachments/assets/460d2839-ef22-4b0a-8dbf-9ebecaf55b72" />


Sales NTFS permissions <img width="1036" height="982" alt="Screenshot 2026-11-18 083853" src="https://github.com/user-attachments/assets/f560a2fb-9c84-409e-bc89-6bf2e10e5647" />

Script re-run showing SKIP <img width="1213" height="1272" alt="Screenshot 2026-11-18 083956" src="https://github.com/user-attachments/assets/08bed825-76a9-4524-b664-eac82cb9994d" />

ADUC groups <img width="1273" height="1177" alt="Screenshot 2026-11-18 083342" src="https://github.com/user-attachments/assets/e7e4c7c0-e1ac-45d0-bb2e-ea75d58a2d2b" />

ADUC users <img width="1265" height="1161" alt="Screenshot 2026-11-18 083423" src="https://github.com/user-attachments/assets/08fcf3fe-853f-4ae5-a709-b101658b85ea" />

CLIENT01 joined to lab.local <img width="1192" height="878" alt="Screenshot 2026-11-18 083514" src="https://github.com/user-attachments/assets/0b3666f4-e333-4f90-83dc-8b65a397a815" />

<!-- TODO: add w2-09-dhcp-scope-options.png and w2-10-group-members.png -->
