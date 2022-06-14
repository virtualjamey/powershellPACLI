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
$usersToUpdate = Import-Csv -Path "$PSScriptRoot\usersToUpdate.csv"

# Starts a pacli session
Start-PVPacli -sessionID 5

# Defines the vault the xeipt will be run against
New-PVVaultDefinition -vault "Dev" -address "IP Address"

# Connects to vault using supplied credentials
Connect-PVVault -user $($creds.Username) -password $($creds.Password)

# Loops through each safe in $safesToAdd variable.
foreach($user in $usersToUpdate){

    <#
    The type of authentication by which the User will log on to the Vault. Specify one of the following:
    PA_AUTH – Password authentication. This is the default.
    PKI_AUTH – PKI authentication. This requires a valid certfilename parameter.
    ADIUS_AUTH – Radius authentication. This does not require any other additional parameters.
    LDAP_AUTH – LDAP authentication.
    #>

   Set-PVUser -destUser $user.username -authType LDAP_AUTH

}

# Cleans up vault connection
Disconnect-PVVault

# Cleans up pacli session
Stop-PVPacli