
$permissions = @(
"Policy.Read.All",
"Policy.ReadWrite.ConditionalAccess",
"EntitlementManagement.ReadWrite.All",
"Policy.ReadWrite.CrossTenantAccess",
    "Directory.ReadWrite.All",
    "Group.ReadWrite.All",
"Application.Read.All",
"User.ReadWrite.All",
"Organization.Read.All",
    "PrivilegedEligibilitySchedule.Read.AzureADGroup",
    "PrivilegedEligibilitySchedule.ReadWrite.AzureADGroup",
    "PrivilegedAccess.Read.AzureADGroup",
    "PrivilegedAccess.ReadWrite.AzureADGroup",
    "RoleManagement.ReadWrite.Directory",
"Policy.ReadWrite.CrossTenantAccess"
)

Connect-MgGraph -Scopes $permissions -NoWelcome -TenantId $tenantID

Write-Host "Creating group for Patriot MXDR Analysts." -ForegroundColor Green
#Creating group for Patriot MXDR Analysts
  $mxdrGroupCheck = Get-MgGroup | Where-Object {$_.DisplayName -eq "Patriot MXDR"}
  if($null -eq $mxdrGroupCheck){
$PatriotMXDRGroup = New-MgGroup -DisplayName "Patriot MXDR" -MailNickname 'PatriotMXDR' -MailEnabled:$false -SecurityEnabled -IsAssignableToRole:$true
$PatriotMXDRNewGroupCheck = "y"  
Write-Host "Created new group named Patriot MXDR" -ForegroundColor Green
  $mxdrGroupMessageCheck = "Created new group named Patriot MXDR"
  } else {
  Write-Host "Patriot MXDR Group Already Existed. Please confirm manually." -ForegroundColor Green
  $PatriotMXDRNewGroupCheck = "n"
  $mxdrGroupMessageCheck = "Patriot MXDR Group Already Existed."
  $PatriotMXDRGroup = Get-MgGroup | Where-Object {$_.DisplayName -eq "Patriot MXDR"}
  }

Write-Host "Applying necessary Responder Permissions to the Patriot MXDR Group." -ForegroundColor Green

# Assign the Role Password Administrator to the Group
try {
    New-MgRoleManagementDirectoryRoleAssignment -PrincipalId $PatriotMXDRGroup.Id -RoleDefinitionId "966707d0-3269-4727-9be2-8c3a10f19b9d" -DirectoryScopeId "/"
    Write-Host "Successfully assigned the Password Administrator role to group Patriot MXDR." -ForegroundColor Green
} catch {
    Write-Host "Failed to assign the Password Administrator role. Error: $_" -ForegroundColor Red
}

# Assign the Role Security Operator to the Group
try {
    New-MgRoleManagementDirectoryRoleAssignment -PrincipalId $PatriotMXDRGroup.Id -RoleDefinitionId "5f2222b1-57c3-48ba-8ad5-d4759f1fde6f" -DirectoryScopeId "/"
    Write-Host "Successfully assigned the Security Operator role to group Patriot MXDR." -ForegroundColor Green
} catch {
    Write-Host "Failed to assign the Security Operator role. Error: $_" -ForegroundColor Red
}

    Write-Host "Creating Access Package Catalog" -ForegroundColor Green

# Creates the Patriot SOC Catalog
$catalogCheck = Get-MgEntitlementManagementCatalog | Where-Object {$_.DisplayName -eq "Patriot Consulting Access"}

if ($null -eq $catalogCheck) {
    Write-Host "Creating Patriot SOC Catalog" -ForegroundColor Green
    $catalog = New-MgEntitlementManagementCatalog -DisplayName "Patriot Consulting Access" -Description "Patriot Consulting Access" -IsExternallyVisible

    # Checks if Catalog was created successfully
    if ($null -ne $catalog) {
        Write-Host "Catalog deployed successfully." -ForegroundColor Green
        $catalogCheckMessage = "Catalog deployed successfully."
    } else {
        Write-Host "Catalog did not deploy correctly. Please investigate manually." -ForegroundColor Red
        $catalogCheckMessage = "Catalog did not deploy correctly. Please investigate manually."
        Start-Sleep 10
		break
    }

    #Creates Parameters for SOC catalog resources
    Write-Host "Creates Parameters for SOC catalog resources." -ForegroundColor Green
    $socCatalogResourceparams = @{
        requestType = "adminAdd"
        resource = @{
            originId = $PatriotMXDRGroup.Id
            originSystem = "AadGroup"
        }
        catalog = @{ Id = $catalog.Id }
    }

    # Creates SOC catalog resources
    Write-Host "Creating Catalog Resources - SOC" -ForegroundColor Green
    $catalogSocResourceCheck = New-MgEntitlementManagementResourceRequest -BodyParameter $socCatalogResourceparams

    # Checks if SOC Catalog resources deployed correctly
    if ($null -ne $catalogSocResourceCheck) {
        Write-Host "Soc Catalog Resource deployed correctly." -ForegroundColor Green
        $catalogSocResourceCheckMessage = "Soc Catalog Resource deployed correctly."
    } else {
        Write-Host "Soc Catalog Resource did not deployed correctly. Please manually resolve." -ForegroundColor Red
        $catalogSocResourceCheckMessage = "Soc Catalog Resource did not deployed correctly. Please manually resolve."
        Start-Sleep 10
		break
    }
}

    #Checks for Patriot Consulting Connected Orginization
    Write-Host "Checking for Patriot Consulting Connected Orginization." -ForegroundColor Green
    $orgCheck | Where-Object {$_.DisplayName -eq "Patriot Consulting"}
    if($null -eq $orgCheck){
	#Creates parameters for Patriot Consulting connected organization
	Write-Host "Creating Patriot Consulting Connected Organization Parameters" -ForegroundColor Green
	$ConnectedOrganizationparams = @{
		DisplayName = "Patriot Consulting"
		description = "Patriot Consulting Access Group"
		identitySources = @(
			@{
				"@odata.type" = "#microsoft.graph.azureActiveDirectoryTenant"
				TenantId = "ab71a6ac-73bf-40a9-bec7-9ca1edfa8c92"
				DisplayName = "ab71a6ac-73bf-40a9-bec7-9ca1edfa8c92"
			}
		)
		State = "configured"
	}

	#Creates Patriot Consulting Connected Organization
	Write-Host "Creating Patriot Consulting Connected Organization" -ForegroundColor Green
	$connectedOrganization = New-MgEntitlementManagementConnectedOrganization @ConnectedOrganizationparams

	#Add a delay to make sure the catalog is created in Azure before adding access packages to it
	Start-Sleep -Seconds 15

	#Setting Parameters for SOC Access Package
	Write-Host "Setting Parameters for SOC Access Package." -ForegroundColor Green
	$socAccessPackageParams = @{
		DisplayName = "Patriot Consulting Access Package"
		description = "Patriot Consulting Access"
		isHidden = $false
		catalog = @{
			Id = "$($catalog.id)"
		}
	}

	#Creating SOC Access Packages
	Write-Host "Creates SOC Access Package." -ForegroundColor Green
	$socAccessPackage = New-MgEntitlementManagementAccessPackage -BodyParameter $socAccessPackageParams

	#Gets the Access Package Resource ID and Root ID Scopes for Access Package role assignment
	Write-Host "Gets the Access Package Resource ID and Root ID Scopes for Access Package role assignment." -ForegroundColor Green
	$socAccessPackageResourceID = (Get-MgEntitlementManagementCatalogResource -AccessPackageCatalogId $catalog.Id  | Where-Object { $_.DisplayName -eq "Patriot MXDR" }).Id
	$socRootID = (Get-MgEntitlementManagementCatalogResource -AccessPackageCatalogId $catalog.Id -ExpandProperty "scopes").Scopes | Where-Object { $_.originId -eq "$($PatriotMXDRGroup.Id)" } | Select-Object Id

#Creates Role Assignment Parameters
	Write-Host "Creates role assignment parameters for access package." -ForegroundColor Green
	$socRoleAssignment = @{
		role = @{
			DisplayName = "Member"
			originSystem = "AadGroup"
			originId = "Member_" + $PatriotMXDRGroup.Id
			resource = @{
				Id = $socAccessPackageResourceID
				DisplayName = "Patriot SOC"
				description = "Patriot SOC Group"
				originId = $PatriotMXDRGroup.Id
				originSystem = "AadGroup"
			}
		}
		Scope = @{
			Id = $socRootID.Id
			DisplayName = "Root"
			description = "Root Scope"
			originId = $PatriotMXDRGroup.Id
			originSystem = "AadGroup"
			isRootScope = $true
		}
	}

	#Creates role scope for access package
	Write-Host "Creates role scope for Access Packages." -ForegroundColor Green
	New-MgEntitlementManagementAccessPackageResourceRoleScope -AccessPackageId $socAccessPackage.Id -BodyParameter $socRoleAssignment

	#Creates Access Package Policy Parameters
	Write-Host "Creates Access package policy parameters." -ForegroundColor Green
$socAssignmentPolicy = @{
    DisplayName = "Patriot SOC"
    Description = "Patriot SOC Access"
    AllowedTargetScope = "specificConnectedOrganizationUsers"
    specificAllowedTargets = @(
		@{
		"@odata.type"= "#microsoft.graph.connectedOrganizationMembers"
        connectedOrganizationId = $connectedOrganization.Id
        description = "Patriot SOC"
		}
	)
    Expiration = @{
        EndDateTime = $null
        Duration = $null
        Type = "noExpiration"
    }
    RequestorSettings = @{
        EnableTargetsToSelfAddAccess = $true
        EnableTargetsToSelfUpdateAccess = $false
        EnableTargetsToSelfRemoveAccess = $true
        AllowCustomAssignmentSchedule = $false 
        EnableOnBehalfRequestorsToAddAccess = $false
        EnableOnBehalfRequestorsToUpdateAccess = $false
        EnableOnBehalfRequestorsToRemoveAccess = $false
        OnBehalfRequestors = @()
    }
    RequestApprovalSettings = @{
        IsApprovalRequiredForAdd = $false
        IsApprovalRequiredForUpdate = $false
        Stages = @()
    }
    AccessPackage = @{
        Id = $socAccessPackage.Id
    }
}

	#Creates Access Package Policy
	Write-Host "Creates access package policy." -ForegroundColor Green
New-MgEntitlementManagementAssignmentPolicy -BodyParameter $socAssignmentPolicy


} else {
    Write-Host "Patriot SOC Orginization already existed. Please update manually if need be." -ForegroundColor Green
    $orgCheckMessage = "Patriot SOC Orginization already existed or had an error."
}

#Adds Patriot SOC org to trusted mfa settings and configures mfa trust settings
Write-Host "Create MFA Trust Settings Parameters" -ForegroundColor Green
$crossTenantAccessSettingparams = @{
	tenantId = "ab71a6ac-73bf-40a9-bec7-9ca1edfa8c92"
	inboundTrust = @{
        isMfaAccepted = "true";
        isCompliantDeviceAccepted = "true";
        isHybridAzureADJoinedDeviceAccepted = "true"
	}
    automaticUserConsentSettings = @{
        inboundAllowed = "true"
    }
}
Write-Host "Create MFA Trust Settings" -ForegroundColor Green
New-MgPolicyCrossTenantAccessPolicyPartner -BodyParameter $crossTenantAccessSettingparams

#Checks for MFA Trust Setting Deployment
$crossTenantAccessSettingCheck = get-MgPolicyCrossTenantAccessPolicyPartner | Where-Object {$_.TenantId -eq "ab71a6ac-73bf-40a9-bec7-9ca1edfa8c92"}
if($null -eq $crossTenantAccessSettingCheck){
Write-Host "MFA Trust Settings did not deploy correctly. Please deploy manually." -ForegroundColor Red
break
} else {
	$crossTenantAccessSettingCheckMessage = "MFA Trust Settings deployed correctly"
	Write-Host "MFA Trust Settings deployed correctly" -ForegroundColor Green
}
