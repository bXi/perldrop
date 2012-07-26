#!/usr/bin/perl

use warnings;
use strict;

use lib './plugins';
use IO::Handle;
use POE;
use POE::Component::IRC::State;	
use POE::Component::IRC::Plugin::Connector;
use POE::Component::IRC::Plugin::BotTraffic;
use Proc::Daemon;
use Proc::PID::File;
use Config::ApacheFormat;
use Cwd;

my $pwd = cwd();

my $config;
my $irc_conf;
my $mysql_conf;

my $debug;

my $enable_logs;

my $shutdown;
my @plugins;

my @config_connections;
my @connections;

my @irc_channels;
my $irc_nick;
my $irc_altnick;
my $irc_ident;
my $irc_realname;
my $irc_server;
my $irc_port;
my $irc_flood;
my $irc_nataddress;
my $irc_dccports;

if (@ARGV) {
	if (-f $ARGV[0]) {
		$config = Config::ApacheFormat->new();
		$config->read($ARGV[0]);
		#$mysql_conf = $config->block("mysql");
		$debug = $config->get("debug");
		$enable_logs = $config->get("enable_logs");
		@plugins = $config->get("plugins");

		@config_connections = $config->get('connection');

		#for (@config_connections) {
		#	print $_->[1];
		#}

		$irc_conf = $config->block("connection" => @config_connections->[0]->[1]);
		@irc_channels = $irc_conf->get("channels");
		$irc_altnick = $irc_conf->get("altnick");
		$irc_nick = $irc_conf->get("nick");
		$irc_ident = $irc_conf->get("ident");
		$irc_realname = $irc_conf->get("realname");
		$irc_server = $irc_conf->get("server");
		$irc_port = $irc_conf->get("port");
		$irc_flood = $irc_conf->get("flood");
		$irc_nataddress = $irc_conf->get("nataddress");
		$irc_dccports = $irc_conf->get("dccports");
		
		if ($ARGV[1] and $ARGV[1] eq "--debug") {
			$debug = 1;
		}
		
		if ($ARGV[1] and $ARGV[1] eq "stop") {
			my $pid = Proc::PID::File->running(dir => $pwd, name => $irc_nick);
			unless ($pid) { 
				print "Not already running!";
				exit;
			}
			kill(2,$pid);
			print "Stop signal sent!\n";
			exit;
		}
		
	} else {
		print "$ARGV[0] is not a valid file.\n";
		exit;
	}
} else {
	print "No configuration file suplied. Use \"$0 bot.conf\" to start your bot.\n";
	exit;
} 

$irc_dccports =~ s/:/../;

$SIG{INT} = \&closeb;


my @dcc_ports = eval $irc_dccports;

if ($debug == 0) {
	print "Becoming a daemon...\n";
	Proc::Daemon::Init;
	chdir($pwd);
}

if (Proc::PID::File->running(dir => $pwd, name => $irc_nick) ) { 
	print "Already running! remove ".$irc_nick.".pid if your sure that its not running.\n" ;
	exit;
}


my ($irc) = POE::Component::IRC::State->spawn();

$irc->plugin_add( 'BotTraffic', POE::Component::IRC::Plugin::BotTraffic->new() );

POE::Session->create(
	inline_states => {
		_start				=> \&bot_start,
		_default			=> \&debug,
		irc_001				=> \&on_connect,
		irc_433				=> \&use_altnick,
		irc_ping			=> \&ping,
		irc_kick			=> \&kick_handler,
		irc_msg				=> \&core_msg,
		irc_disconnected	=> \&bot_disconnected,
		irc_error			=> \&bot_disconnected,
		_stop				=> \&closeb
	},
);


my $module_class;
my %module;

foreach $module_class (@plugins) { 
	eval "use $module_class"; 
	die if $@; 
	$module{$module_class} = $module_class->new(); 
	$irc->plugin_add($module_class, $module{$module_class});
}

my $plugin_list = $irc->plugin_list();

sub core_msg
{
    my ( $kernel, $who, $where, $msg ) = @_[ KERNEL, ARG0, ARG1, ARG2 ];
    my $nick = ( split /!/, $who )[0];
    my $channel = $where->[0];
    if ( my ($command) = $msg =~ /^!reload ([A-Za-z0-9]+)/ ) {
		$irc->plugin_del($command);
		delete $INC{$command . ".pm"};
		delete $INC{"plugins/" . $command . ".pm"};
		eval "use $command";
		$module{$command} = $command->new(); 
		$irc->plugin_add($command, $module{$command});
		$irc->yield( privmsg => $nick => "Module: " . $command . " reloaded." );
	}
}

sub closeb {
	$irc->yield( 'quit' => "Testing my fucking bot." );
	$shutdown = "yes";
}

sub bot_disconnected {
	if ($shutdown eq "yes") {
		exit;
	}
}

sub write_log {
	my ( $message ) = @_;
	open(DAT, '>>debug.log') or die "Couldnt open log file: $!";
	print DAT $message;
	close(DAT);
}

sub debug {
	if ($debug == 1) {
		my ( $event, $args ) = @_[ ARG0 .. $#_ ];
		print "unhandled $event\n";
		my $arg_number = 0;
		foreach (@$args) {
			print "  ARG$arg_number = ";
			if ( ref($_) eq 'ARRAY' ) {
				print "$_ = [", join ( ", ", @$_ ), "]\n";
			}
			else {
				 print defined $_ ? "'$_'" : "''", "\n";
			}
			$arg_number++;
		}
	}
	return 0;
}

sub bot_start {
	my $kernel  = $_[KERNEL];
	my $heap	= $_[HEAP];
	my $session = $_[SESSION];
	$irc->yield( register => "all" );
	$irc->plugin_add( 'Connector' => POE::Component::IRC::Plugin::Connector->new() );
	$irc->yield( connect => {
			Nick		=> $irc_nick,
			Username	=> $irc_ident,
			Ircname		=> $irc_realname,
			Server		=> $irc_server,
			Port		=> $irc_port,
			Flood		=> $irc_flood,
			NATAddr		=> $irc_nataddress,
			DCCPorts	=> \@dcc_ports,
		}
	);
	$_[KERNEL]->delay( 'lag-o-meter' => 60 );
}

sub kick_handler {
	my ( $event, @args ) = @_[ ARG0 .. $#_ ];
	if ($irc_nick eq $args[1]) {
		$irc->yield( join => $args[0]);
	}
}


sub on_connect {
	$irc->yield( join => $_ ) for @irc_channels;
}

sub use_altnick {
	$irc->yield( nick => $irc_altnick );
}

sub lagometer {
	$_[KERNEL]->delay( 'lag-o-meter' => 60 );
}

sub ping {
	#empty function to remove the irc_ping debug event
}

$poe_kernel->run();
exit 0;
