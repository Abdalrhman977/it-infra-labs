# Week 2: Users, Client, DHCP, Shares, PowerShell (Home Lab)

> Home lab built in VMware Workstation. Not a production environment.

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

All three are **Global Security** groups. Security groups can be given permissions
(NTFS, shares, GPO filtering); distribution groups are email-only.

## DHCP scope
| Setting | Value |
|---|---|
| Network | 192.168.10.0/24 |
| Range | 192.168.10.100 - 192.168.10.200 |
| DNS option | 192.168.10.10 |
| Gateway | none (isolated lab segment) |
| Static IPs outside scope | DC01 .10 |
| Bound to | labnet adapter only (not NAT) |

CLIENT01 receives 192.168.10.100 from the scope.

DC01 is **authorized** in AD, so this Windows DHCP server is allowed to serve the domain.
Authorization only stops rogue *Windows* DHCP servers; a router or Linux box could still
hand out addresses (DHCP snooping on switches covers that).

## Domain join
- Before joining, tested from CLIENT01: `ping 192.168.10.10` and `nslookup lab.local`
- Joined `lab.local` and logged in as a domain user (`LAB\user` or `user@lab.local`)
- Verified with `whoami` and `echo %userdomain%`, and saw CLIENT01 in ADUC
- Moved CLIENT01 from the default Computers container into `Company > Computers`,
  because GPOs can't be linked to the default container

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
`try/catch` lets it continue after one failure and report which user failed.

## What broke and how I fixed it
| Symptom | Cause | Fix |
|---|---|---|
| ADUC didn't show a new user | Console view was stale | Refreshed with F5 |
| Sales share would not open for a Sales user | NTFS permissions on the Sales folder were wrong (share permission alone was not enough) | Corrected NTFS: Sales group with Modify, re-tested with a Sales user |
| Script wouldn't run (execution policy prompt) | Default policy blocks unsigned scripts | `Set-ExecutionPolicy -Scope Process Bypass` (this session only, not machine-wide) |
| A user stayed in Sales although the CSV said HR | The user already existed from Day 1, so the script skipped the account and never changed its group | Fix is `Add-ADGroupMember` by hand. Lesson: "skip if exists" doesn't update existing users |

## Lessons
- Opening a share needs BOTH layers to allow access. Check NTFS first when
  the share permissions look correct but access is still denied.
- After changing group membership, log off and on again before testing,
  because the access token updates at logon.
- The client's DNS must point to the DC before joining: it finds the domain through SRV records.
- Joining creates a computer account in AD and a secure channel between the PC and the domain.
- DHCP is DORA: Discover and Request are broadcasts, Offer and Acknowledge come from the server.
- Reset password, unlock and disable are three different things: unlock only clears a lockout.
- Prompting with `Read-Host -AsSecureString` keeps passwords out of scripts and GitHub.

## Screenshots

**ADUC users**

<img width="1265" height="1161" alt="ADUC users" src="https://github.com/user-attachments/assets/08fcf3fe-853f-4ae5-a709-b101658b85ea" />

**ADUC groups**

<img width="1273" height="1177" alt="ADUC groups" src="https://github.com/user-attachments/assets/e7e4c7c0-e1ac-45d0-bb2e-ea75d58a2d2b" />

**CLIENT01 joined to lab.local**

<img width="1192" height="878" alt="CLIENT01 joined to lab.local" src="https://github.com/user-attachments/assets/0b3666f4-e333-4f90-83dc-8b65a397a815" />

**DHCP address pool**

<img width="1258" height="1192" alt="DHCP address pool" src="https://github.com/user-attachments/assets/b95d5a51-e293-474d-a36e-df7a7b21a924" />

**DHCP address leases**

<img width="1234" height="1245" alt="DHCP address leases" src="https://github.com/user-attachments/assets/1728dae4-6d81-4391-9259-7d7b5fe7ab1d" />

**Sales share permissions**

<img width="819" height="871" alt="Sales share permissions" src="https://github.com/user-attachments/assets/460d2839-ef22-4b0a-8dbf-9ebecaf55b72" />

**Sales NTFS permissions**

<img width="1036" height="982" alt="Sales NTFS permissions" src="https://github.com/user-attachments/assets/f560a2fb-9c84-409e-bc89-6bf2e10e5647" />

**Script re-run showing SKIP**

<img width="1213" height="1272" alt="Script re-run showing SKIP" src="https://github.com/user-attachments/assets/08bed825-76a9-4524-b664-eac82cb9994d" />

## Next
Week 3: GPOs, file server, backup, second DC. See [week3-README.md](week3-README.md).
