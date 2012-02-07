clean:
	rm -rf t/cover_db t/output.tap 

coverage:
	perl -w -MDevel::Cover=-db,t/cover_db,-ignore_re,Test,+inc,Test,-silent,l t/runTests.t
	cover t/cover_db

test:
	perl -w t/runTests.t 2> /dev/null | tee t/output.tap
