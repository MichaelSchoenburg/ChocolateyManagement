<#
.SYNOPSIS
    Chocolatey Management Script

.DESCRIPTION
    Script to be used in (e. g.) remote monitoring and management solutions to automatically install and update software.

.SYNTAX


.PARAMETERS


.EXAMPLE
    PS C:\> <example usage>
    Explanation of what the example does

.INPUTS
    None. Parameters are supposed to be set by the rmm solution this script is used in.

.OUTPUTS
    Exit Codes:
    0 = Successfull
    1 = Error
    2 = Warning

.RELATED LINKS
    GitHub: https://github.com/MichaelSchoenburg/ChocolateyManagement

.NOTES
    Author: Michael Schönburg
    Version: v1.0
    Last Edit: 03.04.2024
    
    This projects code loosely follows the PowerShell Practice and Style guide, as well as Microsofts PowerShell scripting performance considerations.
    Style guide: https://poshcode.gitbook.io/powershell-practice-and-style/
    Performance Considerations: https://docs.microsoft.com/en-us/powershell/scripting/dev-cross-plat/performance/script-authoring-considerations?view=powershell-7.1

.REMARKS
    To see the examples, type: "get-help Get-HotFix -examples".
    For more information, type: "get-help Get-HotFix -detailed".
    For technical information, type: "get-help Get-HotFix -full".
    For online help, type: "get-help Get-HotFix -online"
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

<# 

$VSCode
$7-Zip
$adobereaderdc
$zoomit
$powertoys
$MSTeams

#>

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
    Write-Ouutput "$( Get-Date -Format 'MM/dd/yyyy HH:mm:ss' ) - $( $Text )"

    # Restore current VerbosePreference
    $VerbosePreference = $VerbosePreferenceBefore
}

function Install-ChocoPkg {
    [CmdletBinding()]
    param (
        [Parameter(
            Mandatory
        )]
        [string]
        $PkgName,

        # I couldn't find a way to read the package name programmatically using Chocolatey, so it has to be specified manually.
        [Parameter()]
        [string]
        $FriendlyName = $PkgName
    )
    
    $Result = choco list --limit-output --exact $PkgName | ConvertFrom-Csv -delimiter "|" -Header Id, Version
    if ($Result.Count -eq 0) {
        Log "$($FriendlyName) ist noch nicht installiert. Starte Installation..."
        choco install $PkgName --confirm
    } else {
        Log "$($FriendlyName) ist bereits in Version $($Result.Version) installiert."
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
    Log "Chocolatey ist bereits installiert."
} else {
    Log "Chocolatey ist noch nicht installiert. Starte Installation..."
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

# Visual Studio Code
if ($VSCode -eq 1) {
    Log "Visual Studio Code should be installed."
    Install-ChocoPkg -PkgName vscode -FriendlyName 'Visual Studio Code'
} else {
    Log "Visual Studio Code should not be installed."
}

# 7-Zip
if ($7zip -eq 1) {
    Log "7-Zip should be installed."
    Install-ChocoPkg -PkgName 7zip -FriendlyName '7-Zip'
} else {
    Log "7-Zip should not be installed."
}

# Adobe Reader DC
if ($adobereaderdc -eq 1) {
    Log "Adobe Reader DC should be installed."
    Install-ChocoPkg -PkgName adobereader -FriendlyName 'Adobe Reader DC'
} else {
    Log "Adobe Reader DC should not be installed."
}

# ZoomIt
if ($zoomit -eq 1) {
    Log "ZoomIt should be installed."
    Install-ChocoPkg -PkgName zoomit -FriendlyName 'ZoomIt'
} else {
    Log "ZoomIt should not be installed."
}

# Zoom
if ($zoom -eq 1) {
    Log "Zoom should be installed."
    Install-ChocoPkg -PkgName zoom -FriendlyName 'Zoom'
} else {
    Log "Zoom should not be installed."
}

# PowerToys
if ($powertoys -eq 1) {
    Log "PowerToys should be installed."
    Install-ChocoPkg -PkgName powertoys -FriendlyName 'PowerToys'
} else {
    Log "PowerToys should not be installed."
}

# Microsoft Teams (neu)
if ($MSTeams -eq 1) {
    Log "Microsoft Teams (new) should be installed."
    Install-ChocoPkg -PkgName microsoft-teams-new-bootstrapper -FriendlyName 'Microsoft Teams (new)'
} else {
    Log "Microsoft Teams (new) should not be installed."
}

#endregion ChocoPkgs
#region ChocoUpdate
<# 
    Update all packages
#>
Log 'Updating all packages...'
choco upgrade all --confirm

#endregion ChocoUpdate

#endregion EXECUTION
