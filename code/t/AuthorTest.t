package AuthorTest;
use strict;
use base qw(Test::Class);
use Test::More;
use Test::MockModule;
use Test::Fatal;
#use Test::Mock::Cmd 'qr' => \&{ return 'This is a mock!'; };
use Author;

# Test Writer is a custom class
# specifically for running tests on modules
# that use Writer
use Test::Writer;

# We'll use this to store some logging messages
my @infores;

# set this to 0 to prevent skipping
my $skip = 1;

# Let's just mock the whole Log::Log4perl::Logger module.
# We can mock functions as we need them.
my $log = new Test::MockModule('Log::Log4perl::Logger');

sub create_Author_Test : Test(setup) {

	my $t = shift;

}

sub destroy_Author_Test : Test(teardown) {

	my $t = shift;

}

# A good sample of basic tests
sub test_work : Test(7) {

	my $t = shift;
	# This will hold our Author object but not yet!
	my $a;

	# first let's make sure it is not defined
	ok(!defined($a), '$a is not defined.');

	# We'll skip a test that always failes. 
	SKIP: {
		skip 'fail test', 1 unless $skip == 0;
		# This next test is going to fail. The purpose is twofold:
		# A) to show failure syntax
		# B) to show why we used the above syntax and not this
		is($a, 0, '$a is 0');
	};

	$log->mock('info' => sub { push @infores, $_[1]; return 1; } );

	# We will create an object and test it's new() method
	$a = new_ok('Author');

	# Let's double check that it's not undef
	ok(defined($a), "Author object defined");

	$a->work('Great American Story','It was a dark and stormy night');

	# A simple is() test - good for scalars or if you know the position you want to check
	# in an array
	is($infores[0], 'Wrote: Great American Story: It was a dark and stormy night', 'Logged correct info');

	# Access the array in Test::Writer
	my $written = Test::Writer::getWritten;

	# like runs a regular expression. We can use that to search an array for a value
	like("@$written", qr/It was a dark and stormy night/, 'Wrote proper text');

	# We'll create a structure to compare against for our next test
	my $wrote = ['Great American Story', 'It was a dark and stormy night'];

	# is_deeply will walk a full structure whether array, hash, class
	is_deeply($written, $wrote);

}

# Lets test an exception!
# This should work on logdie() as well

sub test_procrastinate : Test(1) {

	my $t = shift;

	my $a = new Author;
	my $exp = exception { $a->procrastinate; };

	like($exp, qr/Stop that!/, 'Exception test');

}

# We want to make sure this fucntion returns the correct object type
# Since we aren't creating a new object of that type, we're going to
# use isa_ok();
#
# We'll then do a similar test with is_deeply();

sub test_getWriter : Test(2) {

	my $t = shift;

	my $a = new Author;

	isa_ok($a->getWriter, 'Writer');

	# If the created Writer object were more complex, we would need
	# to create a more complex object here or is_deeply would fail
	my $w = new Writer;

	is_deeply($a->getWriter, $w, 'Writer object is bare');
}

# All we're showing here is that overloading backticks works
# If we'd written a smarter function we could check inputs,
# which command was called, and whatever else we can imagine.

sub test_getDate : Test(1) {

	my $t = shift;

	my $a = new Author;

#	is($a->getDate, 'This is a mock!', 'Backticks mocked correctly!');

}

1;
