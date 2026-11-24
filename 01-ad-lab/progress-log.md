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

## Week 3 (to 22 Nov 2026)
- GPOs: password/lockout (min length 3, complexity off, 5-attempt lockout), Sales drive map + wallpaper, deny all removable storage; Sales drive shows mapped on CLIENT01 (twice, S: and Z:)
- Built FS1 (192.168.10.12) with hr and sales shares, HR share = Change / NTFS = Modify, FSRM 500 MB hard quotas on both; quota blocked a 125 MB copy
- wbadmin system-state backup completed; Recycle Bin enabled, restored two deleted users
- Promoted DC02 (192.168.10.11, GC); repadmin /replsummary 0 failures
- 22 Nov: took the missing screenshots (policies, FS1 config, quotas, IPs, DC02, Recycle Bin)
- 22 Nov: DC01-down test: CLIENT01 logged on via DC02 (nltest, %logonserver%), hr share still worked
- 22 Nov: set up DHCP hot-standby failover DC01 → DC02 and second DNS .11; client got its lease from DC02. Fixed a client pointing DNS at 8.8.8.8
- Weeks 1-3 done. Ideas for later are in README.md > Future plans

## Week 7 (23 - 24 Nov 2026): Wireshark
- Captured DHCP (Discover/Offer/Request/ACK), DNS (AAAA query/response) and the TCP three-way handshake on the home network; screenshots in 03-wireshark
- Wrote a 15-filter display filter cheat sheet (03-wireshark/filter-cheatsheet.md)
- Raw .pcapng files kept out of the repo (size and privacy), ignored in .gitignore
- Added an HTTP vs HTTPS comparison from the captures: HTTP shows the full request and response, HTTPS only the server and site name (03-wireshark/README.md)
