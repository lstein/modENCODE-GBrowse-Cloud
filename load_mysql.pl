#!/usr/bin/perl                                                                                                                                                                       
use strict;
use constant  MYSQL_ROOT => '/modencode/browser_data/mysql_dumps_new';

my @dumps = glob(MYSQL_ROOT . '/*gz');
for my $d (@dumps) {
   my ($dbname) = $d =~ m!([^/]+)\.sql\.gz$!;
   $dbname or die "Can't find dbname from $d";
   system "mysqladmin -uroot -pmodencode create $dbname";
   system "zcat $d | mysql -uroot -pmodencode $dbname";
}
