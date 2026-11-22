<#
.SYNOPSIS
    Creates AD users from a CSV and adds each one to its group. Home lab (lab.local).

.DESCRIPTION
    CSV columns: FirstName, LastName, Group
    - Users that already exist are skipped (SKIP). Existing users are NOT updated.
    - New users get a SamAccountName of First.Last, an initial password prompted at runtime,
      and must change it at first logon.
    - One failure does not stop the run; each user is reported as CREATED / SKIP / FAILED.

.EXAMPLE
    .\New-UsersFromCsv.ps1 -Path .\newusers.csv -WhatIf    # dry run, changes nothing
    .\New-UsersFromCsv.ps1 -Path .\newusers.csv
#>
[CmdletBinding(SupportsShouldProcess)]
param(
    [string]$Path = '.\newusers.csv',
    [string]$OU   = 'OU=Users,OU=Company,DC=lab,DC=local'
)

$ErrorActionPreference = 'Stop'
Import-Module ActiveDirectory

$users = Import-Csv -Path $Path
# Prompted, never stored in the script or the repo.
$password = Read-Host -Prompt 'Initial password for new users' -AsSecureString
$domain   = (Get-ADDomain).DNSRoot

$results = foreach ($u in $users) {
    $sam = "$($u.FirstName).$($u.LastName)"
    try {
        if (Get-ADUser -Filter "SamAccountName -eq '$sam'") {
            [pscustomobject]@{ User = $sam; Status = 'SKIP'; Detail = 'already exists' }
            continue
        }
        if ($PSCmdlet.ShouldProcess($sam, "Create user in $OU and add to $($u.Group)")) {
            New-ADUser -Name "$($u.FirstName) $($u.LastName)" `
                -GivenName $u.FirstName -Surname $u.LastName `
                -SamAccountName $sam -UserPrincipalName "$sam@$domain" `
                -Path $OU -AccountPassword $password -Enabled $true `
                -ChangePasswordAtLogon $true
            Add-ADGroupMember -Identity $u.Group -Members $sam
            [pscustomobject]@{ User = $sam; Status = 'CREATED'; Detail = $u.Group }
        }
    }
    catch {
        [pscustomobject]@{ User = $sam; Status = 'FAILED'; Detail = $_.Exception.Message }
    }
}

$results | Format-Table -AutoSize
