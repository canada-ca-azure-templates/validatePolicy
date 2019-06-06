#Enable-AzContextAutosave
#$creds = Get-Credential
#$job = Start-Job { param($vmadmin) New-AzVM -Name MyVm -Credential $vmadmin} -ArgumentList $creds

Get-Job | Remove-Job -Force

Start-Job -Name "resourcegroups" {
    param($path)
    Set-Location $path
    $res = & .\validate.ps1
    if (-not $res) {
        throw "Failed to validate"
    }
} -ArgumentList (Resolve-Path $PSScriptRoot\..\resourcegroups\test)

Start-Job -Name "asg" {
    param($path)
    Set-Location $path
    $res = & .\validate.ps1
    if (-not $res) {
        throw "Failed to validate"
    }
} -ArgumentList (Resolve-Path $PSScriptRoot\..\asg\test)

Start-Job -Name "dns" {
    param($path)
    Set-Location $path
    $res = & .\validate.ps1
    if (-not $res) {
        throw "Failed to validate"
    }
} -ArgumentList (Resolve-Path $PSScriptRoot\..\dns\test)

Start-Job -Name "servers" {
    param($path)
    Set-Location $path
    $res = & .\validate.ps1
    if (-not $res) {
        throw "Failed to validate"
    }
} -ArgumentList (Resolve-Path $PSScriptRoot\..\servers\test)

#Get-AzureRmMarketplaceTerms -Publisher cisco -Product cisco-asav -Name asav-azure-byol | Set-AzureRmMarketplaceTerms -Accept

Start-Job -Name "ciscoasav2nic" {
    param($path)
    Set-Location $path
    $res = & .\validate.ps1
    if (-not $res) {
        throw "Failed to validate"
    }
} -ArgumentList (Resolve-Path $PSScriptRoot\..\ciscoasav2nic\test)

#Get-AzureRmMarketplaceTerms -Publisher fortinet -Product fortinet_fortigate-vm_v5 -Name latest | Set-AzureRmMarketplaceTerms -Accept

Start-Job -Name "fortigate2nic" {
    param($path)
    Set-Location $path
    $res = & .\validate.ps1
    if (-not $res) {
        throw "Failed to validate"
    }
} -ArgumentList (Resolve-Path $PSScriptRoot\..\fortigate2nic\test)

Start-Job -Name "azurefirewall" {
    param($path)
    Set-Location $path
    $res = & .\validate.ps1
    if (-not $res) {
        throw "Failed to validate"
    }
} -ArgumentList (Resolve-Path $PSScriptRoot\..\azurefirewall\test)

#Write-Host "Waiting for parallel template validation jobs to finish..."
#Get-Job | Wait-Job

#if (Get-Job -State Failed) {
#    throw "One of the jobs was not successfully created... exiting..."
#}