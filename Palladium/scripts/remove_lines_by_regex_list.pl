#!/usr/bin/perl

$in_file    = $ARGV[0];
$regex_file = $ARGV[1];
$out_file   = $ARGV[2];

#
# 1. go over file list line by line
#
# 2. for each line in file list go over the regex one by one
#
# 3. see if matches any of the regex
#
# 4. if line did not match any regex copy it to out file
#

open(my $in_file_list,  '<', "$in_file")    or die "\n\n####################\n\n   ERROR: $!: $in_file    \n\n####################\n\n";
open(my $regex_list,    '<', "$regex_file") or die "\n\n####################\n\n   ERROR: $!: $regex_file \n\n####################\n\n";
open(my $out_file_list, '>', "$out_file")   or die "\n\n####################\n\n   ERROR: $!: $out_file   \n\n####################\n\n";

chomp(my @regex_list_array = <$regex_list>);

my $keep_current_line = 1;

# 1.
while (my $line_in_file_list = <$in_file_list>) {

  chomp $line_in_file_list;

  $keep_current_line = 1;

  # 2.
  foreach my $regex_from_list (@regex_list_array) {

      if ( $regex_from_list eq "" ) {
            print "\n\n    -Error: empty line in $regex_file\n";
            exit 1;
      }

      # 3.
      if ( $line_in_file_list =~ /$regex_from_list/ ) {	  
          $keep_current_line = 0;
	        print $out_file_list "\n";      
	        last;
      }

  }

  # 4.
  if ($keep_current_line == 1) {
      print $out_file_list "$line_in_file_list\n";
  }

}

close $in_file;
close $regex_file;
close $out_file;
