# Progress Log

## Week 7 (23 - 24 Nov 2026): Wireshark
- Captured DHCP (Discover/Offer/Request/ACK), DNS (AAAA query/response) and the TCP three-way handshake on the home network; see screenshots/
- Wrote a 15-filter display filter cheat sheet (filter-cheatsheet.md)
- Raw .pcapng files kept out of the repo (size and privacy), ignored in .gitignore
- Added an HTTP vs HTTPS comparison from the captures: HTTP shows the full request and response, HTTPS only the server and site name (README.md)
- Added a TLS Client Hello screenshot (screenshots/tls-client-hello.png): TLS 1.3 offered and the site name readable in the SNI before encryption starts
- Next: capture the AD lab traffic on labnet (CLIENT01 DHCP DORA from DC01/DC02, DNS SRV lookups, Kerberos logon), as on the main README roadmap
