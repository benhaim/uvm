## minimal UVM env

this env was lastly used to verify some uvm_hdl_force usage

run command:
```
vcs -kdb -lca -full64 -top top_tb -sverilog -ntb_opts uvm +UVM_TESTNAME=some_test -R -timescale=1ns/1ns -f filelist.f -debug_access+all -debug_region=lib+class +acc
```
