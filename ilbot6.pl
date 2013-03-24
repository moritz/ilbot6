#!/usr/bin/env perl6
use v6;
use Net::IRC::Bot;
use Net::IRC::Modules::Autoident;
use DBIish;

class Logger {
    has $.dbh;
    has $.sth = self.dbh.prepare('INSERT INTO irclog (channel, day, nick, line, timestamp) VALUES (?, ?, ?, ?, ?)');
    method said($ev) {
        self!log(channel => $ev.where, who => $ev.who, line => $ev.what);
    }
    method emoted($ev) {
        self!log(channel => $ev.where, who => '* ' ~ $ev.who, line => $ev.what);
    }
    method joined($ev) {
        self!log(channel => $ev.where, line => $ev.who ~ ' joined ' ~ $ev.where);
    }
    method parted($ev) {
        self!log(channel => $ev.where, line => $ev.who ~ ' left ' ~ $ev.where);
    }
    method quit($ev) {
        say 'quit: ', $ev;
    }
    method leave($ev) {
        say 'leave: ', $ev;
        say "Channels: ", join ', ', @( $ev.state<channels>{ $ev.where } );
    }
    method irc_ping($ev) {
        $.dbh.?ping;
    }
    method topic($ev) {
        self!log(channel => $ev.where, who => '',
            line => $ev.who ~ ' changed the topic to: ' ~ $ev.what
        );
    }

    method !log(:$channel!, :$who = '', :$line!) {
        my $date = Date.today;
        say "date: $date; channel: $channel; name: $who; line: $line";
        $.sth.execute($channel, $date, $who, $line, now.Int);
    }
    method FALLBACK($ev) {
#        say "FALLBACK: ", $ev;
    }
}

my $config_file = 'config';
my %config;
for open($config_file).lines {
    %config.push: .split(':', 2);
}

say %config.perl;
my $dbh = DBIish.connect('mysql',
    user        => %config<db-user>,
    password    => %config<db-password>,
    database    => %config<db-name>,
);



Net::IRC::Bot.new(
	nick       => 'ilbot6',
    altnicks   => qw/ilbot_6 _ilbot6/,
	server     => 'irc.freenode.org',
	channels   => qw/#perl6 #bottest42/,
	modules    => (
        Logger.new(:$dbh),
        Net::IRC::Modules::Autoident.new(password => 'wrong'),
		#Net::IRC::Modules::ACME::Unsmith.new 
	),
	debug      => True,
).run;
