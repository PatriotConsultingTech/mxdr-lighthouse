<#
.SYNOPSIS
    MUST DO!!!! - MAKE SURE THE WORKSPACE YOU ARE RUNNING THIS ON HAS THE MOST UP TO DATE HUNING QUERIES AND ANALYTIC RULE FOR PROPER MATCHING
    This Version of the script has been built around Azure CloudShell. 
    Dry run: Compares only MXDR365 Sentinel Analytics Rules & Hunting Queries via REST API and exports results to CSV.

.DESCRIPTION
    - Retrieves Analytics Rules (`Get-AzSentinelAlertRule`).
    - Retrieves Hunting Queries via REST API (`savedSearches` under `Microsoft.OperationalInsights`).
    - Filters only **Analytics Rules & Hunting Queries starting with `MXDR365`**.
    - Compares and exports:
        1. Matching MXDR365 Analytics Rules & Hunting Queries (`matched_mxdr365.csv`)
        2. MXDR365 Analytics Rules missing a Hunting Query (`missing_mxdr365_hunting_queries.csv`)
#>

# --- Configuration (Update These) ---
$subscriptionId     = "32e993b8-ebcd-4bca-98e7-23b6d3639b38"
$resourceGroupName  = Read-Host "Enter the Resource Group Name"
$workspaceName      = Read-Host "Enter the Workspace Name"
$apiVersion        = "2020-03-01-preview"

# --- Define Cloud Shell File Paths ---
$cloudShellPath = (Get-Location).Path
$matchedCsvPath = "$cloudShellPath/matched_mxdr365.csv"
$missingHuntingCsvPath = "$cloudShellPath/missing_mxdr365_hunting_queries.csv"

# --- Connect to Azure (Uncomment If Needed) ---
Connect-AzAccount -UseDeviceAuthentication  
 
# Check if Az.SecurityInsights module is installed
if (-not (Get-Module -ListAvailable -Name Az.SecurityInsights)) {
    Write-Host "Az.SecurityInsights module not found. Installing..."
    Install-Module Az.SecurityInsights -Scope CurrentUser -Force
} else {
    Write-Host "Az.SecurityInsights module is already installed."
}

# Import the module if it's not already loaded
if (-not (Get-Module -Name Az.SecurityInsights)) {
    Import-Module Az.SecurityInsights
    Write-Host "Az.SecurityInsights module imported."
} else {
    Write-Host "Az.SecurityInsights module already imported."
}

Write-Host "=== DRY RUN: Comparing MXDR365 Sentinel Analytics Rules & Hunting Queries ==="
Write-Host "Subscription: $subscriptionId"
Write-Host "Resource Group: $resourceGroupName"
Write-Host "Workspace: $workspaceName"
Write-Host "--------------------------------------------------------------`n"

Select-AzSubscription -SubscriptionId $subscriptionId

# -------------------------------------------------------------------------
# Step 1: Retrieve Analytics Rules
# -------------------------------------------------------------------------
Write-Host "Retrieving all Analytics Rules..."
$analyticsRules = Get-AzSentinelAlertRule `
    -ResourceGroupName $resourceGroupName `
    -WorkspaceName $workspaceName

$analyticsRuleNames = @{}
$analyticsRuleData = @()

foreach ($rule in $analyticsRules) {
    if ($rule.DisplayName -match "^MXDR365") {
        $analyticsRuleNames[$rule.DisplayName] = $true
        $analyticsRuleData += [PSCustomObject]@{
            Name = $rule.DisplayName
            Severity = $rule.Severity
            Enabled = $rule.Enabled
        }
    }
}

Write-Host "✅ Retrieved $($analyticsRuleNames.Count) MXDR365 Analytics Rules.`n"

# -------------------------------------------------------------------------
# Step 2: Retrieve Hunting Queries via REST API
# -------------------------------------------------------------------------
Write-Host "Retrieving all MXDR365 Hunting Queries via REST API..."

# API Endpoint to get all Hunting Queries (saved searches)
$uri = "https://management.azure.com/subscriptions/$subscriptionId/resourceGroups/$resourceGroupName/providers/Microsoft.OperationalInsights/workspaces/$workspaceName/savedSearches?api-version=$apiVersion"

# Call REST API
$response = Invoke-AzRestMethod -Method GET -Uri $uri

# Convert JSON response to PowerShell object
$huntingQueries = ($response.Content | ConvertFrom-Json).value

$huntingQueryNames = @{}
$huntingQueryData = @()

foreach ($query in $huntingQueries) {
    if ($query.properties.displayName -match "^MXDR365") {
        $huntingQueryNames[$query.properties.displayName] = $true
        $huntingQueryData += [PSCustomObject]@{
            Name = $query.properties.displayName
            Category = $query.properties.Category
        }
    }
}

Write-Host "✅ Retrieved $($huntingQueryNames.Count) MXDR365 Hunting Queries via REST API.`n"

# -------------------------------------------------------------------------
# Step 3: Compare MXDR365 Analytics Rules & Hunting Queries
# -------------------------------------------------------------------------

# Find MXDR365 rules that do NOT have a matching hunting query
$missingHuntingQueries = $analyticsRuleNames.Keys | Where-Object { -not $huntingQueryNames.ContainsKey($_) }

# Find MXDR365 matches (rules that exist in both lists)
$matchedRules = $analyticsRuleNames.Keys | Where-Object { $huntingQueryNames.ContainsKey($_) }

# Export Missing MXDR365 Hunting Queries to CSV
$missingHuntingQueriesData = $missingHuntingQueries | ForEach-Object { [PSCustomObject]@{ Name = $_ } }
$missingHuntingQueriesData | Export-Csv -Path $missingHuntingCsvPath -NoTypeInformation

# Export Matched MXDR365 Rules & Queries to CSV
$matchedRulesData = $matchedRules | ForEach-Object { [PSCustomObject]@{ Name = $_ } }
$matchedRulesData | Export-Csv -Path $matchedCsvPath -NoTypeInformation

# -------------------------------------------------------------------------
# Step 4: Display the Comparison Results
# -------------------------------------------------------------------------

Write-Host "=== COMPARISON REPORT ===`n"

if ($missingHuntingQueries.Count -eq 0) {
    Write-Host "✅ All MXDR365 Analytics Rules have corresponding Hunting Queries."
} else {
    Write-Host "⚠️ MXDR365 Analytics Rules WITHOUT corresponding Hunting Queries:"
    $missingHuntingQueries | ForEach-Object { Write-Host "   - $_" }
}

Write-Host "`nComparison complete. Results exported to CSV files in Cloud Shell:`n"
Write-Host "📂 $matchedCsvPath"
Write-Host "📂 $missingHuntingCsvPath"
