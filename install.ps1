
function install_krnl {
    cd $PSScriptRoot
    $kernel = (gci WSL2k*).FullName
    $newline = "kernel=$($kernel -replace '/|\\','\\')"
    $wslcfg = "~/.wslconfig"
    $WSL2line = $Krnlline = [int]0

    if (Test-Path $wslcfg) {
        $WSL2line = [int]((gc $wslcfg) | sls "^ *\[wsl2]").Linenumber
        $Krnlline = [int]((gc $wslcfg) | sls "^ *kernel *=").Linenumber
        cp $wslcfg $PSScriptRoot
        echo " Configuration file $wslcfg has been modified. A backup of the old file
 can be found in folder $PSScriptRoot"
    }
    if ($WSL2line -eq 0) {
        # There isn't a WSL2 section
        "" >> $wslcfg
        "[wsl2]" >> $wslcfg
        "$newline" >> $wslcfg
    }
    elseif ($WSL2line -gt $Krnlline) {
        # no kernel line in WSL2 section
        "" >> $wslcfg
        "$newline" >> $wslcfg
    }
    else {
        # Replace current custom kernel
        (gc $wslcfg) -Replace "^ *kernel *=.*", "$newline" | Set-Content $wslcfg
    }
}
install_krnl
