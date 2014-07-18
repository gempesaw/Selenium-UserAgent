use strict;
use warnings;
package Selenium::Remote::Driver::UserAgent;

use Moo;
use Cwd qw/abs_path/;
use JSON;
use Selenium::Remote::Driver::Firefox::Profile;

has browserName => (
    is => 'rw',
    required => 1
);

has agent => (
    is => 'rw',
    required => 1
);

has specs => (
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

has options => (
    is => 'rw',
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



sub desired {
    my ($self) = @_;

    return $self->options;
}

sub _get_user_agent_string {
    my ($self) = @_;

    my $specs = $self->specs;
    my $agent = $self->agent;

    return $specs->{$agent}->{user_agent};
}



1;
