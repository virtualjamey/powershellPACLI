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

# Starts a pacli session
Start-PVPacli -sessionID 5

# Defines the vault the xeipt will be run against
New-PVVaultDefinition -vault "Dev" -address "IP Address"

# Connects to vault using supplied credentials
Connect-PVVault -user $($creds.Username) -password $($creds.Password)

$safesToIgnore = @(
    'System',
    'Pictures',
    'VaultInternal',
    'Notification Engine',
    'PVWAConfig',
    'PVWAUserPrefs',
    'SharedAuth_Internal',
    'PVWAReports',
    'PVWATicketingSystem',
    'PVWATaskDefinitions',
    'PVWAPrivateUserPrefs',
    'PVWAPublicData',
    'PasswordManager',
    'PasswordManager_workspace',
    'PassworManager_ADInternal',
    'PasswordManager_Info',
    'PasswordManagerShared',
    'PasswordManagerTemp',
    'PasswordManager_Pending',
    'AccountsFeedADAccounts',
    'AccountsFeedDiscoveryLogs'
)

# FOR TESTING
# Imports list of safes to onboard
$safesToAddUsersTo = Import-Csv -Path "$PSScriptRoot\safesToAddUsersTo.csv"
$safesToAddUsersTo = $safesToAddUsersTo | Where-Object -Filterscript {$_ -notmatch [String]::Join('|',$safesToIgnore)}


# UNCOMMENT AFTER TESTING TO ENABLE ALL SAFES
# Imports list of safes to onboard
#$safesToAddUsersTo = Get-PVSafeList -location \ 
#$safesToAddUsersTo = $safesToAddUsersTo | Where-Object -Filterscript {$_ -notmatch [String]::Join('|',$safesToIgnore)}

# Loops through each safe in $safesToAdd variable.
foreach($safe in $safesToAddUsersTo){

    # Open Safe
    Open-PVSafe -safe $safe.safeName

    # Attempts to add ldap user if not already in vault
    Add-PVExternalUser -destUser $safe.safename -ldapDirectory ABC -ErrorAction SilentlyContinue

    # Removes user before readding with correct permissions
    Remove-PVSafeOwner -safe $safe.safeName -owner $safe.safeName -ErrorAction SilentlyContinue

    # Adds user with correct permissions
    Add-PVsafeOwner  -safe $safe.safeName -owner $safe.safeName -owner -ErrorAction SilentlyContinue
    
    # Removes group before readding with correct permissions
    Remove-PVSafeOwner -safe $safe.safeName -owner "Group1"

    # Adds group with permissions
    Add-PVSafeOwner -owner "Group1" -safe $safe.safeName -owner  -retrieve -store -createObject -list -usePassword -initiateCPMChange -initiateCPMChangeWithManualPassword -eventsList -unlockObject 

    # Removes group before readding with correct permissions
    Remove-PVSafeOwner -safe $safe.safeName -owner "Group2"

    # Adds group with permissions
    Add-PVSafeOwner -owner "Group2" -safe $safe.safeName -list -updateobjectprperties -initiateCPMChange -initiateCPMChangeWithManualPassword -viewAudit -viewPermissions -eventsList -addEvetns -createObject -unlockObject -renameObject

    # Removes group
    Remove-PVSafeOwner -safe $safe.safeName -owner "Group3"

    # Adds group with permissions
    Add-PVSafeOwner -owner "Group3" -safe $safe.safeName -delete -administer -backup -manageOwners -list -updateObjectProperties -initiateCPMChange -viewAudit viewPermissions -eventsList -addEvents -createObject  -store unlockObject -renameObject 

    # Removes group
    Remove-PVSafeOwner -safe $safe.safeName -owner "Group4"

    # Adds group with permissions
    Add-PVsafeOwner -destUser "Group4" -safe $safe.safeName -delete -administer -backup -manageOwners -list -updateObjectProperties -initiateCPMChange -viewAudit -viewPermissions -eventsList -addEvents -createObject -store	-unlockObject -renameObject
  
    # Removes group
    Remove-PVSafeOwner -safe $safe.safeName -owner "Group5"

    # Adds group with permissions
    Add-PVsafeOwner -owner "Group5" -safe $safe.safeName -accessNoConfirmation -addEvents -administer -backup -createFolder -createObject -updateObjectProperties -store -delete -deleteFolder -eventsList -initiateCPMChange -initiateCPMChangeWithManualPassword -list -manageOwners -moveFrom -moveInto	-renameObject -retrieve -supervise -unlockObject -createObject -updateObjectProperties -updateObjectProperties -usePassword -validateSafeContent -viewAudit	-viewPermissions

}

# Cleans up vault connection
Disconnect-PVVault

# Cleans up pacli session
Stop-PVPacli