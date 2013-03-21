#!/usr/bin/env perl6
use v6;
use Net::IRC::Bot;
use Net::IRC::Modules::Autoident;

class Logger {
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
    method topic($ev) {
        self!log(channel => $ev.where, who => '',
            line => $ev.who ~ ' changed the topic to: ' ~ $ev.what
        );
    }

    method !log(:$channel!, :$who = '', :$line!) {
        my $date = Date.today;
        say "date: $date; channel: $channel; name: $who; line: $line";
    }
    method FALLBACK($ev) {
#        say "FALLBACK: ", $ev;
    }
}

Net::IRC::Bot.new(
	nick       => 'ilbot6',
    altnicks   => qw/ilbot_6 _ilbot6/,
	server     => 'irc.freenode.org',
	channels   => qw/#perl6 #bottest42/,
	modules    => (
        Logger.new,
        Net::IRC::Modules::Autoident.new(password => 'wrong'),
		#Net::IRC::Modules::ACME::Unsmith.new 
	),
	debug      => True,
).run;
