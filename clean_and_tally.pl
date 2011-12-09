#!/usr/bin/perl

# step 2 of the pipeline

# turn list of files generated in step 1 to a set of paths,
# and tally up total storage needed.
use File::Find;
use File::Basename 'basename';

use constant ROOT => '/';
use constant CONF  => '/browser_data/conf';
use constant DUMPS => '/browser_data/mysql_dumps_new';
use constant GB   => 1_073_741_824;

use strict;
my (%Totals,@Paths);
while (<>) {
	chomp;
	my $path =  ROOT eq '/' ? $_ : ROOT . $_;
	-e $path or next;
	push @Paths,$path;
	my $species = (split '/',$_)[2];
	$Totals{$species} += -s $path;
}

my $total;
for my $s (sort keys %Totals) {
	printf STDERR "# %-20s %8.2f GB\n",$s,$Totals{$s}/GB;
	$total += $Totals{$s};
}
for my $path (CONF,DUMPS) {
    my $size = du($path);
    printf STDERR "# %-20s %8.2f GB\n",basename($path),$size/GB;    
    $total  += $size;
}
printf STDERR "# %-20s %8.2f GB\n",'TOTAL',$total/GB;

print CONF,"\n";
print DUMPS,"\n";
print join("\n",@Paths),"\n";
exit 0;

sub du {
    my $path = shift;
    my $total = 0;
    find({wanted => sub {
	$total += -s $File::Find::name
	    if -f $File::Find::name;},
      follow => 1},
	 $path);
    return $total;
}
