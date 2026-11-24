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

## HTTP vs HTTPS
Same site (`linkedin.com`) requested over port 80 with `curl` (in the `tcp` capture) and over port 443 (`06-tls` capture).

| | HTTP (port 80) | HTTPS (port 443) |
|---|---|---|
| Filter | `http` | `tls` |
| Request visible? | Yes: method (`HEAD`), host, path (`/`) and `User-Agent: curl/8.21.0` are readable | No: only the TLS handshake is readable |
| Response visible? | Yes: `200`, `Content-Type: text/html` | No: shown as `Application Data` (69 encrypted records) |
| What still leaks | Everything | Server IP, port and the site name in the Client Hello SNI (`tls.handshake.extensions_server_name`) |
| Version / cipher | n/a | Server Hello picked TLS 1.3 (`0x0304`), `TLS_AES_256_GCM_SHA384` |

Takeaway: on HTTP anyone on the path can read the whole request and response; on HTTPS they see who you talk to, not what you say.

## Notes
- Raw `.pcapng` files are not committed: one is over 200 MB (GitHub's limit is 100 MB) and
  raw captures contain everything the PC sent during the capture.
- Filter cheat sheet: [filter-cheatsheet.md](filter-cheatsheet.md)
