#! /usr/bin/perl

use strict;
use warnings;
use Test::More;
use Selenium::Remote::Driver;
use Selenium::Remote::Driver::UserAgent;

my @browsers = qw/chrome firefox/;
my @agents = qw/iphone ipad_seven ipad android_phone android_tablet/;

HAPPY_PATH: {
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

            # useragents with underscores in them need to be trimmed.
            # for example, ipad_seven only has 'iPad' in its user
            # agent, not 'ipad_seven'
            my $expected_agent = $agent;
            $expected_agent =~ s/_.*//;
            cmp_ok($actual_ua, '=~', qr/$expected_agent/i, $prefix . 'user agent includes ' . $agent);
        }
    }
}

INVALID_ARGUMENTS: {
    eval {
        my $bad = Selenium::Remote::Driver::UserAgent->new(
            browserName => 'invalid',
            agent => 'iphone'
        );
    };

    ok( $@ =~ /coercion.*failed/, 'browser name is coerced');
}

done_testing;
