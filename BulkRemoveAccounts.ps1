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
$accountsToRemove = Import-Csv -Path "$PSScriptRoot\accountsToRemove.csv"

# Starts a pacli session
Start-PVPacli -sessionID 5

# Defines the vault the script will be run against
New-PVVaultDefinition -vault "Dev" -address "IP Address"

# Connects to vault using supplied credentials
Connect-PVVault -user $($creds.Username) -password $($creds.Password)

# Loops through each account in $accountsToRemove variable.
foreach($account in $accountsToRemove){

    # Opens safe to remove accounts
    Open-PVSafe -safe $($account.safeName)

    # Removes accounts by name
    Remove-PVFile -safe $account.safeName -folder root -file $account.accountName

    # Writes output to the screen indicating the script is complete
    Write-Host "Accounts have been removed if no error was encoutered." -ForegroundColor Green

}

# Cleans up vault connection
Disconnect-PVVault

# Cleans up pacli session
Stop-PVPacli