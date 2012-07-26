package Rot13;

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
    if ( my ($rot13) = $msg =~ /^!rot13 (.+)/ ) {
        $rot13 =~ tr[a-zA-Z][n-za-mN-ZA-M];
        $irc->yield( privmsg => $channel => $rot13 );
        return PCI_EAT_PLUGIN;
    }
    return PCI_EAT_NONE;
}

sub S_msg {
    my ( $self, $irc ) = splice @_, 0, 2;
    my ($nick) = ( split /!/, ${ $_[0] } )[0];
    my ($channel) = ${ $_[1] }->[0];
    my ($msg)     = ${ $_[2] };
    if ( my ($rot13) = $msg =~ /^!rot13 (.+)/ ) {
        $rot13 =~ tr[a-zA-Z][n-za-mN-ZA-M];
        $irc->yield( privmsg => $nick => $rot13 );
        return PCI_EAT_PLUGIN;
        print "\n\n\n".$msg."\n\n\n";
    }
    return PCI_EAT_NONE;
}

return 1;
