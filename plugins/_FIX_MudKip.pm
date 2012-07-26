package MudKip;

#this is a basic plugin which waits for something to be said in a channel
# and then it does something with the input and msges it back


use strict qw(subs vars refs);    # Make sure we can't mess up
use warnings FATAL => 'all';
use POE::Component::IRC::Plugin qw( :ALL );

my $mode_mudkip = "0";
my $timer_mudkip = "0";

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

    if ( $msg =~ /^!mudkip$/ ) {
     $irc->yield( privmsg => $channel => "mudkip mode is $mode_mudkip, also time to next mud/kip is $timer_mudkip" );
}

    if ( $msg =~ /^!mode_mudkip.ON$/ ) {
     $mode_mudkip = "1";
     $irc->yield( privmsg => $channel => "mudkip mode enabled" );
     return PCI_EAT_PLUGIN;
    }

    if ( $msg =~ /^!mode_mudkip.OFF$/ ) {
     $mode_mudkip = "0";
     $irc->yield( privmsg => $channel => "mudkip mode disabled" );
     return PCI_EAT_PLUGIN;
    }

    if (( $msg =~ /^mud$/ ) && ( $mode_mudkip == "1")) {
     $timer_mudkip = int(rand(30)+30);
     
     my $pid = fork();
     if (not defined $pid) { print "resources not aFAILable.\n"; } 
     elsif ($pid == 0) { 
      sleep $timer_mudkip; $timer_mudkip = "0";
      $irc->yield( privmsg => $channel => "kip" );
      return PCI_EAT_PLUGIN;
      exit(0);	
     } 
     else { return PCI_EAT_PLUGIN; }
    }

   if (( $msg =~ /^kip$/ ) && ( $mode_mudkip == "1")) {
     $timer_mudkip = int(rand(30)+30);
     
     my $pid = fork();
     if (not defined $pid) { print "resources not aFAILable.\n"; } 
     elsif ($pid == 0) { 
      sleep $timer_mudkip; $timer_mudkip = "0";
      $irc->yield( privmsg => $channel => "mud" );
      return PCI_EAT_PLUGIN;
      kill ("TERM",$pid);
     } 
     else { return PCI_EAT_PLUGIN; }
    }

   return PCI_EAT_NONE;
}

sub S_msg {
    my ( $self, $irc ) = splice @_, 0, 2;
    my ($nick) = ( split /!/, ${ $_[0] } )[0];
    my ($channel) = ${ $_[1] }->[0];
    my ($msg)     = ${ $_[2] };
    return PCI_EAT_NONE;
}

return 1;
