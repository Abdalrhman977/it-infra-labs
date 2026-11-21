# Progress Log

## Week 1 (28 Oct - 16 Nov 2026)
- Built DC01 (Server 2022), promoted to new forest lab.local, dcdiag passed
- Created the Company OU structure, explored ADUC, DNS and Event Viewer
- Snapshots: clean-install, static-ip, domain-created
- Next: Week 2, users/groups, client join, DHCP, shares

## Week 2 (17 - 18 Nov 2026)
- Created users and 3 groups (IT, Sales, HR) in lab.local, joined CLIENT01 to the domain, logged in as a domain user
- Installed and authorized DHCP on DC01, scope 192.168.10.100-200 with DNS option
- Created IT, Sales and HR shares with share + NTFS permissions through groups, tested per user
- Wrote a PowerShell script that creates users from a CSV (skips existing, error handling, password prompted at runtime)
- Issues: ADUC didn't show new user until refresh (F5); Sales share wouldn't open until I fixed the NTFS permissions
- Snapshots: client-joined, shares-done, ps-users, week2-done
- Next: Week 3, GPOs, file server, backup, second DC

## Week 3 (to 21 Nov 2026)
- GPOs: password/lockout, Sales drive map + wallpaper, deny removable storage; Sales drive shows mapped on CLIENT01 (twice, S: and Z:)
- Built FS01 file server, FSRM 500 MB quota on the HR share, quota blocked a 125 MB copy
- wbadmin system-state backup of DC01 completed; AD Recycle Bin restore of two deleted users worked
- Promoted DC02; dcdiag failed DFSREvent (SYSVOL replication), next: fix and check with repadmin
