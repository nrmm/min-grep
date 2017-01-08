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
  my %f_opts = ('wanted' => \&track_files, 'no_chdir' => 1);
  find(\%f_opts, $ARGV[1]);
}
else {
  # Input come from stdin.
  if($ARGV[1] eq '-') {
    search_file(regex => $regex, line_numbers => $opts{n});
    exit 0;
  }

  push @files, $ARGV[1];
}

foreach my $file (@files) {
  search_file(regex => $regex, file => $file, line_numbers => $opts{n});
}

# Search for a match.
#
sub search_file {
  my %param = (
    'line_numbers' => 0,
    'file'         => undef,
    'regex'        => qr//,
    @_
  );
  my $file = undef;

  if($param{file}) {
    unless(open $file, "<$param{file}") {
      print STDERR "Error: couldn't open `$param{file}'!";
      return;
    }
  }
  else{
    $file = \*STDIN;
  }

  my @fmt_arg = ();
  my $fmt_str = '';

  if($param{file}) {
    push @fmt_arg, $param{file};
    $fmt_str = '%s:';
  }

  if($param{line_numbers}) {
    $fmt_str .= '%d:';
  }

  $fmt_str .= "%s\n";

  my $line_no = 1;

  while(<$file>) {
    chomp;

    if(/$param{regex}/) {
      if($param{line_numbers}) {
        printf $fmt_str, (@fmt_arg, $line_no, $_);
      }
      else {
        printf $fmt_str, (@fmt_arg, $_);
      }
    }

    $line_no += 1;
  }
}

# Find all files under a given directory.
#
sub track_files {
  unless(-f $File::Find::name) {
    return;
  }
  
  push @files, $File::Find::name;
}

# Help message.
#
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
