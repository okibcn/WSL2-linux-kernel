function helpme {
 " WSL2kernel configuration tool v2.0 2023.02.20
 (C) 2023 Oscar Lopez
 For more information visit: https://github.com/okibcn/WSL2-linux-kernel

 Usage: wsl2kernel [ l | h | u | i [config]]

 wsl2 kernel installs the latest available kernel for WSL2, offering different
 kernel build configurations depending on the special requests.
 
 Options:
 no opt. Shows this kelp.
    l    Lists all the available configurations for the current version
    i    Installs a configuration, or enters interactive mode if not provided
    u    Uninstalls any custom kernel returning to the one provided with WSL
    h    Shows this help.`n"
}

function uninstall {
    wsl --shutdown
    $line = "$($PSScriptRoot -replace '/|\\','\\')"
    $wslcfg = "~/.wslconfig"
    (gc $wslcfg) | sls -notmatch "$line"  -simplematch | Set-Content $wslcfg
}

function install($opt) {
    if (!$opt) { $opt = 'std' }
    cd $PSScriptRoot
    $json = gc .\kernels.json | ConvertFrom-Json
    $kernelName = "WSL2kernel_$($opt)_$($json.version)"
    $kernelPath = (gci "$kernelName").FullName
    $newline = "kernel=$($kernelPath -replace '/|\\','\\')"
    $wslcfg = "~/.wslconfig"
    $WSL2line = $Krnlline = [int]0
    if (Test-Path $wslcfg) {
        $WSL2line = [int]((gc $wslcfg) | sls "^ *\[wsl2]").Linenumber
        $Krnlline = [int]((gc $wslcfg) | sls "^ *kernel *=").Linenumber
        cp $wslcfg $PSScriptRoot
        echo " Configuration file $wslcfg has been modified. A backup of the old file
 can be found in folder $PSScriptRoot."
        (gc $wslcfg) | set-content $wslcfg
        wsl --shutdown
    }
    if ($WSL2line -eq 0) {
        # There isn't a WSL2 section
        Add-Content $wslcfg "[wsl2]'n$newline"
    }
    elseif ($WSL2line -gt $Krnlline) {
        # no kernel line in WSL2 section
        Add-Content $wslcfg "$newline"
    }
    else {
        # Replace current custom kernel
        (gc $wslcfg) -Replace "^ *kernel *=.*", "$newline" | Set-Content $wslcfg
    }
}

Function Menu {
    $json = gc .\kernels.json | ConvertFrom-Json
    $maxOpt = $json.kernels.count
    "Please choose a configuration"
    "*****************************"
    Write-Host -Object "   WSL2 Kernel $($json.version)" -ForegroundColor Yellow
    "*****************************"
    $opt = 0
    $json.kernels | % {
        $opt++
        "(${opt}) $($_.description)"
        ""
    }
    "(U)ninstall custom kernel"
    ""
    "(C)ancel"
    ""
    $Menu = Read-Host -Prompt "(1-${maxopt}), U or C)"
    switch ($Menu) {
        'U' { uninstall; exit }
        'C' { exit }
    }
    $kernel = [int]$Menu - 1
    if ($kernel -lt 0 -OR $kernel -ge $maxOpt) {
        "Invalid option. Leaving without any action."
        exit
    }
    install $json.kernels[$kernel].config
}   

function wsl2kernel {
    cd $PSScriptRoot
    $configs = (gc .\kernels.json | ConvertFrom-Json).kernels
    switch ($args[0]) {
        "l" { $configs ; exit }
        "u" { uninstall ; exit }
        "i" {
            if ($args[1]) {
                if ($args[1] -in $configs.config) {
                    install $args[1]
                }
                else {
                    "Unknown configuration. Use one from the list:"
                    $configs
                    exit
                }
            }
            else {
                menu
            }
            exit
        }
        default { helpme }
    }
}
# Launch The program
wsl2kernel @args