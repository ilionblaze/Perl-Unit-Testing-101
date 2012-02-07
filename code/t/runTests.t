#!/usr/bin/perl -w

use Test::Class;
BEGIN {
	eval { require 'AuthorTest.t'; } or die ("Could not get test class: $!"); 
}

Test::Class->runtests;

