# 03 · Wireshark

Packet captures taken on a home network (home lab, not production).

| Capture | Protocol | What it shows | Screenshot |
|---|---|---|---|
| 03-dhcp | DHCP | The Discover / Offer / Request / ACK exchange (plus a Release), matched by transaction ID. The Offer carries the offered IP, subnet mask, router, DNS server and lease time. | [dhcp-offer-packet.png](screenshots/dhcp-offer-packet.png) |
| 04-dns | DNS | A standard query/response for `linkedin.com` (AAAA record, TTL 300 s, answer in about 68 ms). | [dns-aaaa-response.png](screenshots/dns-aaaa-response.png) |
| tcp | TCP | The three-way handshake. The client's SYN (`tcp.flags.syn==1`) to port 80 is selected, showing the sequence number, window size and options (MSS, window scale). | [tcp-syn-handshake.png](screenshots/tcp-syn-handshake.png) |
| 06-tls | TLS | TLS capture (screenshot to be added). | not added yet |

## Filters used
```
dhcp
dns
tcp.flags.syn==1
```

## Notes
- Raw `.pcapng` files are not committed: one is over 200 MB (GitHub's limit is 100 MB) and
  raw captures contain everything the PC sent during the capture.
- Next: add an HTTP vs HTTPS comparison.
- Filter cheat sheet: [filter-cheatsheet.md](filter-cheatsheet.md)
