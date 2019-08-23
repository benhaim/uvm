#!/usr/bin/perl

$source_file=$ARGV[0];
$dest_file=$ARGV[1];
 
$source_file =~ s/\$(\w+)/$ENV{$1}/g; # perl use of env parameters

open(my $in_file,  '<', "$source_file") or die "\n\n -Error: Cannot locate file:\n      $source_file\n   please check the list under verif/emulation/config_files/files_to_empty_module.txt\n";
open(my $out_file, '>', "$dest_file")   or die "Cannot open destination file $dest_file: $!";

my $module_define_done = 0;
my $multi_line_port = 0;
my $skip_section = 0;

while ( my $line = <$in_file>) {


    # chomp end of line and remove verilog remarks
    $line =~ s/\r//g;           
    $line =~ s/\/\/.*//;


    # to avoid collecting ports in tasks or functions
    if ($line =~ m/^\s*task\s/)       { $skip_section = 1; next }
    if ($line =~ m/^\s*endtask\s/)    { $skip_section = 0; next }
    if ($line =~ m/^\s*function\s/)   { $skip_section = 1; next }
    if ($line =~ m/^\s*endfunction\s/){ $skip_section = 0; next }


    # if line should be skipped
    if ($skip_section == 1)      { next }


    if ($line =~ m/endprimitive\s/) { print $out_file "*/"; next }
    if ($line =~ m/\s*primitive\s/) { print $out_file "/*"; next }

    # handle endmodule
    if ($line =~ m/endmodule/)
        {
          print $out_file $line;
          next
        }


    # start of new module
    if ($line =~ m/^\s*module\s/)
        {
          $module_define_done = 0;
        }

  
    # end of module definition (might be in single line)
    if (( $line =~ m/\)\;/ )||( $line =~ m/^\s*module.*\)\;/ )) 
        {
          if ($module_define_done==0) { print $out_file $line; }
          $module_define_done = 1;
          next
        }

    # copy ifdefs to bb
    if ($line =~ m/^\s*`else|^\s*`ifndef|^\s*`ifdef|^\s*`define|^\s*`endif/)
        { 
          print $out_file $line; 
          next
        }
    

    # while module definition is not closed transfer to bb
    if ($module_define_done==0)
        { 
          print $out_file $line;
          next
        }


    # handle ports defined over multiple lines
    if (($module_define_done==1)&&($multi_line_port==1))
        {
          print $out_file $line;
          if ($line =~ m/.*;/) { $multi_line_port = 0; }
          #TODO shuldnt be here "next"?? just in case..
        }


    # any of the ports definition transfer to bb
    if ($line =~ m/^\s*output\s|\s*output\[|^\s*input\[|^\s*input\s|^\s*inout\s/)
        { 
          if (!($line =~ m/;/)) { $multi_line_port = 1; } # for ports defined over multiple lines
          print $out_file $line;
          #TODO shuldnt be here "next"?? just in case..
        }

    # copy parameters to bb
    if ($line =~ m/^\s*parameter/)
        {
          if (!($line =~ m/;/)) { $multi_line_port = 1; } # for ports defined over multiple lines
          print $out_file $line; 
        }

}
      

close $in_file;
close $out_file;
