## README for Domain Connectivity Check Scripts

### Overview
check_domains_win.ps1 and check_domains_lin.sh are PowerShell and Bash scripts, respectively, designed to verify network connectivity to specific domains over HTTPS (Port 443). These scripts are useful for confirming whether certain domains are accessible from your network, which can help troubleshoot connectivity issues.

### Scripts
#### 1. check_domains_win.ps1
**Description**
This PowerShell script checks the connectivity to a predefined list of domains by attempting to establish a TCP connection on Port 443. The result of each connection attempt (Success or Failed) is displayed in the console.

**Prerequisites**
Windows OS with PowerShell 5.0 or later
Network connectivity and permissions to access the specified domains
Administrator privileges may be required for full functionality

**Usage**
1. Upload the script to the Windows VM
2. Open PowerShell with necessary permissions.
3. Run the script:

```
.\check_domains_win.ps1
```

3. The script outputs a "Success" message for each reachable domain and a "Failed" message for unreachable domains, along with an error description.

**Code Breakdown**
- $urls: Defines the list of domains to check.
- Test-NetConnection: PowerShell cmdlet used to test connectivity to each domain.
- Write-Output: Prints the result of each connection attempt to the console.

#### 2. check_domains_lin.sh
**Description**
This Bash script checks the connectivity to a predefined list of domains over Port 443 using the nc (netcat) command. It outputs the status of each connection attempt to the console, indicating success or failure.

**Prerequisites**
- Linux OS or a compatible Unix-like environment with Bash support
- `nc` (netcat) command installed
- Network connectivity and permissions to access the specified domains

**Usage**
1. Open a terminal with necessary permissions.
2. Make the script executable (if not already):

```bash
chmod +x check_domains_lin.sh
```

3. Run the script:

```bash
./check_domains_lin.sh
```

4. The script outputs "Success" for each reachable domain and "Failed" for unreachable domains.

**Code Breakdown**
- `hosts`: Defines the list of domains to check.
- `nc -z -w 5`: `nc` command to test connectivity on Port 443 with a 5-second timeout.
- `if [ $? -eq 0 ]`: Evaluates the exit code from nc to determine success or failure.

--

**Customization**
To modify the list of domains to be checked:

- PowerShell script: Edit the $urls array.
- Bash script: Edit the hosts array.

To test a different port, update the `port` variable in each script.

#### Notes
- Ensure that necessary network permissions are in place for accurate results.
- Adjustments may be necessary for environments with firewall restrictions or proxy settings.
- For troubleshooting issues with specific domains, additional network diagnostic tools may be required.
