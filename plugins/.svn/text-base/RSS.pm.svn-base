package RSS;

#this is a basic plugin which waits for something to be said in a channel
# and then it does something with the input and msges it back


use strict qw(subs vars refs);    # Make sure we can't mess up
use warnings FATAL => 'all';
use POE::Component::IRC::Plugin qw( :ALL );
use XML::RAI;
use LWP::Simple;


my $trigger = "alistapart";

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
    if ( $msg =~ /^!$trigger/ ) {
    	
    	my $xml = get("http://www.alistapart.com/feed/rss.xml");
    	if ($xml)
    	{
    		my $rai = XML::RAI->parse_string($xml);
    		
    		
    		my $title = $rai->channel->title;
    		
    		$title =~ s/ //g;
    		foreach my $item ( @{$rai->items} )
    		{
    			my $content = $item->title;
    			my $link = $item->link;
    			
    			
    			$irc->yield( privmsg => $channel => "[$title] $content - $link" );
    		}
    	
		}
        return PCI_EAT_NONE;
    }
    return PCI_EAT_NONE;
}

return 1;
