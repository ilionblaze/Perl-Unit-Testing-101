package Test::Log4perl;

use Log::Log4perl;
#use Log::Log4perl qw(get_logger :nowarn);
no warnings 'redefine';
#*_old_get_logger = *Log::Log4perl::Logger::get_logger;
*Log::Log4perl::info = *test_info;
#*Log::Log4perl::Logger::get_logger = *returnTrue;

my @infoLines;

#BEGIN {
sub _init {
	if (!Log::Log4perl::initialized()) {

	$conf = qq/
		log4perl.rootLogger= INFO, Screen
		log4Perl.appender.Screen = Log::Log4perl::Appender::Screen
		log4perl.appender.Screen.stderr = 0
		log4perl.appender.Screen.layout = Log::Log4perl::Layout::PatternLayout
		log4perl.appender.Screen.layout.ConversionPattern = %d{HH:mm:ss,SS} [%c %P ln:%L] %p - %m%n
		log7perl.appender.Screen.utf8 = 1
		/;


		Log::Log4perl::init( \$conf );

	} else { print "Initialized already!\n"; }

#}
}

sub test_info {

	_init();
print "Logging\n";
	for ($i = 0; $i < @_; $i++){
print @_[$i] . "\n";
		push @info, @_[$i];

	}

}

sub getInfoLines {

	return \@infoLines;

}

sub returnTrue {
	
	_init();
foreach(@_){ print "$_\n"; }
#	my $l = _old_get_logger(@_[0]);
	return $l;
}

1;
