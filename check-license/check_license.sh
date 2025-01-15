#!/bin/bash

#####################################
# 1) Let the user select a version
#####################################
echo -e "\e[32mPlease select the version:\e[0m"
echo "[1] 24R1"
echo "[2] 24R2"

read -p "Input your selection [1 or 2]: " choice
case "$choice" in
    1)
        version="24R1"
        app="v241"
        ;;
    2)
        version="24R2"
        app="v242"
        ;;
    *)
        echo -e "\e[31mInvalid input, script terminated.\e[0m"
        exit 1
        ;;
esac

#####################################
# 1.5) Storage path selection
#####################################
echo -e "\e[32mSelect the storage path for the install:\e[0m"
echo "[1] Local"
echo "[2] Shared storage"

read -p "Choose [1 or 2]: " storageChoice


#####################################
# 2) Parameter settings
#####################################
fileName="lmutil"
licFileName="ansyslmd.ini"

#####################################
# 3) Decide search paths based on the storage choice
#####################################
#   - If [1] Local => search under "/ansys_inc"
#   - If [2] Shared => search under "/mnt" (the original behavior)
#####################################

case "$storageChoice" in
    1)  # Local
        appSearchDir="/ansys_inc"
        appSearchPath="/ansys_inc/${app}/licensingclient/linx64/*${fileName}"
        licSearchPath="/ansys_inc/Shared Files/licensing/*${licFileName}"
        ;;
    2)  # Shared storage (original behavior)
        appSearchDir="/mnt"
        appSearchPath="*${app}/licensingclient/linx64/*${fileName}"
        licSearchPath="*/Shared Files/licensing/*${licFileName}"
        ;;
    *)
        echo -e "\e[31mInvalid storage selection, script terminated.\e[0m"
        exit 1
        ;;
esac

#####################################
# 4) Search for the application file (stop when the first one is found)
#####################################
targetPath=$(
  find "$appSearchDir" \
    -maxdepth 6 \
    -type f \
    -path "$appSearchPath" \
    -print -quit 2>/dev/null
)

if [ -n "$targetPath" ]; then
    echo -e "\e[32mApplication file found:\e[0m $targetPath"
else
    echo -e "\e[31mError: No files found matching the pattern.\e[0m"
    exit 1
fi

#####################################
# 5) Search for the license file (stop when the first one is found)
#####################################
lictargetPath=$(
  find "$appSearchDir" \
    -maxdepth 5 \
    -type f \
    -path "$licSearchPath" \
    -print -quit 2>/dev/null
)

if [ -n "$lictargetPath" ]; then
    echo -e "\e[32mLicense file found:\e[0m $lictargetPath"
else
    echo -e "\e[31mError: No files found matching the pattern.\e[0m"
    exit 1
fi

#####################################
# 6) Obtain the value of SERVER= from the license file
#####################################
if [ -f "$lictargetPath" ]; then
 # Extract only the first line that matches SERVER=
    serverValue=$(grep -m 1 -E '^SERVER=' "$lictargetPath" | sed 's/^SERVER=//')
    if [ -n "$serverValue" ]; then
        export SERVER_NAME="$serverValue"
        echo -e "\e[32mSERVER= '$serverValue' was set to SERVER_NAME.\e[0m"
    else
        echo -e "\e[31mSERVER= not found in the license file.\e[0m"
    fi
else
    echo -e "\e[31mCannot find the file you specified. Please check the path.\e[0m"
    exit 1
fi

#####################################
# 7) Temporary files for standard output/error
#####################################
outputFile="/tmp/output.txt"
errorFile="/tmp/error.txt"

#####################################
# 8) URL / Hostname for elastic license check
#####################################
url="https://laas.fnocc.com:443"
hostname="flex1397.flexnetoperations.com"

#####################################
# 9) Check if License Manager is used
#####################################
read -p "Are you using a license manager? (Y/N): " firstAnswer
if [ "$firstAnswer" = "Y" ]; then
    # Check the status of the license
    "$targetPath" lmstat -c "$serverValue" >"$outputFile" 2>"$errorFile"
    output=$(<"$outputFile")
    errorOutput=$(<"$errorFile")
    
    echo -e "\e[32mStandard Output:\e[0m"
    echo "$output"
    
    echo -e "\e[31mStandard Error:\e[0m"
    echo "$errorOutput"
    
    rm -f "$outputFile" "$errorFile"

elif [ "$firstAnswer" = "N" ]; then
    # Check whether an elastic license is used
    read -p "Are you using an elastic license? (Y/N): " secondAnswer
    if [ "$secondAnswer" = "Y" ]; then
        # Verify the connection to the URL using curl
        echo "Accessing $url using curl..."
        curl "$url" >"$outputFile" 2>"$errorFile"
        
        if grep -q "Could not resolve host" "$errorFile"; then
            echo "Error: Access to $url failed."
        else
            echo "Successfully accessed $url."
        fi
        
        # Verify name resolution with nslookup
        echo "Checking name resolution with nslookup..."
        nslookup "$hostname" >"$outputFile" 2>"$errorFile"
        
        if grep -Eq "([0-9]{1,3}\.){3}[0-9]{1,3}" "$outputFile"; then
            echo "Name resolution of $hostname succeeded."
        else
            echo "Error: Name resolution failed for $hostname."
        fi
        
        rm -f "$outputFile" "$errorFile"
    fi
fi
