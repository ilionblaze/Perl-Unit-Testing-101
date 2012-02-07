#!/usr/bin/perl
#
use strict;

use Author;
use Log::Log4perl;
Log::Log4perl->init("etc/logger.conf");
my $a = new Author;

$a->work('Great American Story','It was a dark and stormy night');

print $a->getDate . "\n";
