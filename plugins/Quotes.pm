package Quotes;

use strict qw(subs vars refs);    # Make sure we can't mess up
use warnings FATAL => 'all';
use POE::Component::IRC::Plugin qw( :ALL );
use DBI;
use Config::ApacheFormat;

my $mysql_conf;

my $dbh;
my $sth;

my $mysql_database;
my $mysql_host;
my $mysql_user;
my $mysql_password;



my $config = Config::ApacheFormat->new();
if ($ARGV[0] and -f $ARGV[0]) { 
	$config->read($ARGV[0]);

	$mysql_conf = $config->block("mysql");

	$mysql_database = $mysql_conf->get("database");
	$mysql_host = $mysql_conf->get("host");
	$mysql_user = $mysql_conf->get("user");
	$mysql_password = $mysql_conf->get("password");
}

sub new {
    my ($package) = shift;
    return bless {}, $package;
}

sub PCI_register {
    my ( $self, $irc ) = splice @_, 0, 2;
    $irc->plugin_register( $self, 'SERVER', qw(public) );
    return 1;
}

sub PCI_unregister {
    return 1;
}

#makes mysql connection
sub database_connect {
    $dbh = DBI->connect("DBI:mysql:database=" . $mysql_database . ";host=" . $mysql_host . "",
	                       $mysql_user, $mysql_password,
				    {'RaiseError' => 1});
}

sub S_public {
    my ( $self, $irc ) = splice @_, 0, 2;
    my ($nick) = ( split /!/, ${ $_[0] } )[0];
    my ($channel) = ${ $_[1] }->[0];
    my ($msg)     = ${ $_[2] };
    if ( my ($quote) = $msg =~ m/^!addquote (.+)/i ) {
		database_connect();
       	$dbh->do("INSERT INTO quotes (nick, quote, extra) VALUES ('" . $nick . "', '" . $quote . "', '" . $channel . "' )");
		$irc->yield( notice => $nick , "Your quote has been added." );
	    }
	if ( my ($search) = $msg =~ m/^!quote.?(.*)/i ) {
	    database_connect();
	    if ($search eq "") {
	        $sth = $dbh->prepare("SELECT quote FROM quotes order by rand() limit 1");
	    } else {
		$search =~ s/\*/%/g;
	        $sth = $dbh->prepare("SELECT quote FROM quotes WHERE quote LIKE '%" . $search . "%' order by rand() limit 1");
	    }
	    $sth->execute();
	    while (my $ref = $sth->fetchrow_hashref()) {
			$irc->yield( privmsg => $channel, "[Quote]: " . $ref->{'quote'});
		}
		$sth->finish();
	}
    return PCI_EAT_NONE;
}

return 1;
