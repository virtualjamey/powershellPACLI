# Adding accounts via pacli requires the platformID and platform devicetype. These can be found by editing the desired platform via the pvwa and noting the properties

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
$accountsToAdd = Import-Csv -Path "$PSScriptRoot\accountsToAdd.csv"

# Starts a pacli session
Start-PVPacli -sessionID 5

# Defines the vault the xeipt will be run against
New-PVVaultDefinition -vault "Dev" -address "IP Address"

# Connects to vault using supplied credentials
Connect-PVVault -user $($creds.Username) -password $($creds.Password)

# Loops through each safe in $accountsToAdd variable.
foreach($account in $accountsToAdd){

    # Opens safe to add accounts
    Open-PVSafe -safe $($account.safeName)

    # Creates an objectname for account based on file categories
    $objectName = "$($account.deviceType)-$($account.platformID)-$($account.address)-$($account.userName)"

    # Converts string password to acceptable format for Add-PVPasswordObject
    $password = ConvertTo-SecureString -String $account.password -AsPlainText -Force

    # Adds account to CyberArk 
    Add-PVPasswordObject -safe $($account.safeName) -folder Root -file $($objectName) -password $password -ErrorAction SilentlyContinue

    # Adds required file categories
    Add-PVFileCategory -safe $($account.safeName) -folder Root -file $($objectName) -category Username -value $($account.userName) -ErrorAction SilentlyContinue

    # Adds required file categories
    Add-PVFileCategory -safe $($account.safeName) -folder Root -file $($objectName) -category DeviceType -value $($account.deviceType) -ErrorAction SilentlyContinue
    
    # Adds required file categories
    Add-PVFileCategory -safe $($account.safeName) -folder Root -file $($objectName) -category PolicyID -value $($account.platformID) -ErrorAction SilentlyContinue
    
    # Adds required file categories
    Add-PVFileCategory -safe $($account.safeName) -folder Root -file $($objectName) -category Address -value $($account.address) -ErrorAction SilentlyContinue
    
    # Adds required file categories
    Add-PVFileCategory -safe $($account.safeName) -folder Root -file $($objectName) -category CreationMethod -value PACLI -ErrorAction SilentlyContinue

    # Writes address and username to screen for reference
    Write-Host "Accounts have been added if no error was encoutered." -ForegroundColor Green

}

# Cleans up vault connection
Disconnect-PVVault

# Cleans up pacli session
Stop-PVPacli