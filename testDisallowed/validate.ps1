Param(
    [Parameter(Mandatory = $false)][string]$templateLibraryName = "disallowed",
    [string]$Location = "canadacentral",
    [string]$subscription = "",
    [switch]$devopsCICD = $false,
    [switch]$doNotCleanup = $false,
    [switch]$doNotDeployPreReq = $false
)

#******************************************************************************
# Script body
# Execution begins here
#******************************************************************************

function getValidationURL {
    $remoteURL = git config --get remote.origin.url
    $currentBranch = git rev-parse --abbrev-ref HEAD
    $remoteURLnogit = $remoteURL -replace '\.git', ''
    $remoteURLRAW = $remoteURLnogit -replace 'github.com', 'raw.githubusercontent.com'
    $validateURL = $remoteURLRAW + '/' + $currentBranch + '/template/azuredeploy.json'
    return $validateURL
}

function getBaseParametersURL {
    $remoteURL = git config --get remote.origin.url
    $currentBranch = git rev-parse --abbrev-ref HEAD
    $remoteURLnogit = $remoteURL -replace '\.git', ''
    $remoteURLRAW = $remoteURLnogit -replace 'github.com', 'raw.githubusercontent.com'
    $baseParametersURL = $remoteURLRAW + '/' + $currentBranch + '/testDisallowed/parameters/'
    return $baseParametersURL
}

$validationURL = "https://raw.githubusercontent.com/canada-ca-azure-templates/servers/20190603/template/azuredeploy.json"
$baseParametersURL = getBaseParametersURL

if (-not $devopsCICD) {
    $currentBranch = git rev-parse --abbrev-ref HEAD

    if ($currentBranch -eq 'master') {
        Write-Host "You are working off the master branch... Validation will happen against the github master branch code and will not include any changes you may have made."
        Write-Host "If you want to walidate changes you have made make sure to create a new branch and push those to the remote github server with something like:"
        Write-Host ""
        Write-Host "git branch dev ; git checkout dev; git add ..\. ; git commit -m "Update validation" ; git push -u origin dev"
    }
    else {
        # Make sure we update code to git
        # git branch dev ; git checkout dev ; git pull origin dev
        git add ..\. ; git commit -m "Update validation" ; git push -u origin $currentBranch
    }
}

if ($subscription -ne "") {
    Select-AzureRmSubscription -Subscription $subscription
}

# Cleanup validation resource content in case it did not properly completed and left over components are still lingeringcd
if (-not $doNotCleanup) {
    #check for existing resource group
    $resourceGroup = Get-AzureRmResourceGroup -Name PwS2-validate-$templateLibraryName-RG -ErrorAction SilentlyContinue

    if ($resourceGroup) {
        Write-Host "Cleanup old $templateLibraryName template validation resources if needed..."

        Remove-AzureRmResourceGroup -Name PwS2-validate-$templateLibraryName-RG -Verbose -Force
    }
}

if (-not $doNotDeployPreReq) {
    # Start the deployment
    Write-Host "Starting $templateLibraryName dependancies deployment...";

    New-AzureRmDeployment -Location $Location -Name "Deploy-$templateLibraryName-Template-Infrastructure-Dependancies" -TemplateUri "https://raw.githubusercontent.com/canada-ca-azure-templates/masterdeploy/20190605/template/masterdeploysub.json" -TemplateParameterFile (Resolve-Path -Path "$PSScriptRoot\parameters\masterdeploysub.parameters.json") -baseParametersURL $baseParametersURL -Verbose;

    $provisionningState = (Get-AzureRmDeployment -Name "Deploy-$templateLibraryName-Template-Infrastructure-Dependancies").ProvisioningState

    if ($provisionningState -eq "Failed") {
        Write-Host "One of the jobs was not successfully created... exiting..."
    
        if (-not $doNotCleanup) {
            #check for existing resource group
            $resourceGroup = Get-AzureRmResourceGroup -Name PwS2-validate-$templateLibraryName-RG -ErrorAction SilentlyContinue
    
            if ($resourceGroup) {
                Write-Host "Cleanup old $templateLibraryName template validation resources if needed..."
    
                Remove-AzureRmResourceGroup -Name PwS2-validate-$templateLibraryName-RG -Verbose -Force
            }
        }

        throw "Dependancies deployment failed..."
    }
}

# Validating server template
Write-Host "Starting $templateLibraryName validation deployment...";

New-AzureRmResourceGroupDeployment -ResourceGroupName PwS2-validate-$templateLibraryName-RG -Name "validate-$templateLibraryName-template" -TemplateUri $validationURL -TemplateParameterFile (Resolve-Path "$PSScriptRoot\parameters\validate.parameters.json") -Verbose -ErrorVariable $outPut

$provisionningStateValidation = (Get-AzureRmResourceGroupDeployment -ResourceGroupName PwS2-validate-$templateLibraryName-RG -Name "validate-$templateLibraryName-template").ProvisioningState

if (-not $doNotCleanup) {disallowed marketplace deployment
    #check for existing resource group
    $resourceGroup = Get-AzureRmResourceGroup -Name PwS2-validate-$templateLibraryName-RG -ErrorAction SilentlyContinue

    if ($resourceGroup) {
        Write-Host "Cleanup old $templateLibraryName template validation resources if needed..."

        Remove-AzureRmResourceGroup -Name PwS2-validate-$templateLibraryName-RG -Verbose -Force
    }
}

Write-Host ""
Write-Host $outPut
Write-Host ""

if ($provisionningStateValidation -eq "Success") {
    throw "Validation of disallowed marketplace deployment failed... The marketplace item deployed when it should not have been the case"
}
else {
    Write-Host  "Validation of disallowed marketplace deployment succeeded... The item could not be deployed"
}