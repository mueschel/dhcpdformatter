#!/usr/bin/perl

#This tool takes a usual dhcpd.conf file and outputs its contents to STDOUT
#all host-entries are reformatted to single-line format, sorted and grouped by subnet
#Use at your own risk and always keep a backup!


use warnings;
use strict;

my $filename = 'dhcpd.conf';
my @entr;

open(my $fh, '<', $filename);

#Print all none-host lines
#remove triple-hash comments
#read all host entries
while(<$fh>) {
  if ($_ =~ /^\s*#?\s*host/) {
    my $t = $_;
    chomp $t;
    $t =~ /(#?\s*host)\s+(.+)\s+\{(.*)/;
    my $s = sprintf('%5s %-24s {%s',$1,$2,$3);
    unless ($s =~ /\}/) {
      while(1){
        my $t = <$fh>;
        chomp $t;
        $s .= $t;
        last if $t =~ /\}/;
        }
      }
    push @entr, $s;  
    }
  else {
    next if $_ =~ /###/;
    print $_;
    }
  }
close($fh);

#Extract net names
my $lines;
foreach my $e (@entr) {
  $e =~ /.+\s(\d{1,3}\.\d{1,3}\.\d{1,3})\.\d{1,3}\s*;\s*\}\s*$/;
  push @{$lines->{$1}}, $e;
  }
  
#Print net & addresses  
for my $net (sort keys %{$lines}) {
  print "

######################################
###$net.x
######################################\n";
  my $str = join("\n",sort {getip($a) cmp getip($b)} @{$lines->{$net}});
  print $str;
  }



sub getip {
  my $s = shift @_;
  $s =~ /.+\.\d{1,3}\.(\d{1,3})\s*;\s*\}\s*$/;
  $s = sprintf("%03i",$1);
  return $s;
}


