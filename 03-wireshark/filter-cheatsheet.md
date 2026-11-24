# Wireshark display filter cheat sheet

Display filters go in the bar at the top (they hide packets). Capture filters (BPF) are set before capturing.

| # | Filter | Shows |
|---|---|---|
| 1 | `ip.addr == 192.168.1.2` | All traffic to or from one host |
| 2 | `ip.src == 192.168.1.2 && ip.dst == 8.8.8.8` | One direction between two hosts |
| 3 | `eth.addr == aa:bb:cc:dd:ee:ff` | Traffic by MAC address |
| 4 | `icmp` | Ping and ICMP errors |
| 5 | `arp` | Who-has / is-at requests |
| 6 | `dhcp` | The Discover, Offer, Request, ACK exchange (also `bootp`) |
| 7 | `dns` | All DNS queries and responses |
| 8 | `dns.qry.name contains "linkedin"` | Lookups for one name |
| 9 | `dns.flags.rcode != 0` | Failed DNS lookups (NXDOMAIN and others) |
| 10 | `tcp.port == 80` | HTTP traffic (use `443` for HTTPS) |
| 11 | `tcp.flags.syn == 1 && tcp.flags.ack == 0` | Connection attempts (first packet of the handshake) |
| 12 | `tcp.flags.reset == 1` | Connections refused or torn down abruptly |
| 13 | `tcp.analysis.retransmission` | Retransmitted segments: packet loss or congestion |
| 14 | `tls.handshake.type == 1` | TLS Client Hello (the `tls.handshake.extensions_server_name` field shows the site) |
| 15 | `http.request.method == "GET"` | Plain-HTTP requests |

## Combining
- `and` / `&&`, `or` / `||`, `not` / `!`: for example `ip.addr == 192.168.1.2 && !arp`
- `contains`, `matches` (regex), `in {80 443}`: for example `tcp.port in {80 443}`

## Quick use
- Right-click a packet field, then **Apply as Filter**.
- Right-click a TCP packet, then **Follow, TCP Stream** (`tcp.stream eq N`).
- **Statistics, Conversations** and **Protocol Hierarchy** give the big picture.
- Green bar = valid filter, red = syntax error.
