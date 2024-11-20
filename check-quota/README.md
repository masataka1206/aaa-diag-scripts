# Azure Quota Checker Script

## Overview
This repository contains a PowerShell script designed to check the available quotas for specific Azure VM instance types in a given region. The script interacts with Azure CLI to provide a summary of usage and limits for instance types such as `HB`, and `HC` series.

## Prerequisites

Before running the script, ensure the following prerequisites are met:

- **Azure CLI** is installed on your local machine. You can install it from [Azure CLI Installation Guide](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli).
- You have **logged in to Azure CLI** using the command:
  ```powershell
  az login
  ```
  This script requires you to be logged in to Azure to access subscription information.

## Script Description
The PowerShell script performs the following operations:

1. **Error Handling**: If any command fails, the script exits with an error message.
2. **Azure Region Input**: Prompts the user to specify the Azure region.
3. **Login Verification**: Checks if the Azure CLI is logged in, prompting the user if not.
4. **Quota Filtering**: Retrieves and displays VM usage filtered by specific quota names (`Standard`, `HB`, `HC`).

### PowerShell Script

```powershell
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
$additionalFilters = @("HB", "HC", "Esv", "Fsv", "Dsv3", "Ebds")

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
```

## Usage

1. **Clone the Repository**: Clone this repository to your local machine:
   ```sh
   git clone <repository-url>
   ```

2. **Run the Script**: Open a PowerShell terminal and navigate to the script's directory. Run the script using:
   ```powershell
   .\check_azure_quota.ps1
   ```

3. **Enter Region**: When prompted, enter the Azure region you want to check (e.g., `japaneast`).

You can check your region name using the following command. 

```powershell
az account list-locations -o table
```

Check the "name" column.

```
DisplayName               Name                 RegionalDisplayName
------------------------  -------------------  -------------------------------------
East US                   eastus               (US) East US
South Central US          southcentralus       (US) South Central US
West US 2                 westus2              (US) West US 2
West US 3                 westus3              (US) West US 3
Australia East            australiaeast        (Asia Pacific) Australia East
Southeast Asia            southeastasia        (Asia Pacific) Southeast Asia
North Europe              northeurope          (Europe) North Europe
```


## Example Output

The script will output the **Service Quota Name**, **Current Value**, and **Limit** for each relevant quota in the specified region in a table format.

Example:

```
Service Quota Name          Current Value    Limit
-------------------------  --------------   -----
Standard DSv3 Family       10               20
HBv2 Series                5                10
```

## Error Handling
The script is designed to exit with an appropriate message if:
- The Azure CLI is not installed.
- The user is not logged in.
- Any command fails during execution.

## Contributions
Feel free to fork this repository and create a pull request if you'd like to contribute or improve the script.

## License
This project is licensed under the MIT License.

