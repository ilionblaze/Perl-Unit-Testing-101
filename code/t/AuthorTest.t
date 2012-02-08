package AuthorTest;
use strict;
use base qw(Test::Class);
use Test::More;
use Test::MockModule;
use Test::Fatal;
use DBI;
use Test::Mock::Cmd 'qr' => \&backTicks;
use Author;

# Test Writer is a custom class
# specifically for running tests on modules
# that use Writer
use Test::Writer;

# Created the backticks mock function
sub backTicks {

	return 'This is a mock!';

}

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

	is($a->getDate, 'This is a mock!', 'Backticks mocked correctly!');

}

# We're going to test the database calls now with the help of DBD::Mock
# We use it just like any regular DB handle.

sub test_updateNovel : Test(5) {

	my $t = shift;

	my $a = new Author;

	# Create the DBI:Mock handle
	my $dbh = DBI->connect("DBI:Mock:", "", "");

	# Call a function that will run a query
	$a->updateNovel($dbh, '1998-12-26', 35000);

	# Get the history of the DBH
	my $history = $dbh->{mock_all_history};

	# First let's see if the correct number of statements were executed
	# We'll use is instead of okay because if it's not we want to see
	# how many were!
	is(scalar(@{$history}), 1, 'Correct number of statements executed');

	# We're now going to check the statement is what we expect
	my $update = $history->[0];

	is($update->statement, 'Update novelTracking SET last_worked = ?, word_count = ?', 'Update Statement is correct.');

	# Let's see what params were passed in
	my $params = $update->bound_params;

	# Check the number
	is(scalar(@{$params}), 2, 'Correct number of parameters bound');

	# And check their values
	is($params->[0], '1998-12-26', 'Date parameter is correct');
	is($params->[1], 35000, 'Word count parameter is correct');

	# Reset the handle for future operations
	$dbh->{mock_clear_history} = 1;

}

# Let's show what you can do with some select statements too

sub test_getNovelStats : Test(6) {

	my $t = shift;

	my $a = new Author;

	# Create the DBI:Mock handle
	my $dbh = DBI->connect("DBI:Mock:", "", "", { RaiseError => 1, PrintError => 0 });

	# We'll use this array to verify the results.
	my @res = (
			['2012-01-01', 16257],
			['2012-01-03', 86765],
			['2012-01-23', 63762],
	);

	# We're going to add in a result set for our specific query.
	# Remember, we could just make this generic for any query.
	$dbh->{mock_add_resultset} = {
		sql => 'Select last_worked,word_count FROM novelTracking',
		results => [
			['last_worked','word_count'],
			['2012-01-01', 16257],
			['2012-01-03', 86765],
			['2012-01-23', 63762],
		], 
	};

	# Call a function that will run a query
	my ($totalWords, @stats) = $a->getNovelStats($dbh);

	# We'll verify the function results
	is_deeply(\@stats, \@res, 'Results match');

	# Let's do an okay for numerical comparison
	ok($totalWords == 166784, 'Correct number of words');

	# Get the history of the DBH
	my $history = $dbh->{mock_all_history};

	# Should be one query
	is(scalar(@{$history}), 1, 'Correct number of select statements executed');

	# Check the query itself
	my $select = $history->[0];
	is($select->statement, 'Select last_worked,word_count FROM novelTracking', 'Select statement is correct');

	# There should be no bound params
	is(scalar(@{$select->bound_params}), 0, 'No parameters bound');

	# Reset the handle for future operations
	$dbh->{mock_clear_history} = 1;

	# Let's get tricky and see what happens when a statement fails
	$dbh->{mock_add_resultset} = {
		sql => 'Select last_worked,word_count FROM novelTracking',
		results => DBD::Mock->NULL_RESULTSET,
		failure => [ 8675309, 'I got it!' ],
	};

	my $exp = exception { ($totalWords, @stats) = $a->getNovelStats($dbh); };

	like($exp, qr/I got it!/, 'Query failed and died with correct error');
}

1;
