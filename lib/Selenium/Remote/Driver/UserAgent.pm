use strict;
use warnings;
package Selenium::Remote::Driver::UserAgent;

# ABSTRACT: Emulate mobile devices by setting user agents when using webdriver
use Moo;
use Cwd qw/abs_path/;
use JSON;
use Selenium::Remote::Driver::Firefox::Profile;

=head1 SYNOPSIS

    my $dua = Selenium::Remote::Driver::UserAgent->new(
        browserName => 'chrome',
        agent => 'iphone'
    );

    my $desired = $dua->desired;
    my $driver = Selenium::Remote::Driver->new_from_caps(
        desired_capabilities => { %$desired }
    );

=head1 DESCRIPTION

This package will help you test your websites on mobile devices by
convincing your browsers to masquerade as a mobile device. You can
start up Firefox or Chrome with the same user agents that your mobile
browsers would send, along with the same screen resolution and layout.

Although the experience may not be 100% the same as manually testing
on an actual mobile device, the advantage of testing this way is that
you hardly need any additional infrastructure if you've already got a
webdriver testing suite set up.

=attr browserName

Required: specify which browser type to use. Currently, we only
support Chrome and Firefox.

    my $dua = Selenium::Remote::Driver::UserAgent->new(
        browserName => 'chrome',
        agent => 'ipad'
    );

=cut

has browserName => (
    is => 'rw',
    required => 1
);

=attr agent

Required: specify which mobile device type to emulate. Your options
are:

    iphone
    ipad_seven
    ipad
    android_phone
    android_tablet

Usage looks like:

    my $dua = Selenium::Remote::Driver::UserAgent->new(
        browserName => 'chrome',
        agent => 'ipad_seven'
    );

=cut

has agent => (
    is => 'rw',
    required => 1
);

has _firefox_options => (
    is => 'ro',
    lazy => 1,
    builder => sub {
        my ($self) = @_;

        my $profile = Selenium::Remote::Driver::Firefox::Profile->new;
        $profile->set_preference(
            'general.useragent.override' => $self->_get_user_agent_string
        );

        return {
            firefox_profile => $profile->_encode
        };
    }
);


has _chrome_options => (
    is => 'ro',
    lazy => 1,
    builder => sub {
        my ($self) = @_;

        return {
            chromeOptions => {
                'args' => [
                    '--user-agent=' . $self->_get_user_agent_string
                ]
            }
        }
    }
);

has desired => (
    is => 'ro',
    lazy => 1,
    builder => sub {
        my ($self) = @_;

        my $options;
        if ($self->browserName =~ /chrome/i) {
            $options = $self->_chrome_options;

        }
        elsif ($self->browserName =~ /firefox/i) {
            $options = $self->_firefox_options;
        }

        return {
            browserName => $self->browserName,
            %$options
        };
    }
);

has _specs => (
    is => 'ro',
    builder => sub {
        my $devices_file = abs_path(__FILE__);
        $devices_file =~ s/UserAgent\.pm$/devices.json/;

        my $devices;
        {
            local $/ = undef;
            open (my $fh, "<", $devices_file);
            $devices = from_json(<$fh>);
            close ($fh);
        }

        return $devices;
    }
);

sub _get_user_agent_string {
    my ($self) = @_;

    my $specs = $self->_specs;
    my $agent = $self->agent;

    return $specs->{$agent}->{user_agent};
}



1;
