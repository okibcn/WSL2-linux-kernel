$wslcfg="~/.wslconfig"
if (gc $wslcfg | sls "^ *kernel *=") {
    "We already have a kernel setting"
} else {
    "no kernel setting yet"
}
