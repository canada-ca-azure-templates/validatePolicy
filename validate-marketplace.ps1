Param(
    [switch]$acceptTerms = $false
)

# Global variables
$templatesToValidate = "asg", "dns", "resourcegroups", "servers", "ciscoasav2nic", "fortigate2nic", "azurefirewall", "s2d"

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

# Validate that the Marketplace Policy is in place
Set-Location (Resolve-Path $PSScriptRoot\testDisallowed)
$res = & .\validate.ps1
if (-not $res) {
    throw "The Marketplace Policy does not appear to be in place... stopping..."
} else {
    Write-Host "The Marketplace Policy is in place, moving on with testing..."
}

foreach ($templateToValidate in $templatesToValidate) { 
    Start-Job -Name $templateToValidate {
        param($path)
        Set-Location $path
        $res = & .\validate.ps1
        if (-not $res) {
            throw "Failed to validate"
        }
    } -ArgumentList (Resolve-Path $PSScriptRoot\..\$templateToValidate\test)
}

#Write-Host "Waiting for parallel template validation jobs to finish..."
#Get-Job | Wait-Job

#if (Get-Job -State Failed) {
#    throw "One of the jobs was not successfully created... exiting..."
#}