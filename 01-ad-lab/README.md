# Active Directory Lab

Goal: build a Windows domain (lab.local) in VMware to practise Active Directory, DNS, DHCP, Group Policy, file shares and backup.

## Environment
- Hypervisor: VMware Workstation
- DC01: Windows Server 2022 Standard Evaluation (Desktop Experience), 2 vCPU, 4 GB RAM, 40 GB disk
- CLIENT01: Windows 11 Enterprise Evaluation (virtual TPM)
- Network: LAN Segment "labnet" (lab network) plus NAT on DC01 (activation and updates)

## Progress log

### Day 1
- Created the GitHub repo and installed VMware.
- Checked virtualization support and free disk space.

### Day 2
- Built the DC01 and CLIENT01 virtual machines and took clean snapshots.
- Issue: installed Windows Server Core by mistake (command line only).
  Fix: reinstalled and chose "Standard Evaluation (Desktop Experience)".
