package Test::Writer;

use Writer;

*Writer::w = *plagarize;

my @wrote = ();

sub plagarize {
	for ($i = 1; $i < @_; $i++){

		push(@wrote,$_[$i]);

	}

}

sub getWritten {

	return \@wrote;

}

1;
