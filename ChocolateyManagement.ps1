<#
.SYNOPSIS
    Chocolatey Management Script

.DESCRIPTION
    Script to be used in (e. g.) remote monitoring and management solutions to automatically install and update software.

.INPUTS
    No parameters. Variables are supposed to be set by the rmm solution this script is used in.

.OUTPUTS
    None

.RELATED LINKS
    GitHub: https://github.com/MichaelSchoenburg/ChocolateyManagement

.NOTES
    Author: Michael Schönburg
    Version: v1.0
    Last Edit: 03.04.2024
    
    This projects code loosely follows the PowerShell Practice and Style guide, as well as Microsofts PowerShell scripting performance considerations.
    Style guide: https://poshcode.gitbook.io/powershell-practice-and-style/
    Performance Considerations: https://docs.microsoft.com/en-us/powershell/scripting/dev-cross-plat/performance/script-authoring-considerations?view=powershell-7.1
#>

#region INITIALIZATION
<# 
    Libraries, Modules, ...
#>

#endregion INITIALIZATION
#region DECLARATIONS
<#
    Declare local variables and global variables
#>

# The following variables should be set through your rmm solution.
# If you want to install the package, set the respective variable to 1 (integer). Everything other than 1 will result in the package not being installed.
# Tip: PowerShell variables are not case sensitive.

<# 

$VSCode = 1
$7zip = 1
$adobereaderdc = 1
...

#>

$AllPkgs = @()

$AllPkgs += [PSCustomObject]@{ 
    FriendlyName = "Visual Studio Code"
    PkgName = 'vscode'
    Install = $VSCode 
}

$AllPkgs += [PSCustomObject]@{
    FriendlyName = "7-Zip"
    PkgName='7zip'
    Install = $7zip 
}

$AllPkgs += [PSCustomObject]@{
    FriendlyName = "Adobe Reader DC"
    PkgName = 'adobereader'
    Install = $adobereaderdc 
}

$AllPkgs += [PSCustomObject]@{
    FriendlyName = "ZoomIt"
    PkgName = 'zoomit'
    Install = $zoomit 
}

$AllPkgs += [PSCustomObject]@{
    FriendlyName = "Zoom"
    PkgName = 'Zoom'
    Install = $zoom 
}

$AllPkgs += [PSCustomObject]@{
    FriendlyName = "PowerToys"
    PkgName = 'powertoys'
    Install = $powertoys 
}

$AllPkgs += [PSCustomObject]@{
    FriendlyName = "Microsoft Teams (new)"
    PkgName = 'microsoft-teams-new-bootstrapper'
    Install = $MSTeams
}

$AllPkgs += [PSCustomObject]@{
    FriendlyName = "PDF24"
    PkgName = 'pdf24'
    Install = $PDF24
}

$AllPkgs += [PSCustomObject]@{
    FriendlyName = "VLC media player"
    PkgName = 'vlc'
    Install = $VLCmediaplayer
}

$AllPkgs += [PSCustomObject]@{
    FriendlyName = "TreeSize Free"
    PkgName = 'treesizefree'
    Install = $TreeSizeFree
}

#endregion DECLARATIONS
#region FUNCTIONS
<# 
    Declare Functions
#>

function Write-ConsoleLog {
    <#
    .SYNOPSIS
    Logs an event to the console.
    
    .DESCRIPTION
    Writes text to the console with the current date (US format) in front of it.
    
    .PARAMETER Text
    Event/text to be outputted to the console.
    
    .EXAMPLE
    Write-ConsoleLog -Text 'Subscript XYZ called.'
    
    Long form
    .EXAMPLE
    Log 'Subscript XYZ called.
    
    Short form
    #>
    [alias('Log')]
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true,
        Position = 0)]
        [string]
        $Text
    )

    # Save current VerbosePreference
    $VerbosePreferenceBefore = $VerbosePreference

    # Enable verbose output
    $VerbosePreference = 'Continue'

    # Write verbose output
    Write-Output "$( Get-Date -Format 'MM/dd/yyyy HH:mm:ss' ) - $( $Text )"

    # Restore current VerbosePreference
    $VerbosePreference = $VerbosePreferenceBefore
}

function Install-ChocoPkg {
    [CmdletBinding()]
    param (
        [Parameter(
            Mandatory,
            ValueFromPipelineByPropertyName
        )]
        [string]
        $PkgName,

        # I couldn't find a way to read the package name programmatically using Chocolatey, so it has to be specified manually.
        [Parameter(
            ValueFromPipelineByPropertyName
        )]
        [string]
        $FriendlyName = $PkgName,

        [Parameter(
            ValueFromPipelineByPropertyName
        )]
        [int]
        $Install = 1
    )
    
    process {
        if ($Install -eq 1) {
            Log "$($FriendlyName) should be installed."
            $Result = choco list --limit-output --exact $PkgName | ConvertFrom-Csv -delimiter "|" -Header Id, Version
            if ($Result.Count -eq 0) {
                Log "$($FriendlyName) is not yet installed. Start installation..."
                choco install $PkgName --confirm
            } else {
                Log "$($FriendlyName) is already installed in version $($Result.Version)."
            }
        } else {
            Log "$($FriendlyName) should NOT be installed."
        }
    }
}

#endregion FUNCTIONS
#region EXECUTION

#region ChocoInstall
<# 
    Install Chocolatey
#>

# Check if Chocolatey is installed
if (Get-Command -Name choco.exe -ErrorAction SilentlyContinue) {
    Log "Chocolatey is already installed."
} else {
    Log "Chocolatey is not installed yet. Start installation..."
    # Install Chocolatey
    Set-ExecutionPolicy Bypass -Scope Process -Force
    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
    Invoke-WebRequest https://community.chocolatey.org/install.ps1 -UseBasicParsing | Invoke-Expression
}

#endregion ChocoInstall
#region ChocoPkgs
<# 
    Install packages
#>

$AllPkgs | Install-ChocoPkg

#endregion ChocoPkgs
#region ChocoUpdate
<# 
    Update all packages
#>

Log 'Updating all packages...'
choco upgrade all --confirm

#endregion ChocoUpdate

#endregion EXECUTION
