# Define a URL list (host names only)
$urls = @(
    "access.ansys.com",
    "google.com",
    "agwcdn.ansys.com",
    "access.ansys.com",
    "http-intake.logs.datadoghq.eu"
    "download.microsoft.com",
    "download.mozilla.org",
    "download.schedmd.com",
    "ec2-linux-nvidia-drivers.s3.amazonaws.com",
    "ec2-windows-nvidia-drivers.s3.amazonaws.com",
    "efa-installer.amazonaws.com",
    "files.pythonhosted.org",
    "fsx-lustre-client-repo.s3.amazonaws.com",
    "github.com",
    "linux.mellanox.com",
    "objects.githubusercontent.com"
    "pypi.org",
    "python.org",
    "us.download.nvidia.com",
    "dl.fedoraproject.org",
    "dl.rockylinux.org",
    "download1.rpmfusion.org",
    "packages.microsoft.com"
)

# Check communication for each host
foreach ($url in $urls) {
    $port = 443  # HTTPS port

    # Test-NetConnection to check communication
    $result = Test-NetConnection -ComputerName $url -Port $port

    # Evaluating the results
    if ($result.TcpTestSucceeded) {
        Write-Output "Success: $url (Port: $port)"
    } else {
        Write-Output "Failed: $url (Port: $port, Error: Connection failed)"
    }
}