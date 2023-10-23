Disable-AzContextAutosave -Scope Process

$AzureContext = (Connect-AzAccount -Identity -Environment AzureUSGovernment -AccountId ${umi}).context
$TenantId = '${tenantid}'
$scriptNameLinux = '${scriptnamelinux}'
$scriptNameWindows = '${scriptnamewindows}'
$storageAccountContainer = '${storageaccountcontainer}'
$storageAccountResourceGroup = '${storageaccountresourcegroup}'
$storageAccountName = '${storageaccountname}'
$defaultSubscriptionId = '${defaultsub}'

$settingsLinux = @{
    "fileUris"         = @("https://$storageAccountName.blob.core.usgovcloudapi.net/$storageAccountContainer/$scriptNameLinux")
    "commandToExecute" = "bash $scriptNameLinux"
} | ConvertTo-Json

$settingsWindows = @{
    "fileUris"         = @("https://$storageAccountName.blob.core.usgovcloudapi.net/$storageAccountContainer/$scriptNameWindows")
    "commandToExecute" = "powershell -NonInteractive -ExecutionPolicy Unrestricted -File $scriptNameWindows"
} | ConvertTo-Json

$storageKey = (Get-AzStorageAccountKey -Name $storageAccountName -ResourceGroupName $storageAccountResourceGroup)[0].Value

$protectedSettingsLinux = @{
    "storageAccountName" = $storageAccountName
    "storageAccountKey"  = $storageKey
} | ConvertTo-Json

$protectedSettingsWindows = @{
    "storageAccountName" = $storageAccountName
    "storageAccountKey"  = $storageKey
} | ConvertTo-Json

$currentAZContext = Get-AzContext

if ($currentAZContext.Tenant.id -ne $TenantId) {
    Write-Output "This script is not authenticated to the needed tenant. Running authentication."
    Connect-AzAccount -TenantId $TenantId
}
else {
    Write-Output "This script is already authenticated to the needed tenant - reusing authentication."
}

$subs = @()

if ($defaultSubscriptionId -eq "") {
    $subs = Get-AzSubscription -TenantId $TenantId | Where-Object { $_.State -eq "Enabled" }
}
else {
    if ($defaultSubscriptionId.IndexOf(',') -eq -1) {
        $subs = Get-AzSubscription -TenantId $TenantId -SubscriptionId $defaultSubscriptionId
    }
    else {
        $defaultSubscriptionId = $defaultSubscriptionId -replace '\s', ''
        $subsArray = $defaultSubscriptionId -split ","
        foreach ($subsArrayElement in $subsArray) {
            $currTempSub = Get-AzSubscription -TenantId $TenantId -SubscriptionId $subsArrayElement
            $subs += $currTempSub
        }
    }
}



$excludeVmNamesArray = (${vms_to_exclude})


foreach ($currSub in $subs) {
    Set-AzContext -subscriptionId $currSub.id -Tenant $TenantId

    if (!$?) {
        Write-Output "Error occurred during Set-AzContext. Error message: $( $error[0].Exception.InnerException.Message )"
        Write-Output "Trying to disconnect and reconnect."
        Disconnect-AzAccount
        Connect-AzAccount -TenantId $TenantId -SubscriptionId $currSub.id
        Set-AzContext -subscriptionId $currSub.id -Tenant $TenantId
    }

    $VMs = Get-AzVM

    foreach ($vm in $VMs) {
        if ($excludeVmNamesArray -contains $vm.Name) {
            Write-Output "Skipping VM $($vm.Name) as it is excluded."
            continue
        }

        $status = (Get-AzVM -ResourceGroupName $vm.ResourceGroupName -Name $vm.Name -Status).Statuses[1].DisplayStatus

        if ($status -eq "VM running") {
            Write-Output "Processing running VM $( $vm.Name )"

            $extensions = (Get-AzVM -ResourceGroupName $vm.ResourceGroupName -Name $vm.Name).Extensions

            foreach ($ext in $extensions) {
                if ($null -ne $vm.OSProfile.WindowsConfiguration) {
                    if ($ext.VirtualMachineExtensionType -eq "CustomScriptExtension") {
                        Write-Output "Removing CustomScriptExtension with name $( $ext.Name ) from VM $( $vm.Name )"
                        Remove-AzVMExtension -ResourceGroupName $vm.ResourceGroupName -VMName $vm.Name -Name $ext.Name -Force
                        Write-Output "Removed CustomScriptExtension with name $( $ext.Name ) from VM $( $vm.Name )"
                    }
                }
                else {
                    if ($ext.VirtualMachineExtensionType -eq "CustomScript") {
                        Write-Output "Removing CustomScript extension with name $( $ext.Name ) from VM $( $vm.Name )"
                        Remove-AzVMExtension -ResourceGroupName $vm.ResourceGroupName -VMName $vm.Name -Name $ext.Name -Force
                        Write-Output "Removed CustomScript extension with name $( $ext.Name ) from VM $( $vm.Name )"
                    }
                }
            }

            if ($vm.StorageProfile.OsDisk.OsType -eq "Windows") {
                Write-Output "Windows VM detected: $( $vm.Name )"
                $settingsOS = $settingsWindows
                $protectedSettingsOS = $protectedSettingsWindows
                $publisher = "Microsoft.Compute"
                $extensionType = "CustomScriptExtension"
                $typeHandlerVersion = "1.10"
            }
            elseif ($vm.StorageProfile.OsDisk.OsType -eq "Linux") {
                Write-Output "Linux VM detected: $( $vm.Name )"
                $settingsOS = $settingsLinux
                $protectedSettingsOS = $protectedSettingsLinux
                $publisher = "Microsoft.Azure.Extensions"
                $extensionType = "CustomScript"
                $typeHandlerVersion = "2.1"
            }
            $customScriptExtensionName = "NessusInstall"

            Write-Output "$customScriptExtensionName installation on VM $( $vm.Name )"

            Set-AzVMExtension -ResourceGroupName $vm.ResourceGroupName `
                -Location $vm.Location `
                -VMName $vm.Name `
                -Name $customScriptExtensionName `
                -Publisher $publisher `
                -ExtensionType $extensionType `
                -TypeHandlerVersion $typeHandlerVersion `
                -SettingString $settingsOS `
                -ProtectedSettingString $protectedSettingsOS

            Write-Output "---------------------------"
        }
        else {
            Write-Output "VM $( $vm.Name ) is not running, skipping..."
        }
    }

    Set-AzContext -SubscriptionId $defaultSubscriptionId -Tenant $TenantId
}
