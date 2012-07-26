package Seen;

#this is a basic plugin which waits for something to be said in a channel
# and then it does something with the input and msges it back


use strict qw(subs vars refs);    # Make sure we can't mess up
use warnings FATAL => 'all';
use POE::Component::IRC::Plugin qw( :ALL );

sub new {
    my ($package) = shift;
    return bless {}, $package;
}

sub PCI_register {
    my ( $self, $irc ) = splice @_, 0, 2;
    $irc->plugin_register( $self, 'SERVER', qw(public msg) );
    return 1;
}

sub PCI_unregister {
    return 1;
}

sub S_public {
    my ( $self, $irc ) = splice @_, 0, 2;
    my ($nick) = ( split /!/, ${ $_[0] } )[0];
    my ($channel) = ${ $_[1] }->[0];
    my ($msg)     = ${ $_[2] };
    my $seen_time = time() - 1272569081;

    if ( $msg =~ /^$irc->{'nick'}: test_time$/ ) {
# 	my $seen_time_years = int $seen_time / 60 / 60 / 24 / 365.25 + 1970;
	my $seen_time_human = localtime($seen_time);
	$irc->yield( privmsg => $channel => $seen_time_human );
        return PCI_EAT_PLUGIN;
    }
    return PCI_EAT_NONE;
}

return 1;
