#!/usr/bin/perl

use warnings;
use strict;

my $version = '0.01';
my $revision = `svn info |grep Revision`;
if ($revision) {
    chomp $revision;
    $version = "Perldrop IRC Bot " . $revision;
}

#initiate options and asign to vars
use Getopt::Long;
Getopt::Long::Configure ('bundling');
my $configuration;
my $debug = 0;
GetOptions ( 
    'config|c:s' => \$configuration,
    'debug|d:i' => \$debug,
    'help|h' => \&help
);

# help function.. shows the options
sub help {
    my $help = <<EOF;
$version

Usage: $0 [OPTIONS...]
Perldrop is an eggdrop like IRC bot written in perl.

Examples: 
  $0 --config=Perldrop.conf      # Start the bot with Perldrop.conf as configuration file.
  $0 --config=Perldrop.conf stop # Stops the bot that has been initiated with Perldrop.conf
  
Options:
  -c, --config=FILE     tell Perldrop which config file to use
  -d, --debug=[0,1]     give us verbose debugging output
  
  -?, -h, --help        show this help output
  
Report bugs to <bluepunk\@gmail.com>.
EOF
    print $help;
    exit;
}
# check if debug has a proper value
if ( $debug != 0 and $debug != 1 ) {
    print "--debug only accepts 1 or 0 as argument.\n\n";
    help();
}

# check if the config file exists
if ( !-f $configuration ) {
    print "The configuration file you specified does not exist!\n\n";
    help();
}


