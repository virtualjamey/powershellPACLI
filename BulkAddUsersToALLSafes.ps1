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
$safesToAddUsersTo = Import-Csv -Path "$PSScriptRoot\safesToAddUsersTo.csv"

# Starts a pacli session
Start-PVPacli -sessionID 5

# Defines the vault the xeipt will be run against
New-PVVaultDefinition -vault "Dev" -address "IP Address"

# Connects to vault using supplied credentials
Connect-PVVault -user $($creds.Username) -password $($creds.Password)

# Loops through each safe in $safesToAdd variable.
foreach($safe in $safesToAddUsersTo){

    Open-PVSafe -safe $safe.safeName

    # Role1
    Add-PVSafeOwner -owner $safe.adminGroup -safe $safe.safeName -usePassword <# use accounts #> -retrieve <# Retrieve accounts #> -list <# List accounts #> -createObject <# Add account if used with updateObjectProperties OR Update account content if used with store but NOT updateObjectProperties #> -store <# See createObject notes #> -updateObjectProperties <# See createObject notes #> -initiateCPMChange <# Initiate CPM account management operations #> -initiateCPMChangeWithManualPassword <# Specify next account content #> -renameObject <# Rename Accounts#> -delete <# Delete accounts#> -unlockObject <# Unlock accounts#> -viewAudit <# View audit logs #> -viewPermissions <# View Safe Members #>  -createFolder <# Create folder#> -deleteFolder <# Delete folder #> -administer <# Manage Safe#> -supervise <# Authorize account requests #> -manageOwners <# Manage Safe Members #> -accessNoConfirmation <# Access safe without confirmation #> -validateSafecontent <# Content Validation #>  -moveFrom <# Move accounts/folders #> -moveInto <# Move accounts/folders #> -eventsList <# Events #> -addEvents <# Events #> -supervise <# Authorize account requests #> -accessNoConfirmation <# Access safe without confirmation #>


}

# Cleans up vault connection
Disconnect-PVVault

# Cleans up pacli session
Stop-PVPacli