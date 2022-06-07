# Imports required powershell module. This module is located in the same directory as this script and is named PoshPACLI.
Import-Module -Name $PSScriptRoot\PoshPACLI -Force

# Cleans up any old vault connections
Disconnect-PVVault -ErrorAction SilentlyContinue

# Cleans up any old pacli sessions
Stop-PVPacli -ErrorAction SilentlyContinue

# defines the path of the pacli executable
Set-PVConfiguration -ClientPath $PSScriptRoot\PACLIBinaries\Pacli.exe

# Ask the user for vault credentials
$creds = Get-Credential -Message "Enter Vault Username and password"

# Imports list of safes to onboard
$safesToAdd = Import-Csv -Path "$PSScriptRoot\safesToAdd.csv"

# Starts a pacli session
Start-PVPacli -sessionID 5

# Defines the vault the xeipt will be run against
New-PVVaultDefinition -vault "Dev" -address "IP Address"

# Connects to vault using supplied credentials
Connect-PVVault -user $($creds.Username) -password $($creds.Password)

# Loops through each safe in $safesToAdd variable.
foreach($safe in $safesToAdd){

    New-PVSafe -safe safe.safeName -location \ -size 50 -fileRetention 100 -logRetention 30

    Open-PVSafe -safe $safe.safeName

    Set-PVSafe -safe $safe.safeName -safeOptions PartiallyImpersonatedUsers,ImpersonatedUsers,FullyImpersonatedUsers

    Add-PVSafeGWAccount -safe $safe.safeName -gwAccount PVWAGWAccounts 

    Add-PVSafeOwner -owner owerToAdd -safe $safe.safeName -list -retrieve -updateObjectProperties -renameObject -delete -viewAudit -viewPermissions -initiateCPMChange -initiateCPMChangeWithManualPassword -createFolder -deleteFolder -readOnlyByDefault -store -administer -supervise -backup -manageOwners -accessNoConfirmation -validateSafecontent -usePassword -moveFrom -moveInto -eventsList -addEvents -createObject -unlockObject

}

# Cleans up vault connection
Disconnect-PVVault

# Cleans up pacli session
Stop-PVPacli