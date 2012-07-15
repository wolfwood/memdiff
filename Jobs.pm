package Jobs;

require Exporter;
@ISA = qw(Exporter);
@EXPORT = qw(enqueueJob drainQueue);

my($maxJobs, $outstandingJobs) = (4,0);

# --- job control ---
sub setMaxJobs{
		my($jbz) = @_;

		$maxJobs = $jbz;
}

sub enqueueJob{
		my($cmd) = @_;

		if($outstandingJobs >= $maxJobs){
				wait;
				$outstandingJobs--;
		}

		if(fork == 0){
				exec($cmd) || die "Couldn't spawn job \'$cmd\': $!";
		}else{
				$outstandingJobs++;
		}
}

sub drainQueue{
		while($outstandingJobs > 0){
				wait;
				$outstandingJobs--;
		}
}
