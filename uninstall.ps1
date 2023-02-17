function uninstall_krnl {
    cd $PSScriptRoot
    $kernel = (gci WSL2kernel_*).FullName
    $newline = "kernel=$($kernel -replace '/|\\','\\')"
    $wslcfg = "~/.wslconfig"
    # Remove this kernel
    (gc $wslcfg) | sls -notmatch "$newline"  -simplematch | Set-Content $wslcfg
}
uninstall_krnl
