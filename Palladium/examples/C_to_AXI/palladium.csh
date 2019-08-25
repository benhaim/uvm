#!/bin/csh

set compile   = "0"
set run       = "0"
set gui       = ""

while ( $#argv != 0 )
    switch ( $argv[1] )
        case "-{r,run}":
                        set run = "1"
                        shift
                        breaksw
        case "-{c,compile}":
                        set compile = "1"
                        shift
                        breaksw
        case "-{g,gui}":
                        set gui = "-gui"
                        shift
                        breaksw
        default:
                        echo "\n  flags:\n"
                        echo "      -c / -cpmpile   : compile the demo for Palladium"
                        echo "      -r / -run       : run the demo on Palladium"
                        echo "      -g / -gui       : run the demo in xeDebug GUI mode"
                        echo ""
                        echo "\n        -Error: flag $argv[1] is not supported\n"
                        exit 1
   endsw
end


#################################
#
#   make sure user is on palladium host
#
if ( $HOST != "palladium_host_name" ) then
    echo "\n        -Error: this script must run from palladium host, please ssh there\n" 
    exit 1
endif

#################################
#
#   make sure command is valid
#
if ( ($compile == "0") & ($run == "0") ) then
    echo "\n        -Error: either -compile or -run (or both) must be used\n" 
    exit 1
endif

#################################
#
#   define env variables
#   and source and targe folders
#
setenv UXE_HOME /delivery/tools/cadence/uxe/UXE171/
setenv PATH ${PATH}:$UXE_HOME/tools/bin
# folder where the delivery is at:
setenv EMU_ROOT $PWD
# folder where the results will be generated:
set results_folder = $PWD/results


#################################
#
#     COMPILE
#
if ($compile == "1") then
    mkdir -p $results_folder
    cd $results_folder
    rm -rf compile
    mkdir -p compile
    cd compile

    echo "PALLADIUM COMPILE (`date +'%H:'%M`): started at $results_folder/compile"
    \cp -f $EMU_ROOT/axi_driver.sv    .
    \cp -f $EMU_ROOT/axi_tasks.c      .
    \cp -f $EMU_ROOT/clk.qel          . 
    \cp -f $EMU_ROOT/dut_wrapper.v    .
    \cp -f $EMU_ROOT/top_tb.v         .
    
    echo "PALLADIUM COMPILE (`date +'%H:'%M`): generate clocks"
    ixclkgen -input clk.qel -output clocks.sv > /dev/null
    if ($status != 0) then
    	echo "\n -Error: ixclkgen failed\n"
    	exit 1
    endif

    echo "PALLADIUM COMPILE (`date +'%H:'%M`): vlan command"
    vlan -SV +sv top_tb.v dut_wrapper.v axi_driver.sv clocks.sv -v ${UXE_HOME}/share/uxe/etc/ixcom/IXCclkgen.sv > /dev/null
    if ($status != 0) then
    	echo "\n -Error: vlan failed:\n 		gvim $PWD/vlan.log\n"
    	exit 1
    endif
    
    echo "PALLADIUM COMPILE (`date +'%H:'%M`): clean compilation" 
    ixcom -clean > /dev/null

    echo "PALLADIUM COMPILE (`date +'%H:'%M`): IXCOM compile (takes few minuts)" 
    ixcom -ua +dut+dut_wrapper+_ixc_clkgen -top top_tb -top _ixc_clkgen -timescale 1ns/1ns > /dev/null
    if ($status != 0) then
    	echo "\n -Error: ixcom failed:\n 		gvim $PWD/ixcom.log\n"
    	exit 1
    endif    
    
    echo "PALLADIUM COMPILE (`date +'%H:'%M`): irun C code compile" 
    irun -c -f xc_work/irun.f axi_tasks.c -clean > /dev/null
    if ($status != 0) then
    	echo "\n -Error: irun failed:\n 		gvim $PWD/irun.log\n"
    	exit 1
    endif
    
    echo "PALLADIUM COMPILE (`date +'%H:'%M`): Palladium compilation completed" 

endif

#################################
#
#     RUN
#
if ($run == "1") then
    if (! -d $results_folder) then
    	echo "\n -Error: folder $results_folder is missing, make sure design was compiled \n"
    	exit 1
    endif
    cd $results_folder
    setenv EMU_COMPILE $results_folder/compile
    rm -rf run
    mkdir -p run
    cd run
    \cp -f $EMU_ROOT/multf.tcl        .
    xeDebug -input multf.tcl $gui
endif

exit 0
