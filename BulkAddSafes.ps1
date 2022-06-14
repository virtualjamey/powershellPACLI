<#
    Permissions lookup

    updateObjectProperties = Update account properties
    createObject + updateObjectProperties = Add accounts (includes update permissions) and update account properties
    store + createObject = Update account content

#>

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

    # Shares safe so it is visible via the PVWA
    Set-PVSafe -safe $safe.safeName -safeOptions PartiallyImpersonatedUsers,ImpersonatedUsers,FullyImpersonatedUsers

    # Adds PVWAGWAccounts
    Add-PVSafeGWAccount -safe $safe.safeName -gwAccount PVWAGWAccounts 

    # Adds CPM
    Add-PVSafeOwner -owner $safe.cpm -safe $safe.safeName -list <# List accounts #> -retrieve <# Retrieve accounts #> -usePassword <# use accounts #> -createObject <# Add account if used with updateObjectProperties OR Update account content if used with store but NOT updateObjectProperties #> -store <# See createObject notes  #> -updateObjectProperties <# See createObject notes #> -initiateCPMChange <# Initiate CPM account management operations #> -initiateCPMChangeWithManualPassword <# Specify next account content #> -renameObject <# Rename Accounts#> -delete <# Delete accounts#> -unlockObject <# Unlock accounts#> -viewAudit <# View audit logs #> -createFolder <# Create folder#> -deleteFolder <# Delete folder #> -validateSafecontent <# Content Validation #>  -eventsList <# Events #> -addEvents <# Events #> 

    # Role1
    Add-PVSafeOwner -owner $safe.adminGroup -safe $safe.safeName -usePassword <# use accounts #> -retrieve <# Retrieve accounts #> -list <# List accounts #> -createObject <# Add account if used with updateObjectProperties OR Update account content if used with store but NOT updateObjectProperties #> -store <# See createObject notes #> -updateObjectProperties <# See createObject notes #> -initiateCPMChange <# Initiate CPM account management operations #> -initiateCPMChangeWithManualPassword <# Specify next account content #> -renameObject <# Rename Accounts#> -delete <# Delete accounts#> -unlockObject <# Unlock accounts#> -viewAudit <# View audit logs #> -viewPermissions <# View Safe Members #>  -createFolder <# Create folder#> -deleteFolder <# Delete folder #> -administer <# Manage Safe#> -supervise <# Authorize account requests #> -manageOwners <# Manage Safe Members #> -accessNoConfirmation <# Access safe without confirmation #> -validateSafecontent <# Content Validation #>  -moveFrom <# Move accounts/folders #> -moveInto <# Move accounts/folders #> -eventsList <# Events #> -addEvents <# Events #> -supervise <# Authorize account requests #> -accessNoConfirmation <# Access safe without confirmation #>

    # Role 2
    Add-PVSafeOwner -owner $safe.role2 -safe $safe.safeName -list <# List accounts #>  -initiateCPMChange <# Initiate CPM account management operations #> -unlockObject <# Unlock accounts#> -viewAudit <# View audit logs #> -viewPermissions <# View Safe Members #> -validateSafecontent <# Content Validation #>  -eventsList <# Events #> -addEvents <# Events #> 

    # Role 3
    Add-PVSafeOwner -owner $safe.role3 -safe $safe.safeName -list <# List accounts #> -createObject <# Add account if used with updateObjectProperties OR Update account content if used with store but NOT updateObjectProperties #> -updateObjectProperties <# See createObject notes #> -initiateCPMChange <# Initiate CPM account management operations #> -renameObject <# Rename Accounts#> -delete <# Delete accounts#> -unlockObject <# Unlock accounts#> -administer <# Manage Safe#>  -manageOwners <# Manage Safe Members #> -backup <# Backup safe#> -viewAudit <# View audit logs #> -viewPermissions <# View Safe Members #> -validateSafecontent <# Content Validation #> -eventsList <# Events #> -addEvents <# Events #>


}

# Cleans up vault connection
Disconnect-PVVault

# Cleans up pacli session
Stop-PVPacli