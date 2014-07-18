#! /usr/bin/perl

use strict;
use warnings;
use JSON;
use Test::More;
use IO::Socket::INET;
use Test::ParallelSubtest max_parallel => 5;
use Selenium::Remote::Driver;
use Selenium::Remote::Driver::UserAgent;

my @browsers = qw/chrome firefox/;
my @agents = qw/iphone ipad_seven ipad android_phone android_tablet/;
my @orientations = qw/portrait landscape/;

my $sock = IO::Socket::INET->new(
    PeerAddr => 'localhost',
    PeerPort => 4444
);

plan skip_all => "Author tests not required for installation." unless $ENV{RELEASE_TESTING};
plan skip_all => "no remote driver server?" unless $sock;

foreach my $browser (@browsers) {
    foreach my $agent (@agents) {
        foreach my $orientation (@orientations) {
            my $test_prefix = join(', ', ($browser, $agent, $orientation));
            bg_subtest $test_prefix => sub {
                my $dua = Selenium::Remote::Driver::UserAgent->new(
                    browserName => $browser,
                    agent => $agent,
                    orientation => $orientation
                );

                my $caps = $dua->caps;

                my $driver = Selenium::Remote::Driver->new_from_caps(%$caps);
                my $actual_caps = $driver->get_capabilities;

                ok($actual_caps->{browserName} eq $browser, 'correct browser');

                my $details = $driver->execute_script(qq/return {
                    agent: navigator.userAgent,
                    width: window.innerWidth,
                    height: window.innerHeight
                }/);

                # useragents with underscores in them need to be trimmed.
                # for example, ipad_seven only has 'iPad' in its user
                # agent, not 'ipad_seven'
                my $expected_agent = $agent;
                $expected_agent =~ s/_.*//;
                cmp_ok($details->{agent} , '=~', qr/$expected_agent/i, 'user agent includes ' . $agent);
                cmp_ok($details->{width} , '==', $dua->get_size->{width}, 'width is correct.');
                cmp_ok($details->{height}, '==', $dua->get_size->{height} , 'height is correct.');
            };
        }
    }
}


done_testing;
