#!/bin/bash

# Define a URL list (host names only)
hosts=(
    "access.ansys.com"
    "google.com"
    "agwcdn.ansys.com"
    "access.ansys.com"
    "http-intake.logs.datadoghq.eu"
    "download.microsoft.com"
    "download.mozilla.org"
    "download.schedmd.com"
    "ec2-linux-nvidia-drivers.s3.amazonaws.com"
    "ec2-windows-nvidia-drivers.s3.amazonaws.com"
    "efa-installer.amazonaws.com"
    "files.pythonhosted.org"
    "fsx-lustre-client-repo.s3.amazonaws.com"
    "github.com"
    "linux.mellanox.com"
    "objects.githubusercontent.com"
    "pypi.org"
    "python.org"
    "us.download.nvidia.com"
    "dl.fedoraproject.org"
    "dl.rockylinux.org"
    "download1.rpmfusion.org"
    "packages.microsoft.com"
)

# Setting the port number
port=443  # HTTPS port

# Check communication for each host
for host in "${hosts[@]}"; do
    # Test port connection with the nc command
    nc -z -w 5 "$host" "$port"
    
    # Evaluating the results
    if [ $? -eq 0 ]; then
        echo "Success: $host (Port: $port)"
    else
        echo "Failed: $host (Port: $port)"
    fi
done