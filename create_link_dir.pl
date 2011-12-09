#!/usr/bin/perl

# step 3
# from list created by clean_and_tally, create a link directory for use
# by rsync
use File::Path 'make_path';
use File::Basename 'dirname';

mkdir './browser_data';
while (<>) {
    next if /^#/;
    chomp;
    my $dirname = dirname($_);
    make_path("./$dirname") unless -d "./$dirname";
    symlink($_,"./$_");
}
