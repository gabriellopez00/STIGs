<#
.SYNOPSIS
    This PowerShell script ensures that the maximum size of the Windows Application event log is at least 32768 KB (32 MB).

.NOTES
    Author          : Gabriel Lopez
    LinkedIn        : www.linkedin.com/in/gabriel-lopez-a925b529b
    GitHub          : github.com/gabriellopez00
    Date Created    : 2025-07-03
    Last Modified   : 2025-07-03
    Version         : 1.0
    CVEs            : N/A
    Plugin IDs      : N/A
    STIG-ID         : WN10-AU-000500

.TESTED ON
    Date(s) Tested  :
    Tested By       : 
    Systems Tested  : 
    PowerShell Ver. : 

.USAGE
    PS C:\> .\STIG-ID-WN10-AU-000500.ps1 
#>

# Check if running with administrative privileges
if (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator"))  
{  
    Write-Warning "Please run this script as an Administrator!"
    exit
}

try {
    # Define the registry path
    $registryPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\EventLog\Application"
    
    # Create the full registry path if it doesn't exist
    if (!(Test-Path $registryPath)) {
        Write-Host "Creating registry path: $registryPath" -ForegroundColor Yellow
        
        # Break down the path and create each level
        $pathParts = $registryPath -split "\\"
        $currentPath = $pathParts[0]
        
        foreach ($part in $pathParts[1..($pathParts.Length-1)]) {
            $currentPath += "\$part"
            if (!(Test-Path $currentPath)) {
                New-Item -Path $currentPath | Out-Null
            }
        }
    }

    # Set the MaxSize value, creating it if it doesn't exist
    New-ItemProperty -Path $registryPath -Name "MaxSize" -Value 32768 -PropertyType DWord -Force | Out-Null

    # Verify the setting
    $currentMaxSize = Get-ItemPropertyValue -Path $registryPath -Name "MaxSize"
    
    if ($currentMaxSize -ge 32768) {
        Write-Host "Application Event Log size successfully set to $currentMaxSize KB" -ForegroundColor Green
    }
    else {
        Write-Host "Failed to set Application Event Log size" -ForegroundColor Red
    }
}
catch {
    Write-Host "An error occurred: $_" -ForegroundColor Red
}
