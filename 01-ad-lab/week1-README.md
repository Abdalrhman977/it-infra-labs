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
- dcdiag checks the health of a DC, and warnings right after boot can be normal because services aren't ready yet
- OUs organize users, computers and servers so policies can be applied later

## Problems and fixes

| Symptom | Cause | Fix |
|---|---|---|
| DC01 showed only one network adapter (Ethernet0) inside Windows | Second adapter missing or not detected in the VM settings | Checked VM Settings > Network Adapter, added/enabled the second adapter, renamed them NAT and labnet |
| `dcdiag` showed warnings (DNS timeouts for `_ldap._tcp.dc._msdcs.lab.local` and `wpad`) | Test ran right after boot, before the DNS service was fully up | Waited a few minutes and re-ran `dcdiag`, all tests passed |
| OU names had typos (`Comapny`, `Computer`) | Typed too fast when creating the OUs | Right-click > Rename to `Company` and `Computers` |

## Next
Week 2: users, groups, client domain join, DHCP, shares, PowerShell.
