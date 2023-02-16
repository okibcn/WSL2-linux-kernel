cd $PSScriptRoot
$kernel=(gci WSLk*).PSPath
$line="kernel=$($kernel -replace '/|\\','\\')"
$wslcfg="~/.wslconfig"
cp $wslcfg $PSScriptRoot
if ( (Test-Path $wslcfg) -AND (gc $wslcfg | sls "^ *kernel *=") ) {
    # We already have a kernel setting
    (gc $wslcfg) -Replace "^ *kernel *=.*","$line" | Set-Content $wslcfg
} else {
    if ( !( (Test-Path $wslcfg) -AND (gc $wslcfg | sls "^ *[WSL2]") ) ){
        # We don't have a [WSL2] section
        "`n[WSL2]" >> $wslcfg
    } 
    "'n$line" >> $wslcfg
}
echo " Configuration file $wslcfg has been modified. A backup of the old file 
 can be found in folder $PSScriptRoot"
