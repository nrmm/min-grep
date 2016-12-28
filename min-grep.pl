use strict;
use warnings;
use Getopt::Std;
use File::Find;

my ($regex, %opts, @files);

getopts("nhir", \%opts) or die "Error: unknown option!";

if($opts{h}) {
  usage();
  exit 0;
}

@ARGV == 2 or die "Error: missing argument option!";

$regex = defined $opts{i}? qr/$ARGV[0]/i : qr/$ARGV[0]/;

if($opts{r}) {
  unless(-d $ARGV[1]) {
    die "Error: you must specify a directory when using the -r option!";
  }
  my %f_opts = ('wanted' => \&wanted, 'no_chdir' => 1);
  find(\%f_opts, $ARGV[1]);
}
else {
  unless(-f $ARGV[1]) {
    die "Error: `$ARGV[1]' is not a file!";
  }
  push @files, $ARGV[1];
}

foreach my $file (@files) {
  my $line_no = 1;

  unless(open FILE, "<$file") {
    print STDERR "Error: couldn't open `$file'!";
	next;
  }

  while(<FILE>) {
    chomp;
	if(/$regex/) {
	  print "$file", defined $opts{n}? ",$line_no" : "", ": '$_'\n";	  
	}
	$line_no += 1;
  }

  close FILE;
}

sub wanted {
  unless(-f $File::Find::name) {
    return;
  }
  
  push @files, $File::Find::name;
}

sub usage {
  print <<EOF;
Usage:
$0 [OPTION]... <REGEX> <FILE>...

Options:
-i case insensitive
-n print line numbers
-r search for REGEX in all files under the given directory
-h show this help
EOF
}
