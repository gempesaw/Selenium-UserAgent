#! /usr/bin/perl

use strict;
use warnings;
use Test::More;
use Selenium::Remote::Driver;
use Selenium::Remote::Driver::UserAgent;

my @browsers = qw/chrome firefox/;
my @agents = qw/iphone ipad/;


foreach my $browser (@browsers) {
    foreach my $agent (@agents) {
        my $dua = Selenium::Remote::Driver::UserAgent->new(
            browserName => $browser,
            agent => $agent
        );

        my $desired = $dua->desired;
        my $driver = Selenium::Remote::Driver->new_from_caps(
            desired_capabilities => { %$desired }
        );

        my $prefix = $browser . ', ' . $agent . ': ';

        my $actual_caps = $driver->get_capabilities;
        ok($actual_caps->{browserName} eq $browser, $prefix . 'correct browser');

        my $actual_ua = $driver->execute_script('return navigator.userAgent');
        cmp_ok($actual_ua, '=~', qr/$agent/i, $prefix . 'user agent includes ' . $agent);
    }
}

done_testing;
