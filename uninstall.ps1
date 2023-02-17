function uninstall_krnl {
    cd $PSScriptRoot
    $kernel = (gci WSL2k*).FullName
    $newline = "kernel=$($kernel -replace '/|\\','\\')"
    $wslcfg = "~/.wslconfig"
    # Remove this kernel
    (gc $wslcfg) | sls -notmatch "$newline" | Set-Content $wslcfg
}
uninstall_krnl
