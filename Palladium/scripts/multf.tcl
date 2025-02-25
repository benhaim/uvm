
# those commands tell the xeDEbug to keep retry if
# connection fails
xeset retryDownload 20
xeset retryInterval 20

# point to the compiled design
debug $env(EMU_ROOT)/results/compile/.

# point to the host (since we are runnign from lnx04 this is ".")
host .

# switch to TBrun mode, where the palladium
# can go back and forth from the TB (which will run the C code)
xc xt0
xc zt0
xc on -tbrun
run -swap

# this line tells the palladium to collect waves
# for the path "top_tb" and 5 hier below
probe -create -shm top_tb  -depth 5

# this line limits the amount of waves collected
xeset traceMemSize {100 us}

# this is a flow to run some time and collce the 
# dump into a file
run 99 us
database -upload
run 99 us
database -upload

# and exit
exit
