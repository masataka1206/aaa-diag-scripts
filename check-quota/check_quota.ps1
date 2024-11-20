# Define a function to handle errors
function Stop-Error {
    Write-Host "An error occurred. Exiting."
    exit 1
}

# Ensure script exits on any command failure
$ErrorActionPreference = "Stop"

# Prompt for Azure region input
$REGION = Read-Host "Enter Azure region"

# Verify that Azure CLI is logged in
try {
    az account show > $null
} catch {
    Write-Host "Please log in to Azure using 'Connect-AzAccount'"
    exit 1
}

# Define the filter for quota names
$requiredFilter = "Standard"
$additionalFilters = @("HB", "HC", "Esv", "Fsv", "Dsv3", "Ebds", "NV", "NC", "HX")

# Fetch and display VM usage filtered by relevant quota names
try {
    # Get usage information from Azure CLI
    $usagesJson = az vm list-usage --location $REGION
    if (-not $usagesJson) {
        Write-Host "No data returned from Azure CLI."
        exit 1
    }

    # Convert JSON to PowerShell objects
    $usages = $usagesJson | ConvertFrom-Json
    if (-not $usages) {
        Write-Host "Failed to convert usage data to PowerShell objects."
        exit 1
    }

    # First filter: Apply the "Standard" filter
    $filteredUsages = $usages | Where-Object {
        $_.name.value -like "*$requiredFilter*"
    }

    if (-not $filteredUsages) {
        Write-Host "No matching usage data found for the 'Standard' filter."
        exit 1
    }

    # Further filter the results to ensure they also match any of the additional filters
    $furtherFilteredUsages = $filteredUsages | Where-Object {
        $match = $false
        foreach ($filter in $additionalFilters) {
            if ($_.name.value -like "*$filter*") {
                $match = $true
                break
            }
        }
        $match
    }

    if (-not $furtherFilteredUsages) {
        Write-Host "No matching usage data found after applying additional filters."
        exit 1
    }

    # Display further filtered usage data
    Write-Host "Filtered usage data:" -ForegroundColor Green
    $furtherFilteredUsages | Select-Object @{Name="QuotaName";Expression={$_.name.value}}, CurrentValue, Limit | Format-Table
} catch {
    Stop-Error
}
