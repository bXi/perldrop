package Logfile;

use strict qw(subs vars refs);    # Make sure we can't mess up
use warnings FATAL => 'all';
use POE::Component::IRC::Plugin qw( :ALL );
use POE::Component::IRC::State;

my $pwd;
chomp($pwd = `pwd`);

sub new {
    my ($package) = shift;
    return bless {}, $package;
}

sub PCI_register {
    my ( $self, $irc ) = splice @_, 0, 2;
    $irc->plugin_register( $self, 'SERVER', qw( all ) );
    return 1;
}

sub PCI_unregister {
    return 1;
}

sub timestamp {
	my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime time;
	if ($hour < 10) { $hour = "0".$hour; }
	if ($min < 10) { $min = "0".$min; }
	my $ts = "[".$hour.":".$min."]";
	return $ts;
}

sub write_log {
	my ( $channel, $message ) = @_;
	open(DAT, '>>'.$pwd.'/logs/'.$channel.'.log') or die "Couldnt open log file: $!";
	print DAT $message; #print DAT $message
	close(DAT);
}

sub S_public {
    my ( $self, $irc ) = splice @_, 0, 2;
    my ($nick) = ( split /!/, ${ $_[0] } )[0];
    my ($channel) = ${ $_[1] }->[0];
    my ($msg)     = ${ $_[2] };
	write_log($channel, timestamp." <".$nick."> ".$msg."\n");
    return PCI_EAT_NONE;
}

sub S_bot_public {
    my ( $self, $irc ) = splice @_, 0, 2;
    my ($nick) = ( split /!/, ${ $_[0] } )[0];
    my ($channel) = ${ $_[1] }->[0];
    my ($msg)     = ${ $_[2] };
        write_log($channel, timestamp." <".$nick."> ".$msg."\n");
    return PCI_EAT_NONE;
}

sub S_ctcp_action {
    my ( $self, $irc ) = splice @_, 0, 2;
    my ($nick) = ( split /!/, ${ $_[0] } )[0];
    my ($channel) = ${ $_[1] }->[0];
    my ($msg)     = ${ $_[2] };
    write_log($channel, timestamp." Action: ". $nick." ".$msg."\n");
    return PCI_EAT_NONE;
}

sub S_topic {
    my ($self, $irc) = splice @_, 0,2;
    my ($nick) = ( split /!/, ${ $_[0] } )[0];
    my ($channel) = ${ $_[1] };
    my ($msg)     = ${ $_[2] };
    write_log($channel, timestamp." Topic changed on ".$channel." by ".$nick.": ".$msg."\n");
    return PCI_EAT_NONE;
}

sub S_kick {
    my ($self, $irc) = splice @_, 0,2;
    my ($nick) = ( split /!/, ${ $_[0] } )[0];
    my ($channel) = ${ $_[1] };
    my ($victim) = ${ $_[2] };
    my ($msg)     = ${ $_[3] };
    write_log($channel, timestamp." ".$victim." kicked from ".$channel." by ".$nick.": ".$msg."\n");
    return PCI_EAT_NONE;
}

sub S_join {
    my ($self, $irc) = splice @_, 0,2;
    my ($nick) = ( split /!/, ${ $_[0] } )[0];
    my ($host) = ( split /!/, ${ $_[0] } )[1];
    my ($channel) = ${ $_[1] };
    write_log($channel, timestamp." ".$nick." (".$host.") joined ".$channel."\n");
    return PCI_EAT_NONE;
}

sub S_part {
    my ($self, $irc) = splice @_, 0,2;
    my ($nick) = ( split /!/, ${ $_[0] } )[0];
    my ($host) = ( split /!/, ${ $_[0] } )[1];
    my ($channel) = ${ $_[1] };
    write_log($channel, timestamp." ".$nick." (".$host.") left ".$channel."\n");
    return PCI_EAT_NONE;
}

sub S_quit {
    my ($self, $irc) = splice @_, 0,2;
    my ($nick) = ( split /!/, ${ $_[0] } )[0];
    my ($host) = ( split /!/, ${ $_[0] } )[1];
    my ($reason) = ${ $_[1] };
    foreach my $channel ( keys %{ $irc->channels() } ) {
        write_log($channel, timestamp." ".$nick." (".$host.") left irc: ".$reason."\n");
    }
    return PCI_EAT_NONE;
}

sub S_nick {
    my ($self, $irc) = splice @_, 0,2;
    my ($oldnick) = ( split /!/, ${ $_[0] } )[0];
    my ($newnick) = ${ $_[1] };
    foreach my $channel ( keys %{ $irc->channels() } ) {
        write_log($channel, timestamp." Nick change: ". $oldnick." -> ".$newnick."\n");
    }
    return PCI_EAT_NONE;
}

sub S_mode {
	my ($self, $irc) = splice @_, 0, 2;
	my ($nick,$userhost) = split(/!/, ${ $_[0] });
	my ($channel) = ${ $_[1] };
	my ($mode) = join(' ', map { $$_ } @_[ 2 .. $#_ ] );
	write_log($channel, timestamp." ".$channel.": mode change '".$mode."' by ".$nick."!".$userhost."\n");
}

return 1;
