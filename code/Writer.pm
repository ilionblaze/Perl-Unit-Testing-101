package Writer;

use strict;

sub new {
	my $class = shift;
	my $self = {};

	bless ( $self, $class );

	return $self;

}

sub w {

	my ($self, $msg) = @_;

	print "Writer says: $msg\n";

}

1;
