package DCC;

#stutt

# the .op user channel bit is working now as expected
# the code i wrote was correct all along
# but the error was in webbot
# i needed to change POE::Component::IRC into POE::Component::IRC::State on 2 lines
# if you want you can make similiar subroutines for voicing and devoicing and such :)
# i'll work on a database thingie so we can have users on the bot in either mysql or a flatfile


use strict qw(subs vars refs);    # Make sure we can't mess up
use warnings FATAL => 'all';
use POE::Component::IRC::Plugin qw( :ALL );

sub new {
    my ($package) = shift;
    return bless {}, $package;
}

sub PCI_register {
    my ( $self, $irc ) = splice @_, 0, 2;
    $irc->plugin_register( $self, 'SERVER', qw(all) );
    return 1;
}

sub PCI_unregister {
    return 1;
}

sub S_dcc_request {
	my ( $self, $irc ) = splice @_, 0, 2;
	my $cookie = ${ $_[3] };
	$irc->yield( 'dcc_accept' => $cookie );
}

sub S_dcc_start {
	my ( $self, $irc ) = splice @_, 0, 2;
	my ( $cookie ) = ${ $_[0] };
	$irc->yield( 'dcc_chat' => $cookie => 'Welcome' );
}

sub S_dcc_chat {
        my ( $self, $irc ) = splice @_, 0, 2;
        my ( $cookie ) = ${ $_[0] };
        my ( $msg ) = ${ $_[3] };
 
        my $botnick = $irc->nick_name; #works
        if ( my ($command) = $msg =~ /^.(.+)/ ) {
                if ( my ($rest) = $command =~ /^op (.+)/ ) {
                        my ($nick, $channel) = ( split / /, $rest );
                        my $isopped = $irc->is_channel_operator( $channel, $botnick );
			my $isonchannel = $irc->is_channel_member( $channel, $nick );
			if ($isonchannel) {
	                        if ($isopped) {
        	                        $irc->yield( 'mode' => $channel => '+o' => $nick );		
	                        } else {
	                                $irc->yield( 'dcc_chat' => $cookie => "Not opped on $channel." );
        	                }
			} else {
				$irc->yield( 'dcc_chat' => $cookie => "$nick is not on $channel." );
			}
                }
        }
}

sub S_ctcp_chat {
	my ( $self, $irc ) = splice @_, 0, 2;
	my ($nick) = ( split /!/, ${ $_[0] } )[0];
	$irc->yield( 'dcc' => $nick => 'CHAT' );
}


return 1;
