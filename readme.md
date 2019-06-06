# Azure Marketplace Policy Validation

## Introduction

This repository contain script(s) used to validate that changes to the Azure Marketplace Policy is not breaking any existing templates. If existing deployment is successfull than the chances of introducing deployment issues for current users is greatly reduced. It does not provide 100% guaranty it will never happen.

## Dependancies

You need to clone every template you intend to validate against in the same folder as the one containing the "validatePolicy" folder. For example in a structure like the following:

```text
Root-Folder ---> validatePolicy
            |
            ---> asg
            |
            ---> dns
            |
            ...
            |
            ---> s2d
```

The complete list of templates can be found by name in the validate-marketplace.ps1 script.

Make sure your system can deploy using azurerm powershell modules in the Azure Subscription you target to use for the validation

## Execution

```powershell
cd validatePolicy
login-azurermaccount
select-azurermsubscription <subscription name>
.\validate-marketplace.ps1
```

The validation will take roughly an hour at the time of the writing of this readme. You can check the validation process by running the following powershell command:

```powershell
Get-Job

Id     Name            PSJobTypeName   State         HasMoreData     Location             Command
--     ----            -------------   -----         -----------     --------             -------
306    resourcegroups  BackgroundJob   Completed     True            localhost            ...
308    asg             BackgroundJob   Completed     True            localhost            ...
310    dns             BackgroundJob   Completed     True            localhost            ...
312    servers         BackgroundJob   Completed     True            localhost            ...
314    ciscoasav2nic   BackgroundJob   Completed     True            localhost            ...
316    fortigate2nic   BackgroundJob   Completed     True            localhost            ...
318    azurefirewall   BackgroundJob   Completed     True            localhost            ...
```

As can be seen in the example above the validation has completed with success (looking at the Stats column).

If the word "Failed" is listed in the state column then something did not complete properly with the validation of the template named under the "Name" column. To get the log output of why this might be run the following powershell command:

```powershell
Receive-Job <Id number>
```

For example:

```powershell
Receive-Job 308

You are working off the master branch... Validation will happen against the github master branch code and will not include any changes you may have made.
If you want to walidate changes you have made make sure to create a new branch and push those to the remote github server with something like:

git branch dev ; git checkout dev; git add ..\. ; git commit -m  Update validation ; git push -u origin dev
Starting asg dependancies deployment...
VERBOSE: 8:14:41 PM - Template is valid.
VERBOSE: 8:14:41 PM - Create template deployment 'Deploy-asg-Template-Infrastructure-Dependancies'
VERBOSE: 8:14:41 PM - Checking deployment status in 5 seconds
VERBOSE: 8:14:46 PM - Resource Microsoft.Resources/deployments 'start-bc9ed9f0-574b-4649-ac33-a34c91fb0f8e' provisioning status is running
VERBOSE: 8:14:46 PM - Checking deployment status in 5 seconds
VERBOSE: 8:14:52 PM - Resource Microsoft.Resources/deployments 'resourcegroups-asg' provisioning status is running
VERBOSE: 8:14:52 PM - Resource Microsoft.Resources/deployments 'Deploy-rg-PwS2-validate-asg-RG' provisioning status is running
VERBOSE: 8:14:52 PM - Resource Microsoft.Resources/resourceGroups 'PwS2-validate-asg-RG' provisioning status is succeeded
VERBOSE: 8:14:52 PM - Resource Microsoft.Resources/deployments 'start-bc9ed9f0-574b-4649-ac33-a34c91fb0f8e' provisioning status is succeeded
VERBOSE: 8:14:52 PM - Checking deployment status in 5 seconds
VERBOSE: 8:14:57 PM - Resource Microsoft.Resources/deployments 'Deploy-rg-PwS2-validate-asg-RG' provisioning status is succeeded
VERBOSE: 8:14:57 PM - Checking deployment status in 5 seconds
VERBOSE: 8:15:02 PM - Resource Microsoft.Resources/deployments 'resourcegroups-asg' provisioning status is succeeded
Starting asg validation deployment...
VERBOSE: Performing the operation "Creating Deployment" on target "PwS2-validate-asg-RG".
VERBOSE: 8:15:04 PM - Template is valid.
VERBOSE: 8:15:04 PM - Create template deployment 'validate-asg-template'
VERBOSE: 8:15:04 PM - Checking deployment status in 5 seconds
VERBOSE: 8:15:09 PM - Resource Microsoft.Resources/deployments 'asg-Deploy.testASG1' provisioning status is running
VERBOSE: 8:15:09 PM - Resource Microsoft.Network/applicationSecurityGroups 'testASG1' provisioning status is running
VERBOSE: 8:15:09 PM - Checking deployment status in 5 seconds
VERBOSE: 8:15:14 PM - Checking deployment status in 5 seconds
VERBOSE: 8:15:19 PM - Resource Microsoft.Network/applicationSecurityGroups 'testASG1' provisioning status is succeeded
VERBOSE: 8:15:19 PM - Checking deployment status in 5 seconds
VERBOSE: 8:15:24 PM - Resource Microsoft.Resources/deployments 'asg-Deploy.testASG1' provisioning status is succeeded
Cleanup old asg template validation resources if needed...
VERBOSE: Performing the operation "Removing resource group ..." on target "PwS2-validate-asg-RG".
Validation deployment succeeded...
```

## History

| Date     | Release                                                                               | Change                           |
| -------- | ------------------------------------------------------------------------------------- | -------------------------------- |
| 20190606 | [20190606](https://github.com/canada-ca-azure-templates/validatePolicy/tree/20190606) | 1st release of validation script |
