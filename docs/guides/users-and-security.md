# Users & Security

PowerShell provides cmdlets for managing local users and groups, Active Directory accounts, execution policies, and security credentials.

---

## Local Users

```powershell
# List all local users
Get-LocalUser

# Get details on a specific user
Get-LocalUser -Name alice

# Create a new local user
$password = Read-Host "Password" -AsSecureString
New-LocalUser -Name "bob" -Password $password -FullName "Bob Smith" -Description "Developer"

# Enable / Disable a user
Enable-LocalUser  -Name bob
Disable-LocalUser -Name bob

# Change password
$newPwd = Read-Host "New password" -AsSecureString
Set-LocalUser -Name bob -Password $newPwd

# Remove a user
Remove-LocalUser -Name bob
```

---

## Local Groups

```powershell
# List all local groups
Get-LocalGroup

# Members of the Administrators group
Get-LocalGroupMember -Group "Administrators"

# Add a user to a group
Add-LocalGroupMember -Group "Administrators" -Member "bob"

# Remove from a group
Remove-LocalGroupMember -Group "Administrators" -Member "bob"

# Create a custom group
New-LocalGroup -Name "Developers" -Description "Dev team access"
```

---

## Credentials

```powershell
# Prompt for credentials interactively
$cred = Get-Credential

# Prompt with a custom message
$cred = Get-Credential -Message "Enter admin credentials" -UserName "DOMAIN\admin"

# Use credentials with a cmdlet
Get-ChildItem \\server\share -Credential $cred
Invoke-Command -ComputerName srv01 -Credential $cred -ScriptBlock { hostname }

# Create credentials in a script (non-interactive)
$user = "domain\svc_account"
$pass = ConvertTo-SecureString "P@ssw0rd" -AsPlainText -Force
$cred = New-Object PSCredential $user, $pass
```

!!! warning "Plain-text passwords"
    Never hard-code plain-text passwords in scripts. Use `Get-Credential`, environment variables, or an encrypted credential store instead.

---

## Execution Policy

Controls which scripts are allowed to run:

```powershell
# View the current policy at all scopes
Get-ExecutionPolicy -List

# Set for current user (no elevation needed)
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser

# Set machine-wide (requires elevation)
Set-ExecutionPolicy AllSigned -Scope LocalMachine

# Temporarily bypass for one command
PowerShell -ExecutionPolicy Bypass -File .\setup.ps1
```

| Policy | Behavior |
|--------|---------|
| `Restricted` | No scripts (default on Windows) |
| `AllSigned` | All scripts must be code-signed |
| `RemoteSigned` | Local scripts run freely; downloaded scripts need a signature |
| `Unrestricted` | All scripts run (warns on downloaded scripts) |
| `Bypass` | Nothing blocked — no warnings |

---

## File & Folder Permissions (ACLs)

```powershell
# View permissions on a path
Get-Acl .\sensitive.txt | Format-List

# View access rules
(Get-Acl .\folder).Access | Format-Table IdentityReference, FileSystemRights, AccessControlType

# Grant access
$acl  = Get-Acl .\folder
$rule = New-Object System.Security.AccessControl.FileSystemAccessRule(
    "DOMAIN\alice", "ReadAndExecute", "ContainerInherit,ObjectInherit", "None", "Allow"
)
$acl.AddAccessRule($rule)
Set-Acl .\folder $acl

# Copy ACL from one item to another
Get-Acl .\source | Set-Acl .\destination
```

---

## Digital Signatures

```powershell
# Check if a script is signed
Get-AuthenticodeSignature .\myscript.ps1

# Check multiple scripts
Get-ChildItem .\scripts -Filter *.ps1 |
    Get-AuthenticodeSignature |
    Select-Object Path, Status, SignerCertificate

# Sign a script (requires a code-signing certificate)
$cert = Get-ChildItem Cert:\CurrentUser\My -CodeSigningCert
Set-AuthenticodeSignature .\myscript.ps1 -Certificate $cert
```

---

## Auditing: Who Is Logged In?

```powershell
# Current user
$env:USERNAME
[System.Security.Principal.WindowsIdentity]::GetCurrent().Name

# Is current user an administrator?
([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(
    [Security.Principal.WindowsBuiltInRole]::Administrator
)

# Active logon sessions (CIM)
Get-CimInstance Win32_LoggedOnUser | Select-Object -ExpandProperty Antecedent | Select-Object Name, Domain

# Recent logon events (requires elevation)
Get-WinEvent -FilterHashtable @{
    LogName = 'Security'
    Id      = 4624   # successful logon
} -MaxEvents 20 | Select-Object TimeCreated,
    @{Name='User'; Expression={ $_.Properties[5].Value }},
    @{Name='Type'; Expression={ $_.Properties[8].Value }}
```

---

## Secure String and Credential Files

Save credentials encrypted to disk for use in scheduled tasks:

```powershell
# Save encrypted password to file (DPAPI — only readable by same user on same machine)
$password = Read-Host "Enter password" -AsSecureString
$password | ConvertFrom-SecureString | Out-File .\cred.txt

# Load it back
$password = Get-Content .\cred.txt | ConvertTo-SecureString
$cred = New-Object PSCredential "domain\user", $password
```

!!! tip "Cross-machine or cross-user encryption"
    DPAPI ties the encryption to the user profile on that machine. For portable credentials, use `-Key` with a 16, 24, or 32-byte AES key and store the key separately in a secrets manager or Azure Key Vault.
