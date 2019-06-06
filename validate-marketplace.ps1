Param(
    [switch]$acceptTerms = $false,
    [switch]$doNotTestDisallowed = $false
)

# Global variables
$templatesToValidate = "asg", "availabilityset", "azurefirewall", "ciscoasav2nic", "ciscoasav4nic", "devtestlab", "dns", "fortigate2nic", "fortigate4nic", "keyvaults", "loadbalancers", "loganalytics", "nsg", "resourcegroups", "routes", "servers", "storage", "vnet-peering", "vnet-subnet"

# sign in
if ([string]::IsNullOrEmpty($(Get-AzureRmContext).Account)) {
    Write-Host "You need to login. Minimize the Visual Studio Code and login to the window that poped-up"
    Login-AzureRmAccount
}

# Cleanup jobs to start fresh
Get-Job | Remove-Job -Force

if ($acceptTerms) {
    Get-AzureRmMarketplaceTerms -Publisher cisco -Product cisco-asav -Name asav-azure-byol | Set-AzureRmMarketplaceTerms -Accept
    Get-AzureRmMarketplaceTerms -Publisher fortinet -Product fortinet_fortigate-vm_v5 -Name latest | Set-AzureRmMarketplaceTerms -Accept
    Get-AzureRmMarketplaceTerms -Publisher bitnami -Product elastic-search -Name latest | Set-AzureRmMarketplaceTerms -Accept
}

if (!$doNotTestDisallowed) {
    # Validate that the Marketplace Policy is in place
    Set-Location (Resolve-Path $PSScriptRoot\testDisallowed)
    $res = & .\validate.ps1
    if (-not $res) {
        throw "The Marketplace Policy does not appear to be in place... stopping..."
    }
    else {
        Write-Host "The Marketplace Policy is in place, moving on with testing..."
    }

    Set-Location $PSScriptRoot
}

foreach ($templateToValidate in $templatesToValidate) {
    if (!(Test-Path (Resolve-Path $PSScriptRoot\..\$templateToValidate) -PathType Container)) {
        git clone https://github.com/canada-ca-azure-templates/$templatesToValidate.git (Resolve-Path $PSScriptRoot\..)
    }

    Start-Job -Name $templateToValidate {
        param($path)
        Set-Location $path
        $res = & .\validate.ps1
        if (-not $res) {
            throw "Failed to validate"
        }
    } -ArgumentList (Resolve-Path $PSScriptRoot\..\$templateToValidate\test)
}