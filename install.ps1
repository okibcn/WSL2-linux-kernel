
function install_krnl {
    wsl --shutdown
    cd $PSScriptRoot
    $kernel = (gci WSL2kernel_*).FullName
    $newline = "kernel=$($kernel -replace '/|\\','\\')"
    $wslcfg = "~/.wslconfig"
    $WSL2line = $Krnlline = [int]0

    if (Test-Path $wslcfg) {
        $WSL2line = [int]((gc $wslcfg) | sls "^ *\[wsl2]").Linenumber
        $Krnlline = [int]((gc $wslcfg) | sls "^ *kernel *=").Linenumber
        cp $wslcfg $PSScriptRoot
        echo " Configuration file $wslcfg has been modified. A backup of the old file
 can be found in folder $PSScriptRoot"
        (gc $wslcfg) | set-content $wslcfg
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
install_krnl
