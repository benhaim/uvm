
### ralgen
run VCS's ralgen command to convert IPXACT to ralf
```
ralgen -ipxact2ralf <ipxact file>
```
run VCS's ralgen command to generate the .sv file according to that ralf
```
ralgen -l sv -uvm -t top_reg_block -full64 regmodel.ralf -o regmodel
```
