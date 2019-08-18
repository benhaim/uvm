#!/bin/csh

gvim text_file.txt -c "hardcopy > printed_script.ps | q"
ps2pdf printed_script.ps same_file.pdf

#TODO need to add checks for $status after each operation
