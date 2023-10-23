$installerUrl = "<URL to the msi>"

$NESSUS_GROUP = "<Name of your Nessus Group>"

$NESSUS_KEY = "<Name of Nessus Key>"

$NESSUS_SERVER = "<FQDN of Nessus Server>"

$NESSUS_PORT = "<Port if different from standard 8834>"

$installerPath = "C:\TEMP\nessusagent.msi"

$windows_package_name = "'Nessus Agent (x64)'"

$installed = Get-WmiObject -Query "SELECT * FROM Win32_Product WHERE Name = $windows_package_name" | Select-Object Name

function Test-Admin {

    $currentUser = New-Object Security.Principal.WindowsPrincipal $([Security.Principal.WindowsIdentity]::GetCurrent())

    $currentUser.IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)

}



if ((Test-Admin) -eq $false) {

    if ($elevated) {

    }

    else {

        Start-Process powershell.exe -Verb RunAs -ArgumentList ('-noprofile -file "{0}" -elevated' -f ($myinvocation.MyCommand.Definition))

    }

    exit

}


'running with full privileges'

if ($installed) {

    Write-Output "Nessus Agent is already installed. Exiting."

}

else {

    Write-Output "Downloading Nessus Agent MSI installer..."

    Invoke-WebRequest -Uri $installerUrl -OutFile $installerPath

    Write-Output "Installing Nessus Agent..."

    Start-Process -FilePath msiexec.exe -ArgumentList '/i C:\TEMP\nessusagent.msi NESSUS_GROUPS="$NESSUS_GROUP" NESSUS_SERVER="$NESSUS_SERVER" NESSUS_KEY='$NESSUS_KEY' /qn' -Wait

    $installed = Get-WmiObject -Query "SELECT * FROM Win32_Product WHERE Name = $windows_package_name" | Select-Object Name

    if ($installed) {

        Write-Output "Nessus Agent has been successfully installed."

    }

    else {

        Write-Output "Failed to install Nessus Agent."

    }

}


if (Test-Path $installerPath) {

    Remove-Item -Path $installerPath -Force

}


Function Start-ProcessGetStream {

    [CmdLetBinding()]

    Param(

        [System.IO.FileInfo]$FilePath,

        [string[]]$ArgumentList

    )

    $pInfo = New-Object System.Diagnostics.ProcessStartInfo

    $pInfo.FileName = $FilePath

    $pInfo.Arguments = $ArgumentList

    $pInfo.RedirectStandardError = $true

    $pInfo.RedirectStandardOutput = $true

    $pinfo.UseShellExecute = $false

    $pInfo.CreateNoWindow = $true

    $pInfo.WindowStyle = [System.Diagnostics.ProcessWindowStyle]::Hidden

    $proc = New-Object System.Diagnostics.Process

    $proc.StartInfo = $pInfo

    Write-Verbose "Starting $FilePath"

    $proc.Start() | Out-Null

    Write-Verbose "Waiting for $($FilePath.BaseName) to complete"

    $proc.WaitForExit()

    $stdOut = $proc.StandardOutput.ReadToEnd()

    $stdErr = $proc.StandardError.ReadToEnd()

    $exitCode = $proc.ExitCode



    Write-Verbose "Standard Output: $stdOut"

    Write-Verbose "Standard Error: $stdErr"

    Write-Verbose "Exit Code: $exitCode"

    [PSCustomObject]@{

        "StdOut"   = $stdOut

        "Stderr"   = $stdErr

        "ExitCode" = $exitCode

    }

}

Function Get-NessusStatsFromStdOut {



    Param(

        [string]$stdOut

    )



    $stats = @{}







    $StdOut -split "`r`n" | ForEach-Object {

        if ($_ -like "*:*") {

            $result = $_ -split ":"

            $stats.add(($result[0].Trim() -replace "[^A-Za-z0-9]", "_").ToLower(), $result[1].Trim())

        }

    }

    Return $stats

}

Function Get-DateFromEpochSecond {

    Param(

        [int]$seconds

    )



    $utcTime = (Get-Date 01.01.1970) + ([System.TimeSpan]::fromseconds($seconds))

    Return Get-Date $utcTime.ToLocalTime() -Format "yyyy-MM-dd HH:mm:ss"

}


Try {

    $nessusExe = Join-Path $env:ProgramFiles -ChildPath "Tenable\Nessus Agent\nessuscli.exe" -ErrorAction Continue

}

Catch {

    Throw "Cannot find NessusCli.exe, installing..."

}



Write-Output "Getting Agent Status..."

$agentStatus = Start-ProcessGetStreams -FilePath $nessusExe -ArgumentList "agent status"



If ($agentStatus.stdOut -eq "" -and $agentStatus.StdErr -eq "") {

    Throw "No Data Returned from NessusCli, linking now"

    Start-ProcessGetStreams -FilePath $nessusExe -ArgumentList 'agent link --key=$NESSUS_KEY --groups="$NESSUS_GROUP" --host=$NESSUS_SERVER --port=$NESSUS_PORT'

}

elseif ($agentStatus.StdOut -eq "" -and $agentStatus.StdErr -ne "") {

    Throw "StdErr: $($agentStatus.StdErr)"

}

elseif (-not($agentStatus.stdOut -like "*Running: *")) {

    Throw "StdOut: $($agentStatus.StdOut)"

}

else {

    $stats = Get-NessusStatsFromStdOut -stdOut $agentStatus.StdOut

    If ($stats.linked_to -eq '$NESSUS_SERVER' -and $stats.link_status -ne 'Not linked to a manager') {

        Write-Output "Connected to $NESSUS_SERVER"

    }

    else {

        Write-Output "Connecting..."

        Start-ProcessGetStreams -FilePath "C:\Program Files\Tenable\Nessus Agent\nessuscli.exe" -ArgumentList 'agent link --key=$NESSUS_KEY --groups="$NESSUS_GROUP" --host=$NESSUS_SERVER --port=$NESSUS_PORT'

    }

    If ($stats.last_connection_attempt -as [int]) { $stats.last_connection_attempt = Get-DateFromEpochSeconds $stats.last_connection_attempt }

    If ($stats.last_connect -as [int]) { $stats.last_connect = Get-DateFromEpochSeconds $stats.last_connect }

    If ($stats.last_scanned -as [int]) { $stats.last_connect = Get-DateFromEpochSeconds $stats.last_scanned }

}


#$stats | Out-Host
