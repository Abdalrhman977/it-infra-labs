# Scripts

> Home lab scripts (`lab.local`). Not for production as-is.

| Script | What it does |
|---|---|
| [New-UsersFromCsv.ps1](New-UsersFromCsv.ps1) | Creates AD users from a CSV, adds each to its group, prints CREATED / SKIP / FAILED per user. Used in [AD lab Week 2](../01-ad-lab/week2-README.md). |

## Usage
Run on a DC (or a machine with RSAT) as a domain admin:

```powershell
Set-ExecutionPolicy -Scope Process Bypass
.\New-UsersFromCsv.ps1 -Path .\newusers.sample.csv -WhatIf   # dry run
.\New-UsersFromCsv.ps1 -Path .\newusers.sample.csv
```

- CSV columns: `FirstName, LastName, Group` (see [newusers.sample.csv](newusers.sample.csv)).
- The initial password is prompted at runtime and never stored. Users must change it at first logon.
- `-WhatIf` still asks for the password (the prompt comes first), but creates nothing.
- Safe to run twice: existing users are skipped. They are not updated, so a group change
  for an existing user needs `Add-ADGroupMember` by hand.
- Undo: `Remove-ADUser First.Last` for any user created by mistake.
