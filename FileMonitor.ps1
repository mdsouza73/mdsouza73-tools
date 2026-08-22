# ============================================================
# APM File Monitor
# ============================================================

# ------------------------------------------------------------
# Configuration
# ------------------------------------------------------------

$MonitorFolders = @(
    "D:\APM\Staging",
    "D:\APM\AnotherFolder"
)

$OutputFile = "D:\APM\FileMonitor.txt"


# ------------------------------------------------------------
# Function: Scan a folder and return file details
# ------------------------------------------------------------

function Scan-Folder {
    param (
        [string]$Folder
    )

    # Get only the immediate subfolders
    $SubFolders = Get-ChildItem -Path $Folder -Directory -ErrorAction SilentlyContinue

    foreach ($SubFolder in $SubFolders) {

        # Get files directly inside this subfolder
        $Files = Get-ChildItem -Path $SubFolder.FullName -File -ErrorAction SilentlyContinue

        foreach ($File in $Files) {

            $DetectionDate = Get-Date -Format "dd-MMM-yyyy"
            $DetectionTime = Get-Date -Format "HH:mm:ss"
            $LastModified  = $File.LastWriteTime.ToString("dd-MMM-yyyy HH:mm:ss")

            [PSCustomObject]@{
                DetectionDate = $DetectionDate
                DetectionTime = $DetectionTime
                Filename      = $File.Name
                LastModified  = $LastModified
                Path          = $File.DirectoryName
            }
        }
    }
}


# ------------------------------------------------------------
# Read existing output file
# ------------------------------------------------------------

$ExistingEntries = @()

if (Test-Path $OutputFile) {
    $ExistingEntries = Get-Content -Path $OutputFile
}


# ------------------------------------------------------------
# Scan each monitoring folder
# ------------------------------------------------------------

foreach ($MonitorFolder in $MonitorFolders) {

    # Make sure the folder exists
    if (-not (Test-Path $MonitorFolder)) {
        continue
    }

    # Scan the folder
    $FileDetails = Scan-Folder -Folder $MonitorFolder


    # --------------------------------------------------------
    # Process each file
    # --------------------------------------------------------

    foreach ($File in $FileDetails) {

        # Unique combination used to identify the file/version
        $UniqueEntry = "$($File.Filename) | $($File.LastModified) | $($File.Path)"

        # Check if this entry already exists
        $AlreadyExists = $ExistingEntries | Where-Object {
            $_ -like "*$UniqueEntry"
        }

        # If it is a new entry, write it to the output
        if (-not $AlreadyExists) {

            $OutputLine = "$($File.DetectionDate) | $($File.DetectionTime) | $($File.Filename) | $($File.LastModified) | $($File.Path)"

            Add-Content -Path $OutputFile -Value $OutputLine

            # Add it to our in-memory list as well
            # so duplicate files found during this same run
            # are not written twice.
            $ExistingEntries += $OutputLine
        }
    }
}
