## Licensing Troubleshooting Script
This PowerShell script assists in troubleshooting licensing issues for applications using FlexNet licensing. It automates the process of locating necessary files, extracting server information, and verifying connectivity related to the licensing setup.

### Table of Contents
- Prerequisites
- Usage Instructions
- What the Script Does
- Troubleshooting
- Notes

### Prerequisites
- Operating System: Windows
- Permissions: Administrative privileges may be required to access certain directories and files.
- Utilities:
    - curl command-line tool (should be available in the system PATH).
    - nslookup command-line tool (usually available by default in Windows).

### Usage Instructions
1. Open PowerShell:

    - Run PowerShell as an administrator to ensure all operations can be performed without permission issues.

2. Execute the Script:

- Navigate to the directory containing the script.
- Run the script by typing:

```powershell
.\LicensingTroubleshootingScript.ps1
```

3. Select Application Version:


    - When prompted, input 1 for version 24R1 or 2 for version 24R2.

4. Answer Licensing Questions:

- License Manager:
    - The script will ask: Are you using a license manager? (Y/N)
    - Input Y if you are using a license manager.
    - Input N if you are not using a license manager.
- Elastic License (if you answered N to the previous question):
    - The script will ask: Are you using an elastic license? (Y/N)
    - Input Y if you are using an elastic license.
    - Input N if you are not using an elastic license.

### What the Script Does
1. Version Selection:

    - Sets up environment variables based on the selected application version.

2. File Search:
    - Searches for lmutil.exe in the application's licensing client directory.
    - Searches for ansyslmd.ini in the shared licensing directory.
    - These files are necessary for license management and verification.

3. Server Information Extraction:

    - Reads the ansyslmd.ini file to find the line starting with SERVER=.
    - Extracts the server information and sets it as an environment variable SERVER_NAME.

4. License Manager Check (if applicable):

    - Executes lmstat -c <server_value> using lmutil.exe to check the license manager status.
    - Outputs the result to the console.

5. Elastic License Verification (if applicable):

    - Attempts to access a specific URL (https://laas.fnocc.com:443) using curl to verify network connectivity.
    - Uses nslookup to check DNS resolution for flex1397.flexnetoperations.com.
    - Outputs the results to the console.

### Troubleshooting
- Invalid Input:
    - If an invalid selection is made, the script will display an error message and terminate.
    - Ensure you input the correct options when prompted.

- File Not Found:
    - If lmutil.exe or ansyslmd.ini are not found, the script will display an error message.
    - Verify that the application is installed correctly and the files exist in the expected directories.

- Access Denied:
    - If the script cannot access certain files or directories, try running PowerShell as an administrator.

- Network Connectivity Issues:
    - If the script fails to access the URL or resolve the hostname, check your network connection and firewall settings.

- Missing Utilities:
    - Ensure that curl and nslookup are available in your system's PATH. Install them if necessary.

### Notes
- Environment Variables:
    - The script sets the SERVER_NAME environment variable for the current session.
    - This variable will not persist after the session ends.
- Temporary Files:
    - The script creates temporary output files in the system's TEMP directory.
    - These files are deleted after the script completes execution.
- Compatibility:
    - The script is designed for Windows systems with PowerShell.
