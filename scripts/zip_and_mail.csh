#!/bin/csh

set reg_folder = $argv[1]

set mail_address = ""
if ( $#argv == 2 ) then
    set mail_address = "$argv[2]"
endif 

# create zipped file
zip $reg_folder/compressed_files.zip $reg_folder/*.txt

# mail the zip
if ( "$mail_address" != "" ) then
    echo "see attacehd (mail content)" | mail -s "zipped file (mail subject)" -a $reg_folder/compressed_files.zip $mail_address
endif
