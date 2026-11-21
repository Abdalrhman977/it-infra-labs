# Week 1: Active Directory Domain Build (Home Lab)

> Home lab built in VMware Workstation. Not a production environment.

## Goal
Build a Windows Server 2022 domain controller and a base OU structure.

## Environment
| Item | Value |
|---|---|
| Hypervisor | VMware Workstation |
| DC01 | Windows Server 2022 (Desktop Experience) |
| CLIENT01 | Windows 11 Enterprise eval (created, not joined yet) |
| Adapters | NAT + LAN Segment "labnet" |
| labnet IP | 192.168.10.10/24, DNS 192.168.10.10, no gateway |
| Domain | lab.local (new forest) |

## What I did
1. Created the VMs, installed the OSes, snapshot `clean-install`
2. Renamed adapters, set a static IP, renamed server to DC01, snapshot `static-ip`
3. Installed the AD DS + DNS roles and promoted DC01 to a new forest lab.local, snapshot `domain-created`
4. Verified with `dcdiag` and `nslookup lab.local`
5. Explored ADUC, DNS Manager and Event Viewer
6. Built the OU tree: Company > Users, Computers, Groups, Servers

## Verification

**dcdiag: all tests passed**

<img width="822" height="533" alt="image" src="https://github.com/user-attachments/assets/8d1ffd77-5285-401f-8363-e44aa10fe4ff" />


**nslookup: lab.local resolves to DC01**

<img width="962" height="332" alt="image" src="https://github.com/user-attachments/assets/57c4ff82-405b-4e6c-826c-0b2aa9b92749" />


**OU structure in ADUC**

 <img width="1267" height="1291" alt="image" src="https://github.com/user-attachments/assets/37ef3272-6f29-4382-a790-70929a24a50e" />


## What I learned
- DNS is the backbone of AD: the SRV records under _msdcs are how clients find the DC
- A DC must point to itself for DNS. On a DC with two NICs, only the LAN NIC should register in DNS
- Set the static IP, hostname, time zone and the NAT "register in DNS" setting **before** promotion
- Don't restrict DNS listen addresses on a multi-homed DC: it broke the forwarders
- Kerberos needs clocks within 5 minutes. Fix the time zone, not the clock
- Read `dcdiag` from the top: a failed Connectivity test skips every test after it, and warnings right after boot can be normal
- Change one thing at a time so the real cause stays clear
- OUs organize users, computers and servers so policies can be applied later

## Problems and fixes

| Symptom | Cause | Fix |
|---|---|---|
| `nslookup lab.local` returned the NAT IP (192.168.189.130) | DC01 registered its NAT adapter in DNS | Unticked "Register this connection's addresses in DNS" on the NAT adapter, deleted the stale A records |
| `nslookup` showed `Server: UnKnown` and timed out | No reverse lookup zone | `Add-DnsServerPrimaryZone -NetworkId "192.168.10.0/24" -ReplicationScope Domain` |
| `google.com` didn't resolve | DNS was set to listen only on the LAN IP, so forwarder traffic couldn't leave via NAT | `dnscmd /ResetListenAddresses`, restarted DNS |
| `dcdiag` DFSREvent / SystemLog failed | Clock about 2.7 days off because the time zone was wrong | `Set-TimeZone -Id "Egypt Standard Time"` (fixed the zone, not `Set-Date`) |
| `dcdiag` Connectivity failed: `<guid>._msdcs.lab.local` couldn't resolve, no `_tcp` / `_udp` / `_sites` in DNS, event 1696 | DC wasn't registering its SRV records: hand-added static A records plus wrong DNS client settings | Deleted the static DC01 A records, set DNS to 192.168.10.10 with registration on, restarted Netlogon, `nltest /dsregdns`. Connectivity and all primary tests then passed |
| DC01 showed only one network adapter (Ethernet0) inside Windows | Second adapter missing or not detected in the VM settings | Checked VM Settings > Network Adapter, added/enabled the second adapter, renamed them NAT and labnet |
| `dcdiag` showed warnings (DNS timeouts for `_ldap._tcp.dc._msdcs.lab.local` and `wpad`) | Test ran right after boot, before the DNS service was fully up | Waited a few minutes and re-ran `dcdiag`, all tests passed |
| OU names had typos (`Comapny`, `Computer`) | Typed too fast when creating the OUs | Right-click > Rename to `Company` and `Computers` |

For the Connectivity fix I changed several things in a row, so the exact cause isn't proven. Most likely it was the static A records plus the DNS registration setting.

### Commands I used
```powershell
nslookup lab.local
Resolve-DnsName _ldap._tcp.dc._msdcs.lab.local -Type SRV
ipconfig /registerdns; net stop netlogon; net start netlogon; nltest /dsregdns
dcdiag /q; dcdiag /test:dns
w32tm /query /status
```

## Next
Week 2: users, groups, client domain join, DHCP, shares, PowerShell.
