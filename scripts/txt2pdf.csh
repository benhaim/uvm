#!/bin/csh

##gvim text_file.txt -c "hardcopy > printed_script.ps | q" # this causes flash (as gvim opens and closes)
rgoff -Tps text_file.txt > printed_script.ps
ps2pdf printed_script.ps same_file.pdf

#TODO need to add checks for $status after each operation
