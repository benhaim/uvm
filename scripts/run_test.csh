#!/bin/csh

# print usage to screen
alias usage " \
    echo '\n  Usage:\n\n    >> runt.csh -t|test <test_name> -setup_name <setup name>'   \
    echo '\n  Flags:\n' \
    \grep case $0 | \grep -v grep | sed 's/case//' | tr -d '#"\""' \
    echo "

set test = ""
set gui  = ""

set vcs_args  = ""
set simv_args = ""

set seed  = "0"
set sufix = ""
set dump_waves  = ""

while ( $#argv != 0 )
   switch ( $argv[1] )
      #case# MANDATORY FLAGS
      case "-{t,test}":        # test name to run
                        shift
                        set test = $argv[1]
                        shift
                        set rerun_test = "$rerun_test -test $test"
                        breaksw
      #case#
      #case# OPTIONAL FLAGS
      case "-sim_folder":       # folder under $WA_ROOT to run at (default is sim/)
                        shift
                        set sim_folder = $argv[1]
                        shift
                        set rerun_test = "$rerun_test -sim_folder $sim_folder"
                        breaksw
      case "-{g,gui}":          # open Verdi to run simulation
                        set gui = "-gui=verdi"
                        set debug_access = "+all"
                        shift
                        set rerun_test = "$rerun_test -gui"
                        breaksw
      case "-{w,waves}":        # dump fsdb file
                        set dump_waves = "-ucli -i setup_vcs.do" 
                        shift
                        set rerun_test = "$rerun_test -waves"
                        breaksw
      case "-cov":              # generate coverage in central location (under '<sim_folder>/simv_cov/')
                        set cov_str = "1"
                        shift 
                        set rerun_test = "$rerun_test -cov"
                        breaksw
      case "-sufix":            # add sufix to test's folder name
                        shift 
                        set sufix = $argv[1]
                        shift 
                        set rerun_test = "$rerun_test -sufix $sufix"
                        breaksw
      case "-vcs_args":         # direct add arguments to VCS command
                        shift 
                        set vcs_args = "$vcs_args $argv[1]"
                        shift
                        set rerun_test = "$rerun_test -vcs_args $vcs_args"
                        breaksw
      case "-simv_args":        # direct add arguments to SIMV command
                        shift 
                        set simv_args = "$simv_args $argv[1]"
                        set rerun_test = "$rerun_test -simv_args $simv_args"
                        shift
                        breaksw
      case "-{s,seed}":         # run with specific seed ("random" for random seed)
                        shift
                        set seed = $argv[1]
                        shift
                        breaksw
      case "-{h,help}":         # print usage
                        usage
                        exit 1
      default:
                        usage
                        echo "\n        -Error: flag $argv[1] is not supported\n"
                        exit 1
   endsw
end


# verify user under the sourced WA tree
set wa_name = `basename $WA_ROOT`
echo $PWD/ | grep "/$wa_name/" -q
verify_operation $status "you sourced setproj under $WA_ROOT, and you are at $PWD. some of the env variables may not be what you mean" 

# remove extension from testname
set test = `basename $test .sv`
# verify test exists before compiling (to spare compilation of non existing test)
find $TESTS/ -name $test.sv | grep . -q
verify_operation $status "test $test does not exist" 

if ( $setup_name == "" ) then
    printf "\n\033[1;31m  Compilation failed\033[0m\n"
    printf "\n  flag -setup_name <setup name>  is missing\n\n"
    exit 1
endif


####################################
# 
#       generate seed if random
#
if ( $seed == "random" ) then
    set seed = `perl -e "print int(rand(32000000));"`
endif
set rerun_test = "$rerun_test -seed $seed"



##################################
#
#   create results folder
#
mkdir -p $WA_ROOT/$sim_folder


 
##################################
#
#   set coverage command
#
## this is here and not in the arg switch so that $sim_folder
## will be defined at this point if it is not default
#
if ( $cov_str != "" ) then
    set cov_str = ""
    set cov_str = "$cov_str -cm line+fsm+cond+tgl+branch+assert"    # code coverage flags
    set cov_str = "$cov_str -cm_dir $comp_folder/simv_cov"          # folder to collect coverage (to speare the merge later)
    # cm_libs only relevant to compilation (adding to simv causes warning)
    set vcs_cov = "$cov_str -cm_libs vy"     
endif


    @ vcs_start_utc = `date +%s`
    
    echo "RUN SCRIPT: run VCS compilation (started `date +%H:%M:%S`)"
    
    vcs -debug_access+all $vcs_cov -timescale=1ns/1ps -l comp.log \
        +define+PRTN_NO_ASRT \
    	  -debug_region=lib+cell \
        -full64 -top $top_module \
        -kdb -lca +acc \
        +libext+.v \
        -sverilog \
        -f $file_list  \
        $vcs_args  \
        +vcs+lic+wait    
    if ( $status != 0 ) then
        printf "\n\033[1;31m  Compilation failed\033[0m, log at:\n    gvim $comp_folder/comp.log\n\n"
        exit 1
    else
        printf "\n\033[1;32m  Compilation passed\033[0m, log at:\n    gvim $comp_folder/comp.log\n\n"
    endif
    
    @ vcs_end_utc = `date +%s`
    @ vcs_minuts  = ( $vcs_end_utc - $vcs_start_utc ) / 60
    @ vcs_seconds = ( $vcs_end_utc - $vcs_start_utc ) % 60
    printf "VCS compilation took %0d:%02d minuts\n\n" ${vcs_minuts} ${vcs_seconds}
        




####################################
# 
#   manage the sufix
#
if ( $sufix != "" ) then
    if ( $sufix == "seed" ) then
        set sufix = "_${seed}"  
    else
        set sufix = "_${sufix}"
    endif
endif


##################################
#
#   get UTC time before SIMV
#
@ simv_start_utc = `date +%s`


    ##################################
    #
    #     if test is folder copy supported files
    #
    if ( -d $TESTS/$test ) then
        \cp $TESTS/$test/* .
    endif


    if ( "$dump_waves" != "" ) then
        \rm -f setup_vcs.do
        ## make test generate dumps and run and stop
        echo "fsdbDumpfile dut.fsdb"         >> setup_vcs.do
        echo "fsdbDumpvars 0 {$top_module} +mda" >> setup_vcs.do
        if ( "$gui" == "" ) then # if not running with gui run the test
            echo run                         >> setup_vcs.do
            echo quit                        >> setup_vcs.do
        endif
    endif

    if ( "$cov_str" != "" ) then
        set cm_name = " -cm_name ${test}${sufix}"  # uniqu name for each test coverage results
    endif


   ##  +UVM_MAX_QUIT_COUNT=<number>
   ##  +UVM_VERBOSITY=<verbosity_string>
   
   
    echo "RUN SCRIPT: run SIMV simulation (started `date +%H:%M:%S`)"
    ./simv  +UVM_TESTNAME=$test +ntb_stop_on_constraint_solver_error=1 \
                       +ntb_random_seed=${seed} $dump_waves  \
                      -l sim.log $simv_args $gui $cov_str $cm_name


