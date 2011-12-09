#!/usr/bin/perl

# step 1 of the pipeline

# get a list of all the files that need to be transferred from xfer-cloud:/browser_data
# and copied to AWS in order to run the GBrowse instance there...
use strict;
use File::Find;

use constant MYSQL_ROOT=>'/browser_data/mysql_dumps_new';
use constant CONF_ROOT =>'/browser_data/conf';
my %files;

warn "extracting binary filenames from conf files...\n";
-d CONF_ROOT or die CONF_ROOT," does not seem to be mounted. Are you running this on modencode.oicr.on.ca?";

my @files = ();
find({wanted => sub {push @files,$File::Find::name if /\.conf(\.gz)?$/},
      follow => 1},
     CONF_ROOT);
for my $f (@files) {
    print STDERR "Extracting $f...";
    my $cmd = "zcat $f|";
    my @matches;
    open my $in,$cmd or die "$cmd: $!";
    while (<$in>) {
	chomp;
	my @f = m!'?(/browser_data[^']+)'?!g or next;
	        push @matches,@f;
	}
	print STDERR scalar @matches," candidate files\n";
        $files{$_}++ foreach @matches;
}


warn "extracting binary filenames from mysql dumps...\n";

-d MYSQL_ROOT or die MYSQL_ROOT," does not seem to be mounted. Are you running this on modencode.oicr.on.ca?";
@files = glob(MYSQL_ROOT .'/*.gz');

for my $f (@files) {
    print STDERR "Extracting $f...";
    my $cmd = "zcat $f|";
    my @matches;
    open my $in,$cmd or die "$cmd: $!";
    while (<$in>) {
	chomp;
	my @f = m!'(/[^']+)'!g or next;
	        push @matches,@f;
	}
	print STDERR scalar @matches," candidate files\n";
        $files{$_}++ foreach @matches;
}

# add index files
for my $f (keys %files) {
    if ($f =~ /\.(fa|fasta)$/i) {
	$files{"$f.fai"}++;
    } elsif ($f =~ /\.bam$/i) {
	$files{"$f.bai"}++;
    }
}

print join("\n",sort keys %files),"\n";
