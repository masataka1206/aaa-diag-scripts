Write-Host "Please select the version:" -ForegroundColor Green
Write-Host "[1] 24R1"
Write-Host "[2] 24R2"

$choice = Read-Host "Input your selection [1 or 2]" 
switch ($choice) {
    '1' {
        $version = "24R1"
        $app = "v241"
    }
    '2' {
        $version = "24R2"
        $app = "v242"
    }
    default {
        Write-Host "Invalid input, script terminated." -ForegroundColor Red
        exit
    }
}

# Search for the path up to a specific file
$startDirectory = "C:\Program Files\"
$fileName = "lmutil.exe"
$licfileName = "ansyslmd.ini"

# Specify the file name to search for
$searchPattern = "*\$($app)\licensingclient\winx64\*$filename"
$licsearchPattern = "*\Shared Files\licensing\*$licfilename"

# Search for the path
$foundFiles = Get-ChildItem -Path $startDirectory -Recurse -File -ErrorAction SilentlyContinue |
    Where-Object { $_.FullName -like $searchPattern }

if ($foundFiles) {
    # Set the full path of the first found file to the environment variable
    $targetPath = $foundFiles[0].FullName
    Write-Host "Application files found." -ForegroundColor Green
    Write-Host $targetPath
} else {
    Write-Host "Error: No files found matching pattern '$searchPattern'." -ForegroundColor Red
    exit
}

# Search for the path
$licfoundFiles = Get-ChildItem -Path $startDirectory -Recurse -File -ErrorAction SilentlyContinue |
    Where-Object { $_.FullName -like $licsearchPattern }

if ($licfoundFiles) {
    # Set the full path of the first found file to the environment variable
    $lictargetPath = $licfoundFiles[0].FullName
    Write-Host "Licence file found." -ForegroundColor Green
    Write-Host $lictargetPath
} else {
    Write-Host "Error: No files found matching pattern '$licsearchPattern'." -ForegroundColor Red
    exit
}

# Read the file line by line
if (Test-Path $lictargetPath) {
    $fileContent = Get-Content -Path $lictargetPath
    
    # Search for Server=<Port>:<private IP>
    foreach ($line in $fileContent) {
        if ($line -match '^SERVER=(.*)') {
            # Store the <port>:<private> part in a variable
            $serverValue = $matches[1]
            
            # Set environment variable (e.g. SERVER_NAME)
            $env:SERVER_NAME = $serverValue
            Write-Host "The value of SERVER= '$serverValue' was set to the environment variable SERVER_NAME." -ForegroundColor Green
            break
        }
    }
} else {
    Write-Host "Cannot find the file you specified. Please check the path."
}

$outputFile = "$env:TEMP\output.txt"
$errorFile = "$env:TEMP\error.txt"

# URL&hostname
$url = "https://laas.fnocc.com:443"
$hostname = "flex1397.flexnetoperations.com"

# Question1
$firstAnswer = Read-Host "Are you using a license manager? (Y/N)"
if ($firstAnswer -eq 'Y') {
    # check shared web license
    Start-Process -FilePath $targetPath -ArgumentList @("lmstat", "-c", $serverValue) -NoNewWindow -Wait -RedirectStandardOutput $outputFile
    $output = Get-Content $outputFile
    Write-Host "Standard Output:" -ForegroundColor Green
    Write-Host $output
    Remove-Item -Path $outputFile -Force

} elseif ($firstAnswer -eq 'N') {
    # Question2
    $secondAnswer = Read-Host "Are you using a elastic license? (Y/N)"
    if ($secondAnswer -eq 'Y') {
        # Accessing a specific URL using curl
        Write-Host "Accessing $url using curl..."
        Start-Process -FilePath "curl.exe" -ArgumentList $url -NoNewWindow -Wait -RedirectStandardOutput $outputFile -RedirectStandardError $errorFile
        
        # Check for success or error
        if (Get-Content $errorFile | Select-String -Pattern "Could not resolve host" -Quiet) {
            Write-Host "Error: Access to $url failed." -ForegroundColor Red
        } else {
            Write-Host "Successfully accessed $url." -ForegroundColor Green
        }
        
        # Check name resolution with nslookup
        Write-Host "Checking name resolution with nslookup..."
        Start-Process -FilePath "nslookup" -ArgumentList $hostname -NoNewWindow -Wait -RedirectStandardOutput $outputFile -RedirectStandardError $errorFile
        
        # Check for success or error
        if (Get-Content $outputFile | Select-String -Pattern "(\d{1,3}\.){3}\d{1,3}" -Quiet) {
            Write-Host "Name resolution of $hostname succeeded." -ForegroundColor Green
        } else {
            Write-Host "Error: Name resolution failed for $hostname." -ForegroundColor Red
        }
    }
}