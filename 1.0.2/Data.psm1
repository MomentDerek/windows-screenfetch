Add-Type -AssemblyName System.Windows.Forms

Function Get-SystemSpecifications() 
{

    $UserInfo = Get-UserInformation;
    $OS = "Windows 10";
    $Kernel = Get-Kernel;
    $Shell = Get-Shell;
    $Displays = Get-Displays;
    $CPU = Get-CPU;
    $GPU = Get-GPU;
    $RAM = Get-RAM;


    [System.Collections.ArrayList] $SystemInfoCollection = 
        "",
        "",
        "",
        "", 
        $OS, 
        $Kernel,
        $Shell,
        $Displays,
        $CPU,
        $GPU,
        $RAM;
    
    return $SystemInfoCollection;
}

Function Get-LineToTitleMappings() 
{ 
    $TitleMappings = @{
        0 = "";
        1 = "";
        2 = "";
        3 = "Moment's Laptop";
        4 = "OS: "; 
        5 = "Kernel: ";
        6 = "Shell: ";
        7 = "Resolution: ";
        8 = "CPU: ";
        9 = "GPU ";
        10 = "RAM: ";
    };

    return $TitleMappings;
}

Function Get-UserInformation()
{
    return $env:USERNAME + "@" + (Get-CimInstance Win32_OperatingSystem).CSName;
}

Function Get-OS()
{
    return (Get-CimInstance Win32_OperatingSystem).Caption + " " + 
        (Get-CimInstance Win32_OperatingSystem).OSArchitecture;
}

Function Get-Kernel()
{
    return (Get-CimInstance  Win32_OperatingSystem).Version;
}

Function Get-Shell()
{
    return "PowerShell $($PSVersionTable.PSVersion.ToString())";
}

Function Get-Displays()
{ 
    $Displays = New-Object System.Collections.Generic.List[System.Object];

    # This gives the available resolutions
    $monitors = Get-CimInstance -N "root\wmi" -Class WmiMonitorListedSupportedSourceModes

    foreach($monitor in $monitors) 
    {
        # Sort the available modes by display area (width*height)
        $sortedResolutions = $monitor.MonitorSourceModes | sort -property {$_.HorizontalActivePixels * $_.VerticalActivePixels}
        $maxResolutions = $sortedResolutions | select @{N="MaxRes";E={"$($_.HorizontalActivePixels) x $($_.VerticalActivePixels) "}}

        $Displays.Add(($maxResolutions | select -last 1).MaxRes);
    }

    return $Displays;
}

Function Get-CPU() 
{
    return (((Get-CimInstance Win32_Processor).Name) -replace '\s+', ' ');
}

Function Get-GPU() 
{
    return (Get-CimInstance Win32_DisplayConfiguration).DeviceName;
}

Function Get-RAM() 
{
    $FreeRam = ([math]::Truncate((Get-CimInstance Win32_OperatingSystem).FreePhysicalMemory / 1KB)); 
    $TotalRam = ([math]::Truncate((Get-CimInstance Win32_ComputerSystem).TotalPhysicalMemory / 1MB));
    $UsedRam = $TotalRam - $FreeRam;
    $FreeRamPercent = ($FreeRam / $TotalRam) * 100;
    $FreeRamPercent = "{0:N0}" -f $FreeRamPercent;
    $UsedRamPercent = ($UsedRam / $TotalRam) * 100;
    $UsedRamPercent = "{0:N0}" -f $UsedRamPercent;

    return $UsedRam.ToString() + "MB / " + $TotalRam.ToString() + " MB " + "(" + $UsedRamPercent.ToString() + "%" + ")";
}