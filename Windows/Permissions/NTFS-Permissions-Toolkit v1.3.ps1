#requires -version 5.1
<#
.SYNOPSIS
    NTFS Permissions Toolkit
.DESCRIPTION
    Interactive PowerShell toolkit for inspecting, backing up, restoring and modifying
    NTFS ownership and permissions.

    Version 1.3 - file attributes and Windows HOSTS read-only controls.

    Default backup location:
        Desktop\Backup\NTFS-Permissions-Toolkit

    IMPORTANT:
    - Test first on non-critical files/folders.
    - Some operations require elevation.
    - System paths are protected with additional confirmations.
#>

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# -----------------------------
# Global state
# -----------------------------
$Script:Target = $null
$Script:DefaultBackupRoot = Join-Path ([Environment]::GetFolderPath('Desktop')) 'Backup\NTFS-Permissions-Toolkit'
$Script:BackupRoot = $Script:DefaultBackupRoot
$Script:LastBackupPath = $null

# -----------------------------
# Console helpers
# -----------------------------
function Write-Header {
    Clear-Host
    $identity = [Security.Principal.WindowsIdentity]::GetCurrent()
    $user = $identity.Name
    $isAdmin = Test-IsAdministrator
    $targetText = if ($Script:Target) { $Script:Target } else { '<not selected>' }

    Write-Host ('=' * 72)
    Write-Host '                     NTFS PERMISSIONS TOOLKIT'
    Write-Host ('=' * 72)
    Write-Host (" Current user : {0}" -f $user)
    Write-Host (" Elevated     : {0}" -f ($(if ($isAdmin) { 'YES' } else { 'NO' })))
    Write-Host (" Target       : {0}" -f $targetText)
    Write-Host (" Backup root  : {0}" -f $Script:BackupRoot)
    Write-Host ('=' * 72)
}

function Pause-Toolkit {
    Write-Host
    [void](Read-Host 'Press ENTER to continue')
}

function Test-IsBackCommand {
    param([AllowNull()][string]$Value)

    if ($null -eq $Value) {
        return $false
    }

    $v = $Value.Trim()
    return ($v -match '^(?i)(B|BACK|ESC|ESCAPE|Q|QUIT|CANCEL)$')
}

function Read-ToolkitInput {
    param(
        [Parameter(Mandatory)][string]$Prompt,
        [switch]$AllowBack
    )

    if ($AllowBack) {
        $value = Read-Host "$Prompt  [B=Back / ESC=Cancel]"
        if (Test-IsBackCommand $value) {
            return $null
        }
        return $value
    }

    return (Read-Host $Prompt)
}

function Write-Section([string]$Title) {
    Write-Host
    Write-Host ('-' * 72)
    Write-Host (" {0}" -f $Title)
    Write-Host ('-' * 72)
}

function Write-Info([string]$Message) {
    Write-Host "[INFO] $Message"
}

function Write-Warn([string]$Message) {
    Write-Warning $Message
}

function Write-Ok([string]$Message) {
    Write-Host "[OK]   $Message"
}

function Write-ErrorLine([string]$Message) {
    Write-Host "[ERR]  $Message"
}

# -----------------------------
# Security/elevation helpers
# -----------------------------
function Test-IsAdministrator {
    $principal = New-Object Security.Principal.WindowsPrincipal(
        [Security.Principal.WindowsIdentity]::GetCurrent()
    )
    return $principal.IsInRole(
        [Security.Principal.WindowsBuiltInRole]::Administrator
    )
}

function Require-Elevation {
    if (Test-IsAdministrator) {
        return $true
    }

    Write-Warn 'This operation requires administrator privileges.'
    $answer = Read-Host 'Restart this script as Administrator? [Y/N]'
    if ($answer -match '^[Yy]$') {
        $scriptPath = $PSCommandPath
        if (-not $scriptPath) {
            Write-ErrorLine 'Cannot determine the current script path for self-elevation.'
            return $false
        }

        $args = @(
            '-NoProfile',
            '-ExecutionPolicy', 'Bypass',
            '-File', ('"{0}"' -f $scriptPath)
        )

        Start-Process powershell.exe -Verb RunAs -ArgumentList $args
        exit
    }

    return $false
}

# -----------------------------
# Target helpers
# -----------------------------
function Resolve-InputPath {
    param([Parameter(Mandatory)][string]$PathText)

    # Drag & drop into the console often produces a quoted path.
    $clean = $PathText.Trim().Trim('"').Trim("'")

    if (-not $clean) {
        throw 'Empty path.'
    }

    $item = Get-Item -LiteralPath $clean -Force -ErrorAction Stop
    return $item.FullName
}

function Select-Target {
    Write-Section 'SELECT TARGET'
    Write-Host 'Opening graphical target selector...'
    Write-Host 'Browse File / Browse Folder are the reliable methods.'
    Write-Host 'Drag & drop can be blocked by Windows when privilege levels differ.'
    Write-Host

    try {
        Add-Type -AssemblyName System.Windows.Forms
        Add-Type -AssemblyName System.Drawing

        $form = New-Object System.Windows.Forms.Form
        $form.Text = 'NTFS Permissions Toolkit - Select Target'
        $form.StartPosition = 'CenterScreen'
        $form.Size = New-Object System.Drawing.Size(720, 335)
        $form.MinimumSize = New-Object System.Drawing.Size(650, 320)
        $form.KeyPreview = $true

        $title = New-Object System.Windows.Forms.Label
        $title.Text = 'Select a file or folder'
        $title.Font = New-Object System.Drawing.Font('Segoe UI', 14, [System.Drawing.FontStyle]::Bold)
        $title.AutoSize = $true
        $title.Location = New-Object System.Drawing.Point(20, 18)
        $form.Controls.Add($title)

        $pathBox = New-Object System.Windows.Forms.TextBox
        $pathBox.Location = New-Object System.Drawing.Point(20, 68)
        $pathBox.Size = New-Object System.Drawing.Size(660, 28)
        $pathBox.Font = New-Object System.Drawing.Font('Segoe UI', 10)
        if ($Script:Target) {
            $pathBox.Text = $Script:Target
        }
        $form.Controls.Add($pathBox)

        $browseFile = New-Object System.Windows.Forms.Button
        $browseFile.Text = 'Browse File...'
        $browseFile.Location = New-Object System.Drawing.Point(20, 118)
        $browseFile.Size = New-Object System.Drawing.Size(140, 36)
        $form.Controls.Add($browseFile)

        $browseFolder = New-Object System.Windows.Forms.Button
        $browseFolder.Text = 'Browse Folder...'
        $browseFolder.Location = New-Object System.Drawing.Point(170, 118)
        $browseFolder.Size = New-Object System.Drawing.Size(140, 36)
        $form.Controls.Add($browseFolder)

        $useTarget = New-Object System.Windows.Forms.Button
        $useTarget.Text = 'Use Target'
        $useTarget.Location = New-Object System.Drawing.Point(450, 118)
        $useTarget.Size = New-Object System.Drawing.Size(110, 36)
        $useTarget.DialogResult = [System.Windows.Forms.DialogResult]::OK
        $form.AcceptButton = $useTarget
        $form.Controls.Add($useTarget)

        $back = New-Object System.Windows.Forms.Button
        $back.Text = 'Back / Esc'
        $back.Location = New-Object System.Drawing.Point(570, 118)
        $back.Size = New-Object System.Drawing.Size(110, 36)
        $back.DialogResult = [System.Windows.Forms.DialogResult]::Cancel
        $form.CancelButton = $back
        $form.Controls.Add($back)

        $note = New-Object System.Windows.Forms.Label
        $note.Text = @"
You can paste/type a full path in the box above.
ESC closes this window and returns to the main menu.

Note: Windows can block drag & drop from Explorer into an elevated PowerShell process.
"@
        $note.AutoSize = $false
        $note.Location = New-Object System.Drawing.Point(20, 180)
        $note.Size = New-Object System.Drawing.Size(660, 75)
        $note.Font = New-Object System.Drawing.Font('Segoe UI', 9)
        $form.Controls.Add($note)

        $browseFile.Add_Click({
            $dialog = New-Object System.Windows.Forms.OpenFileDialog
            $dialog.Title = 'Select target file'
            $dialog.CheckFileExists = $true
            $dialog.Multiselect = $false
            if ($dialog.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
                $pathBox.Text = $dialog.FileName
            }
        })

        $browseFolder.Add_Click({
            $dialog = New-Object System.Windows.Forms.FolderBrowserDialog
            $dialog.Description = 'Select target folder'
            $dialog.ShowNewFolderButton = $false
            if ($dialog.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
                $pathBox.Text = $dialog.SelectedPath
            }
        })

        $form.Add_KeyDown({
            param($sender, $e)
            if ($e.KeyCode -eq [System.Windows.Forms.Keys]::Escape) {
                $form.DialogResult = [System.Windows.Forms.DialogResult]::Cancel
                $form.Close()
            }
        })

        $result = $form.ShowDialog()

        if ($result -eq [System.Windows.Forms.DialogResult]::OK) {
            try {
                $Script:Target = Resolve-InputPath -PathText $pathBox.Text
                Write-Ok "Target set to: $Script:Target"
            }
            catch {
                Write-ErrorLine $_.Exception.Message
            }
        }
        else {
            Write-Info 'Returning to main menu.'
        }

        $form.Dispose()
    }
    catch {
        Write-ErrorLine "Graphical selector failed: $($_.Exception.Message)"
        Write-Host
        $inputPath = Read-ToolkitInput -Prompt 'Target' -AllowBack

        if ($null -eq $inputPath) {
            Write-Info 'Returning to main menu.'
            Pause-Toolkit
            return
        }

        try {
            $Script:Target = Resolve-InputPath -PathText $inputPath
            Write-Ok "Target set to: $Script:Target"
        }
        catch {
            Write-ErrorLine $_.Exception.Message
        }
    }

    Pause-Toolkit
}

function Test-TargetSelected {
    if (-not $Script:Target) {
        Write-Warn 'No target selected.'
        Pause-Toolkit
        return $false
    }

    if (-not (Test-Path -LiteralPath $Script:Target)) {
        Write-Warn "Target no longer exists: $Script:Target"
        Pause-Toolkit
        return $false
    }

    return $true
}

function Test-SensitiveTarget {
    param([Parameter(Mandatory)][string]$Path)

    $full = [IO.Path]::GetFullPath($Path).TrimEnd('\')
    $windows = [IO.Path]::GetFullPath($env:windir).TrimEnd('\')
    $system32 = Join-Path $windows 'System32'
    $programFiles = [Environment]::GetFolderPath('ProgramFiles').TrimEnd('\')
    $programFilesX86 = [Environment]::GetFolderPath('ProgramFilesX86').TrimEnd('\')
    $systemDriveRoot = ([IO.Path]::GetPathRoot($env:SystemDrive)).TrimEnd('\')

    $sensitiveRoots = @(
        $windows,
        $system32,
        $programFiles,
        $programFilesX86,
        $systemDriveRoot
    ) | Where-Object { $_ }

    foreach ($root in $sensitiveRoots) {
        if ($full -ieq $root -or $full.StartsWith($root + '\', [StringComparison]::OrdinalIgnoreCase)) {
            return $true
        }
    }

    return $false
}

function Confirm-DangerousOperation {
    param(
        [Parameter(Mandatory)][string]$Operation,
        [switch]$AlwaysConfirm
    )

    $needsStrongConfirm = $AlwaysConfirm -or (Test-SensitiveTarget -Path $Script:Target)

    Write-Warn "You are about to: $Operation"
    Write-Host "Target: $Script:Target"

    if ($needsStrongConfirm) {
        Write-Warn 'This target is inside a sensitive Windows/system location.'
        $confirm = Read-ToolkitInput -Prompt 'Type CONFIRM to continue' -AllowBack
        if ($null -eq $confirm) { return $false }
        return ($confirm -ceq 'CONFIRM')
    }
    else {
        $confirm = Read-ToolkitInput -Prompt 'Continue? [Y/N]' -AllowBack
        if ($null -eq $confirm) { return $false }
        return ($confirm -match '^[Yy]$')
    }
}

# -----------------------------
# Backup helpers
# -----------------------------
function Ensure-BackupRoot {
    if (-not (Test-Path -LiteralPath $Script:BackupRoot)) {
        New-Item -ItemType Directory -Path $Script:BackupRoot -Force | Out-Null
    }
}

function Set-BackupRoot {
    Write-Section 'BACKUP LOCATION'
    Write-Host "Current: $Script:BackupRoot"
    Write-Host 'Press ENTER to restore the default location.'
    Write-Host "Default: $Script:DefaultBackupRoot"
    $inputPath = Read-ToolkitInput -Prompt 'New backup folder' -AllowBack

    if ($null -eq $inputPath) {
        Write-Info 'Returning to main menu.'
        Pause-Toolkit
        return
    }

    if ([string]::IsNullOrWhiteSpace($inputPath)) {
        $Script:BackupRoot = $Script:DefaultBackupRoot
        Ensure-BackupRoot
        Write-Ok "Backup location restored to: $Script:BackupRoot"
        Pause-Toolkit
        return
    }

    $clean = $inputPath.Trim().Trim('"').Trim("'")

    try {
        if (-not (Test-Path -LiteralPath $clean)) {
            New-Item -ItemType Directory -Path $clean -Force | Out-Null
        }

        $Script:BackupRoot = (Get-Item -LiteralPath $clean -Force).FullName
        Write-Ok "Backup location set to: $Script:BackupRoot"
    }
    catch {
        Write-ErrorLine $_.Exception.Message
    }

    Pause-Toolkit
}

function New-BackupFolder {
    Ensure-BackupRoot

    $timestamp = Get-Date -Format 'yyyy-MM-dd_HH-mm-ss'
    $safeName = Split-Path -Leaf $Script:Target
    if ([string]::IsNullOrWhiteSpace($safeName)) {
        $safeName = 'ROOT'
    }
    $safeName = ($safeName -replace '[^\w\.-]', '_')

    $folder = Join-Path $Script:BackupRoot "${timestamp}_${safeName}"
    New-Item -ItemType Directory -Path $folder -Force | Out-Null
    $Script:LastBackupPath = $folder
    return $folder
}

function Export-SecuritySnapshot {
    param(
        [Parameter(Mandatory)][string]$DestinationFolder,
        [switch]$IncludeTargetCopy
    )

    $acl = Get-Acl -LiteralPath $Script:Target

    # Human-readable ACL report
    $reportPath = Join-Path $DestinationFolder 'ACL_Report.txt'
    @(
        "Target: $Script:Target"
        "Captured: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
        ""
        "OWNER:"
        $acl.Owner
        ""
        "ACL:"
        ($acl.Access | Format-Table -AutoSize | Out-String)
        ""
        "FULL GET-ACL:"
        ($acl | Format-List * | Out-String)
    ) | Set-Content -LiteralPath $reportPath -Encoding UTF8

    # Serialized ACL object
    $xmlPath = Join-Path $DestinationFolder 'ACL.xml'
    $acl | Export-Clixml -LiteralPath $xmlPath

    # ICACLS output
    $icaclsPath = Join-Path $DestinationFolder 'ICACLS.txt'
    (& icacls.exe "$Script:Target" 2>&1 | Out-String) |
        Set-Content -LiteralPath $icaclsPath -Encoding UTF8

    # Metadata
    $metadataPath = Join-Path $DestinationFolder 'Metadata.txt'
    $item = Get-Item -LiteralPath $Script:Target -Force
    @(
        "Target=$Script:Target"
        "Type=$(if ($item.PSIsContainer) {'Directory'} else {'File'})"
        "Captured=$(Get-Date -Format 'o')"
        "Owner=$($acl.Owner)"
        "BackupRoot=$Script:BackupRoot"
    ) | Set-Content -LiteralPath $metadataPath -Encoding UTF8

    if ($IncludeTargetCopy) {
        if ($item.PSIsContainer) {
            $copyFolder = Join-Path $DestinationFolder 'TargetCopy'
            Copy-Item -LiteralPath $Script:Target -Destination $copyFolder -Recurse -Force
        }
        else {
            $copyFolder = Join-Path $DestinationFolder 'TargetCopy'
            New-Item -ItemType Directory -Path $copyFolder -Force | Out-Null
            Copy-Item -LiteralPath $Script:Target -Destination $copyFolder -Force
        }
    }
}

function Backup-TargetSecurity {
    if (-not (Test-TargetSelected)) { return }

    Write-Section 'BACKUP TARGET SECURITY'
    try {
        $folder = New-BackupFolder
        Export-SecuritySnapshot -DestinationFolder $folder -IncludeTargetCopy
        Write-Ok "Backup created: $folder"
    }
    catch {
        Write-ErrorLine $_.Exception.Message
    }

    Pause-Toolkit
}

function Backup-TargetSecurityAutomatic {
    if (-not (Test-TargetSelected)) { return $null }

    $folder = New-BackupFolder
    Export-SecuritySnapshot -DestinationFolder $folder
    Write-Ok "Automatic ACL backup created: $folder"
    return $folder
}

function Restore-AclFromBackup {
    if (-not (Test-TargetSelected)) { return }
    if (-not (Require-Elevation)) { return }

    Write-Section 'RESTORE ACL FROM BACKUP'
    Write-Host 'Drag & drop an ACL.xml file here, or type its full path.'
    $inputPath = Read-ToolkitInput -Prompt 'ACL.xml path' -AllowBack

    if ($null -eq $inputPath) {
        Write-Info 'Returning to main menu.'
        Pause-Toolkit
        return
    }

    try {
        $xmlPath = Resolve-InputPath -PathText $inputPath
        if ((Split-Path -Leaf $xmlPath) -ne 'ACL.xml') {
            Write-Warn 'The selected file is not named ACL.xml. Attempting restore anyway.'
        }

        if (-not (Confirm-DangerousOperation -Operation 'restore ACL from the selected backup')) {
            Write-Warn 'Operation cancelled.'
            Pause-Toolkit
            return
        }

        $acl = Import-Clixml -LiteralPath $xmlPath
        Set-Acl -LiteralPath $Script:Target -AclObject $acl
        Write-Ok 'ACL restored successfully.'
    }
    catch {
        Write-ErrorLine $_.Exception.Message
    }

    Pause-Toolkit
}

# -----------------------------
# Information / diagnostics
# -----------------------------
function Show-IdentityAndGroups {
    Write-Section 'CURRENT USER / GROUPS / PRIVILEGES'
    & whoami.exe
    Write-Host
    & whoami.exe /groups
    Write-Host
    & whoami.exe /priv
    Pause-Toolkit
}

function Show-Icacls {
    if (-not (Test-TargetSelected)) { return }
    Write-Section 'ICACLS'
    & icacls.exe "$Script:Target"
    Pause-Toolkit
}

function Show-DetailedAcl {
    if (-not (Test-TargetSelected)) { return }
    Write-Section 'DETAILED ACL'
    Get-Acl -LiteralPath $Script:Target | Format-List *
    Pause-Toolkit
}

function Export-ReadableReport {
    if (-not (Test-TargetSelected)) { return }

    Write-Section 'EXPORT SECURITY REPORT'
    try {
        Ensure-BackupRoot
        $timestamp = Get-Date -Format 'yyyy-MM-dd_HH-mm-ss'
        $safeName = (Split-Path -Leaf $Script:Target) -replace '[^\w\.-]', '_'
        if (-not $safeName) { $safeName = 'ROOT' }
        $report = Join-Path $Script:BackupRoot "${timestamp}_${safeName}_SecurityReport.txt"

        $acl = Get-Acl -LiteralPath $Script:Target
        @(
            "NTFS Permissions Toolkit - Security Report"
            "Generated: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
            "Target: $Script:Target"
            ""
            "CURRENT USER:"
            (& whoami.exe | Out-String)
            ""
            "OWNER:"
            $acl.Owner
            ""
            "ACCESS RULES:"
            ($acl.Access | Format-Table -AutoSize | Out-String)
            ""
            "ICACLS:"
            (& icacls.exe "$Script:Target" 2>&1 | Out-String)
            ""
            "DETAILED GET-ACL:"
            ($acl | Format-List * | Out-String)
        ) | Set-Content -LiteralPath $report -Encoding UTF8

        Write-Ok "Report saved to: $report"
    }
    catch {
        Write-ErrorLine $_.Exception.Message
    }

    Pause-Toolkit
}

function Show-InheritanceStatus {
    if (-not (Test-TargetSelected)) { return }

    Write-Section 'INHERITANCE STATUS'
    try {
        $acl = Get-Acl -LiteralPath $Script:Target
        Write-Host "AreAccessRulesProtected : $($acl.AreAccessRulesProtected)"
        Write-Host
        Write-Host 'Meaning:'
        Write-Host '  False = inheritance is enabled.'
        Write-Host '  True  = inheritance is disabled/protected.'
        Write-Host
        $acl.Access |
            Select-Object IdentityReference, FileSystemRights, AccessControlType, IsInherited, InheritanceFlags, PropagationFlags |
            Format-Table -AutoSize
    }
    catch {
        Write-ErrorLine $_.Exception.Message
    }

    Pause-Toolkit
}

function Explain-IcaclsMarkers {
    Write-Section 'ICACLS MARKER REFERENCE'
    @'
Common permission markers:
  (F)   Full Control
  (M)   Modify
  (RX)  Read & Execute
  (R)   Read
  (W)   Write
  (D)   Delete

Inheritance markers:
  (I)   Inherited from parent
  (OI)  Object Inherit - files inherit the ACE
  (CI)  Container Inherit - subfolders inherit the ACE
  (IO)  Inherit Only
  (NP)  No Propagate

Access type:
  DENY  Explicit deny entry
'@ | Write-Host
    Pause-Toolkit
}

# -----------------------------
# Ownership operations
# -----------------------------
function Set-OwnerCurrentUser {
    if (-not (Test-TargetSelected)) { return }
    if (-not (Require-Elevation)) { return }
    if (-not (Confirm-DangerousOperation -Operation 'take ownership as the current user')) {
        Write-Warn 'Operation cancelled.'
        Pause-Toolkit
        return
    }

    try {
        Backup-TargetSecurityAutomatic | Out-Null
        & takeown.exe /F "$Script:Target"
        Write-Ok 'Ownership command completed.'
    }
    catch {
        Write-ErrorLine $_.Exception.Message
    }
    Pause-Toolkit
}

function Set-OwnerAdministrators {
    if (-not (Test-TargetSelected)) { return }
    if (-not (Require-Elevation)) { return }
    if (-not (Confirm-DangerousOperation -Operation 'set owner to the local Administrators group')) {
        Write-Warn 'Operation cancelled.'
        Pause-Toolkit
        return
    }

    try {
        Backup-TargetSecurityAutomatic | Out-Null
        & icacls.exe "$Script:Target" /setowner '*S-1-5-32-544'
        Write-Ok 'Owner set to local Administrators group.'
    }
    catch {
        Write-ErrorLine $_.Exception.Message
    }
    Pause-Toolkit
}

function Set-OwnerTrustedInstaller {
    if (-not (Test-TargetSelected)) { return }
    if (-not (Require-Elevation)) { return }
    if (-not (Confirm-DangerousOperation -Operation 'set owner to NT SERVICE\TrustedInstaller')) {
        Write-Warn 'Operation cancelled.'
        Pause-Toolkit
        return
    }

    try {
        Backup-TargetSecurityAutomatic | Out-Null
        & icacls.exe "$Script:Target" /setowner 'NT SERVICE\TrustedInstaller'
        Write-Ok 'Owner set to TrustedInstaller.'
    }
    catch {
        Write-ErrorLine $_.Exception.Message
    }
    Pause-Toolkit
}

# -----------------------------
# Permission operations
# -----------------------------
function Grant-CurrentUserFullControl {
    if (-not (Test-TargetSelected)) { return }
    if (-not (Require-Elevation)) { return }
    if (-not (Confirm-DangerousOperation -Operation 'grant Full Control to the current user')) {
        Write-Warn 'Operation cancelled.'
        Pause-Toolkit
        return
    }

    try {
        Backup-TargetSecurityAutomatic | Out-Null
        $user = [Security.Principal.WindowsIdentity]::GetCurrent().Name
        & icacls.exe "$Script:Target" /grant "${user}:(F)"
        Write-Ok "Granted Full Control to: $user"
    }
    catch {
        Write-ErrorLine $_.Exception.Message
    }
    Pause-Toolkit
}

function Grant-AdministratorsFullControl {
    if (-not (Test-TargetSelected)) { return }
    if (-not (Require-Elevation)) { return }
    if (-not (Confirm-DangerousOperation -Operation 'grant Full Control to local Administrators')) {
        Write-Warn 'Operation cancelled.'
        Pause-Toolkit
        return
    }

    try {
        Backup-TargetSecurityAutomatic | Out-Null
        & icacls.exe "$Script:Target" /grant '*S-1-5-32-544:(F)'
        Write-Ok 'Granted Full Control to local Administrators.'
    }
    catch {
        Write-ErrorLine $_.Exception.Message
    }
    Pause-Toolkit
}

function Grant-CurrentUserModify {
    if (-not (Test-TargetSelected)) { return }
    if (-not (Require-Elevation)) { return }
    if (-not (Confirm-DangerousOperation -Operation 'grant Modify permission to the current user')) {
        Write-Warn 'Operation cancelled.'
        Pause-Toolkit
        return
    }

    try {
        Backup-TargetSecurityAutomatic | Out-Null
        $user = [Security.Principal.WindowsIdentity]::GetCurrent().Name
        & icacls.exe "$Script:Target" /grant "${user}:(M)"
        Write-Ok "Granted Modify permission to: $user"
    }
    catch {
        Write-ErrorLine $_.Exception.Message
    }
    Pause-Toolkit
}

function Remove-ExplicitCurrentUserPermission {
    if (-not (Test-TargetSelected)) { return }
    if (-not (Require-Elevation)) { return }

    Write-Warn 'This removes explicit ACE entries for the current user from the target.'
    if (-not (Confirm-DangerousOperation -Operation 'remove explicit permissions for the current user' -AlwaysConfirm)) {
        Write-Warn 'Operation cancelled.'
        Pause-Toolkit
        return
    }

    try {
        Backup-TargetSecurityAutomatic | Out-Null
        $user = [Security.Principal.WindowsIdentity]::GetCurrent().Name
        & icacls.exe "$Script:Target" /remove "$user"
        Write-Ok "Explicit entries removed for: $user"
    }
    catch {
        Write-ErrorLine $_.Exception.Message
    }
    Pause-Toolkit
}

# -----------------------------
# Inheritance operations
# -----------------------------
function Enable-Inheritance {
    if (-not (Test-TargetSelected)) { return }
    if (-not (Require-Elevation)) { return }
    if (-not (Confirm-DangerousOperation -Operation 'enable ACL inheritance from the parent')) {
        Write-Warn 'Operation cancelled.'
        Pause-Toolkit
        return
    }

    try {
        Backup-TargetSecurityAutomatic | Out-Null
        & icacls.exe "$Script:Target" /inheritance:e
        Write-Ok 'Inheritance enabled.'
    }
    catch {
        Write-ErrorLine $_.Exception.Message
    }
    Pause-Toolkit
}

function Disable-InheritancePreserve {
    if (-not (Test-TargetSelected)) { return }
    if (-not (Require-Elevation)) { return }
    if (-not (Confirm-DangerousOperation -Operation 'disable inheritance while preserving inherited ACEs as explicit entries')) {
        Write-Warn 'Operation cancelled.'
        Pause-Toolkit
        return
    }

    try {
        Backup-TargetSecurityAutomatic | Out-Null
        & icacls.exe "$Script:Target" /inheritance:d
        Write-Ok 'Inheritance disabled; inherited entries preserved as explicit entries.'
    }
    catch {
        Write-ErrorLine $_.Exception.Message
    }
    Pause-Toolkit
}

function Reset-AclFromParent {
    if (-not (Test-TargetSelected)) { return }
    if (-not (Require-Elevation)) { return }

    Write-Warn '/reset does NOT mean "restore Microsoft defaults".'
    Write-Warn 'It replaces ACL entries with inherited ACLs from the parent.'
    if (-not (Confirm-DangerousOperation -Operation 'RESET ACL FROM PARENT' -AlwaysConfirm)) {
        Write-Warn 'Operation cancelled.'
        Pause-Toolkit
        return
    }

    try {
        Backup-TargetSecurityAutomatic | Out-Null
        & icacls.exe "$Script:Target" /reset
        Write-Ok 'ACL reset from parent inheritance completed.'
    }
    catch {
        Write-ErrorLine $_.Exception.Message
    }
    Pause-Toolkit
}

# -----------------------------
# Comparison
# -----------------------------
function Compare-CurrentAclWithBackup {
    if (-not (Test-TargetSelected)) { return }

    Write-Section 'COMPARE CURRENT ACL WITH SAVED ACL'
    Write-Host 'Drag & drop an ACL.xml file here, or type its path.'
    $inputPath = Read-ToolkitInput -Prompt 'ACL.xml path' -AllowBack

    if ($null -eq $inputPath) {
        Write-Info 'Returning to main menu.'
        Pause-Toolkit
        return
    }

    try {
        $xmlPath = Resolve-InputPath -PathText $inputPath
        $oldAcl = Import-Clixml -LiteralPath $xmlPath
        $newAcl = Get-Acl -LiteralPath $Script:Target

        $oldLines = @(
            "Owner=$($oldAcl.Owner)"
            $oldAcl.Access | ForEach-Object {
                "ACE=$($_.IdentityReference)|$($_.FileSystemRights)|$($_.AccessControlType)|Inherited=$($_.IsInherited)|IF=$($_.InheritanceFlags)|PF=$($_.PropagationFlags)"
            }
        )

        $newLines = @(
            "Owner=$($newAcl.Owner)"
            $newAcl.Access | ForEach-Object {
                "ACE=$($_.IdentityReference)|$($_.FileSystemRights)|$($_.AccessControlType)|Inherited=$($_.IsInherited)|IF=$($_.InheritanceFlags)|PF=$($_.PropagationFlags)"
            }
        )

        $diff = Compare-Object -ReferenceObject $oldLines -DifferenceObject $newLines

        if (-not $diff) {
            Write-Ok 'No ACL differences found.'
        }
        else {
            Write-Host
            Write-Host 'Legend: <= only in backup, => only in current ACL'
            $diff | Format-Table -AutoSize
        }
    }
    catch {
        Write-ErrorLine $_.Exception.Message
    }

    Pause-Toolkit
}

# -----------------------------
# File attributes (not NTFS ACLs)
# -----------------------------
function Set-ToolkitAttribute {
    param(
        [Parameter(Mandatory)][string]$Path,
        [Parameter(Mandatory)][System.IO.FileAttributes]$Attribute,
        [Parameter(Mandatory)][bool]$Enable
    )

    $item = Get-Item -LiteralPath $Path -Force -ErrorAction Stop
    $before = $item.Attributes
    $value = [int]$before
    $flag = [int]$Attribute
    if ($Enable) { $value = $value -bor $flag }
    else { $value = $value -band (-bnot $flag) }

    if ($value -eq [int]$before) {
        Write-Info "Already configured: $Attribute = $Enable"
        return
    }

    # Apply only to the selected object; never recurse into folders.
    [System.IO.File]::SetAttributes($item.FullName, [System.IO.FileAttributes]$value)
    $after = (Get-Item -LiteralPath $Path -Force).Attributes
    Write-Ok "Attributes: $before -> $after"
}

function Manage-TargetAttributes {
    if (-not (Test-TargetSelected)) { return }

    $available = @(
        [System.IO.FileAttributes]::ReadOnly,
        [System.IO.FileAttributes]::Hidden,
        [System.IO.FileAttributes]::System,
        [System.IO.FileAttributes]::Archive
    )

    while ($true) {
        Write-Section 'FILE / FOLDER ATTRIBUTES'
        $item = Get-Item -LiteralPath $Script:Target -Force
        Write-Host "Target: $($item.FullName)"
        Write-Host "Current: $($item.Attributes)"
        Write-Host 'These flags are separate from NTFS permissions (ACL).'
        Write-Host 'Changes apply to this item only, not recursively.'
        Write-Host
        for ($i = 0; $i -lt $available.Count; $i++) {
            $flag = $available[$i]
            $enabled = (([int]$item.Attributes -band [int]$flag) -ne 0)
            Write-Host (" [{0}] {1,-10} : {2}" -f ($i + 1), $flag, $(if ($enabled) { 'ON' } else { 'OFF' }))
        }
        $selection = Read-ToolkitInput -Prompt 'Select attribute to toggle [1-4]' -AllowBack
        if ($null -eq $selection) { return }
        if ($selection -notmatch '^[1-4]$') { Write-Warn 'Invalid selection.'; continue }
        $flag = $available[[int]$selection - 1]
        $enabled = (([int]$item.Attributes -band [int]$flag) -ne 0)
        if (-not (Require-Elevation)) { return }
        if (-not (Confirm-DangerousOperation -Operation "set attribute $flag to $(-not $enabled)")) {
            Write-Warn 'Operation cancelled.'
            continue
        }
        try {
            Set-ToolkitAttribute -Path $Script:Target -Attribute $flag -Enable (-not $enabled)
        }
        catch { Write-ErrorLine $_.Exception.Message }
        Pause-Toolkit
    }
}

function Manage-WindowsHostsReadOnly {
    $hostsPath = Join-Path $env:windir 'System32\drivers\etc\hosts'
    Write-Section 'WINDOWS HOSTS - READ ONLY'
    if (-not (Test-Path -LiteralPath $hostsPath -PathType Leaf)) {
        Write-ErrorLine "HOSTS not found: $hostsPath"
        Pause-Toolkit
        return
    }

    $item = Get-Item -LiteralPath $hostsPath -Force
    $isReadOnly = (([int]$item.Attributes -band [int][System.IO.FileAttributes]::ReadOnly) -ne 0)
    Write-Host "File: $hostsPath"
    Write-Host "Attributes: $($item.Attributes)"
    Write-Host "ReadOnly: $isReadOnly"
    Write-Host ' [1] Enable editing (remove ReadOnly)'
    Write-Host ' [2] Protect from accidental edits (set ReadOnly)'
    Write-Host ' [B] Back'
    $choice = Read-ToolkitInput -Prompt 'Select action' -AllowBack
    if ($null -eq $choice) { return }
    if ($choice -notin @('1','2')) { Write-Warn 'Invalid selection.'; Pause-Toolkit; return }
    $enableReadOnly = ($choice -eq '2')
    if (-not (Require-Elevation)) { return }
    # HOSTS is in a Windows system directory: always require explicit confirmation.
    Write-Warn 'This only changes ReadOnly; ACLs, ownership and antivirus protection are unchanged.'
    $previousTarget = $Script:Target
    try {
        $Script:Target = $hostsPath
        if (-not (Confirm-DangerousOperation -Operation "set HOSTS ReadOnly to $enableReadOnly" -AlwaysConfirm)) {
            Write-Warn 'Operation cancelled.'
            return
        }
        Set-ToolkitAttribute -Path $hostsPath -Attribute ([System.IO.FileAttributes]::ReadOnly) -Enable $enableReadOnly
    }
    catch { Write-ErrorLine $_.Exception.Message }
    finally {
        $Script:Target = $previousTarget
        Pause-Toolkit
    }
}

# -----------------------------
# Main menu
# -----------------------------
function Show-MainMenu {
    Write-Header

    Write-Host
    Write-Host ' INFORMATION / DIAGNOSTICS'
    Write-Host '  [1]  Show current user, groups and privileges'
    Write-Host '       Displays identity, group membership and token privileges.'
    Write-Host '  [2]  Show permissions (ICACLS)'
    Write-Host '       Displays the target ACL in native ICACLS format.'
    Write-Host '  [3]  Show detailed ACL (Get-Acl)'
    Write-Host '       Displays owner, rules, inheritance and advanced ACL details.'
    Write-Host '  [4]  Export readable security report'
    Write-Host '       Saves owner, ACL and ICACLS information to a TXT file.'
    Write-Host '  [5]  Show inheritance status'
    Write-Host '       Shows whether ACL inheritance is enabled and which ACEs are inherited.'
    Write-Host '  [6]  Explain ICACLS markers'
    Write-Host '       Quick reference for (F), (M), (RX), (I), (OI), (CI), etc.'

    Write-Host
    Write-Host ' BACKUP / RESTORE'
    Write-Host '  [7]  Backup ACL + target copy'
    Write-Host '       Creates ACL.xml, reports and a copy of the selected file/folder.'
    Write-Host '  [8]  Restore ACL from ACL.xml'
    Write-Host '       Restores a previously saved PowerShell ACL snapshot.'
    Write-Host '  [9]  Change backup folder'
    Write-Host '       Default is Desktop\Backup\NTFS-Permissions-Toolkit.'

    Write-Host
    Write-Host ' OWNERSHIP'
    Write-Host ' [10]  Take ownership - Current user'
    Write-Host '       Changes owner using TAKEOWN.'
    Write-Host ' [11]  Set owner - Administrators'
    Write-Host '       Sets the local Administrators group as owner.'
    Write-Host ' [12]  Restore owner - TrustedInstaller'
    Write-Host '       Sets NT SERVICE\TrustedInstaller as owner.'

    Write-Host
    Write-Host ' PERMISSIONS'
    Write-Host ' [13]  Grant current user Full Control'
    Write-Host '       Adds an explicit Full Control ACE for the current account.'
    Write-Host ' [14]  Grant Administrators Full Control'
    Write-Host '       Adds Full Control for the local Administrators group.'
    Write-Host ' [15]  Grant current user Modify'
    Write-Host '       Adds Modify permission without granting Full Control.'
    Write-Host ' [16]  Remove current user explicit ACEs'
    Write-Host '       Removes explicit ACL entries for the current account.'

    Write-Host
    Write-Host ' INHERITANCE / ADVANCED'
    Write-Host ' [17]  Enable inheritance'
    Write-Host '       Enables inheritance from the parent object.'
    Write-Host ' [18]  Disable inheritance (preserve entries)'
    Write-Host '       Converts inherited entries to explicit entries.'
    Write-Host ' [19]  Compare current ACL with saved ACL'
    Write-Host '       Shows differences between current ACL and an ACL.xml backup.'
    Write-Host ' [20]  Reset ACL from parent'
    Write-Host '       DANGEROUS: replaces ACL with inherited parent permissions.'

    Write-Host
    Write-Host ' FILE ATTRIBUTES / HOSTS'
    Write-Host ' [21]  View / toggle ReadOnly, Hidden, System, Archive on target'
    Write-Host '       Updates one attribute at a time, with confirmation.'
    Write-Host ' [22]  Windows HOSTS - enable / disable ReadOnly'
    Write-Host '       Quick action for the HOSTS file without changing its ACL.'

    Write-Host
    Write-Host ' GENERAL'
    Write-Host '  [T]  Change target'
    Write-Host '  [R]  Refresh screen'
    Write-Host '  [B]  Back / return to main menu'
    Write-Host '  [Q]  Quit'
    Write-Host
}

# -----------------------------
# Program entry
# -----------------------------
Ensure-BackupRoot

while ($true) {
    Show-MainMenu
    $choice = Read-Host 'Select an option'

    switch ($choice.ToUpperInvariant()) {
        '1'  { Show-IdentityAndGroups }
        '2'  { Show-Icacls }
        '3'  { Show-DetailedAcl }
        '4'  { Export-ReadableReport }
        '5'  { Show-InheritanceStatus }
        '6'  { Explain-IcaclsMarkers }
        '7'  { Backup-TargetSecurity }
        '8'  { Restore-AclFromBackup }
        '9'  { Set-BackupRoot }
        '10' { Set-OwnerCurrentUser }
        '11' { Set-OwnerAdministrators }
        '12' { Set-OwnerTrustedInstaller }
        '13' { Grant-CurrentUserFullControl }
        '14' { Grant-AdministratorsFullControl }
        '15' { Grant-CurrentUserModify }
        '16' { Remove-ExplicitCurrentUserPermission }
        '17' { Enable-Inheritance }
        '18' { Disable-InheritancePreserve }
        '19' { Compare-CurrentAclWithBackup }
        '20' { Reset-AclFromParent }
        '21' { Manage-TargetAttributes }
        '22' { Manage-WindowsHostsReadOnly }
        'T'  { Select-Target }
        'R'  { continue }
        'B'  { continue }
        'BACK' { continue }
        'ESC' { break }
        'ESCAPE' { break }
        'Q'  { break }
        default {
            Write-Warn 'Invalid selection.'
            Start-Sleep -Seconds 1
        }
    }

    if ($choice.ToUpperInvariant() -in @('Q','ESC','ESCAPE')) {
        break
    }
}
