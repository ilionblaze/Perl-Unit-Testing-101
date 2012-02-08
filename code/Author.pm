package Author;

use strict;
use Writer;
use Log::Log4perl;

# We're going to keep the log object private

my $log = Log::Log4perl::get_logger(__PACKAGE__);

# The proper way to test is with new_ok()

sub new {
	my $class = shift;
	my $self = {};

	$self->{writer} = new Writer();

	bless ( $self, $class );

	return $self;

}

# A simple method but we'll get a good number of tests!

sub work {

	my ($self, $title, $line) = @_;

	$self->{writer}->w($title);
	$self->{writer}->w($line);

	$log->info("Wrote: $title: $line");
}

# Here's something that will die
# Test::Fatal helps here

sub procrastinate {

	my $self = shift;

	die("Stop that!");

}

# We want a method that returns an object
# A good candidate for isa_ok()

sub getWriter {

	my $self = shift;

	return $self->{writer};

}

# Obviously a very silly subroutine but we need to illustrate
# how to overload backticks

sub getDate {

	my $self = shift;

	my $date = `date`;

	chomp($date);

	return $date;

}

# Imagine we have a table that tracks the work we've done on
# our masterpiece. It has two columns: date and int.

sub updateNovel {

	my $self = shift;
	my $dbh = shift;
	my $date = shift;
	my $wc = shift;

	my $sth = $dbh->prepare("Update novelTracking SET last_worked = ?, word_count = ?") || $log->logdie ("Could not prepare statement: " . $dbh->errstr);

	$sth->execute($date, $wc) || $log->logdie ("Could not execute: " . $dbh->errstr);

}

sub getNovelStats {

	my $self = shift;
	my $dbh = shift;
	my $totalWc = 0;
	my @stats = ();

	my $sth = $dbh->prepare("Select last_worked,word_count FROM novelTracking") || $log->logdie ("Could not prepare statement: " . $dbh->errstr);

	$sth->execute() || $log->logdie ("Could not execute: " . $dbh->errstr);

	while ( my @row = $sth->fetchrow_array ) {

		push(@stats, \@row);
		$totalWc += $row[1];

	}

	return $totalWc, @stats;

}

1;
