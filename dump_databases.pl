#!/usr/bin/perl

use strict;
use File::Find;

use constant CONF_ROOT =>'/browser_data/conf';
use constant DEST      => '/browser_data/mysql_dumps_new';

my @files = ();
find({wanted => sub {push @files,$File::Find::name if /\.conf(\.gz)?$/},
      follow => 1},
     CONF_ROOT);

my %databases;

for my $f (@files) {
    my $cmd = "zcat $f|";
    open my $in,$cmd or die "$cmd: $!";
    while (<$in>) {
	chomp;
	my ($dsn) = m/-dsn\s+(\S+)/ or next;
	$databases{$dsn}++;
    }
}

system "mkdir -p ".DEST unless -d DEST;
die "no writable destination directory ".DEST unless -w DEST;

for my $db (sort keys %databases) {
    my $dest = DEST.'/'.$db.'.sql.gz';
    warn "dumping to $dest...\n";
    system "mysqldump -unobody --opt --skip-lock-tables --compress $db | gzip -c > $dest";
}


exit 0;

