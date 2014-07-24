use strict;
use warnings;
package Selenium::Remote::Driver::UserAgent;
$Selenium::Remote::Driver::UserAgent::VERSION = '0.02';
# ABSTRACT: Emulate mobile devices by setting user agents when using webdriver
use Moo;
use JSON;
use Cwd qw/abs_path/;
use Carp qw/croak/;
use Selenium::Remote::Driver::Firefox::Profile;


has browserName => (
    is => 'rw',
    required => 1,
    coerce => sub {
        my $browser = $_[0];

        croak 'Only chrome and firefox are supported.'
          unless $browser =~ /chrome|firefox/;
        return lc($browser)
    }
);


has agent => (
    is => 'rw',
    required => 1,
    coerce => sub {
        my $agent = $_[0];

        my @valid = qw/iphone ipad_seven ipad android_phone android_tablet/;

        croak 'invalid agent' unless $agent ~~ @valid;
        return $agent;
    }
);


has orientation => (
    is => 'rw',
    coerce => sub {
        croak 'Invalid orientation; please choose "portrait" or "landscape'
          unless $_[0] =~ /portrait|landscape/;
        return $_[0];
    },
    default => 'portrait'
);

has _firefox_options => (
    is => 'ro',
    lazy => 1,
    builder => sub {
        my ($self) = @_;

        my $dim = $self->get_size;

        my $profile = Selenium::Remote::Driver::Firefox::Profile->new;
        $profile->set_preference(
            'general.useragent.override' => $self->get_user_agent
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

        my $size = $self->get_size_for('chrome');

        return {
            chromeOptions => {
                'args' => [
                    'user-agent=' . $self->get_user_agent,
                    'window-size=' . $size
                ],
                'excludeSwitches'   => [
                    'ignore-certificate-errors'
                ]
            }
        }
    }
);

has caps => (
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
            inner_window_size => $self->get_size_for('caps'),
            desired_capabilities => {
                browserName => $self->browserName,
                %$options
            }
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

sub get_user_agent {
    my ($self) = @_;

    my $specs = $self->_specs;
    my $agent = $self->agent;

    return $specs->{$agent}->{user_agent};
}

sub get_size {
    my ($self) = @_;

    my $specs = $self->_specs;
    my $agent = $self->agent;
    my $orientation = $self->orientation;

    return $specs->{$agent}->{$orientation};
}

sub get_size_for {
    my ($self, $format) = @_;
    my $dim = $self->get_size;

    if ($format eq 'caps') {
        return [ $dim->{height}, $dim->{width} ];
    }
    elsif ($format eq 'chrome') {
        return $dim->{width} . ',' . $dim->{height};
    }
}

1;

__END__

=pod

=encoding UTF-8

=head1 NAME

Selenium::Remote::Driver::UserAgent - Emulate mobile devices by setting user agents when using webdriver

=head1 VERSION

version 0.02

=head1 SYNOPSIS

    my $dua = Selenium::Remote::Driver::UserAgent->new(
        browserName => 'chrome',
        agent => 'iphone'
    );

    my $caps = $dua->caps;
    my $driver = Selenium::Remote::Driver->new_from_caps(%$caps);

=head1 DESCRIPTION

This package will help you test your websites on mobile devices by
convincing your browsers to masquerade as a mobile device. You can
start up Firefox or Chrome with the same user agents that your mobile
browsers would send, along with the same screen resolution and layout.

Although the experience may not be 100% the same as manually testing
on an actual mobile device, the advantage of testing this way is that
you hardly need any additional infrastructure if you've already got a
webdriver testing suite set up.

=head1 ATTRIBUTES

=head2 browserName

Required: specify which browser type to use. Currently, we only
support C<Chrome> and C<Firefox>.

    my $dua = Selenium::Remote::Driver::UserAgent->new(
        browserName => 'chrome',
        agent => 'ipad'
    );

=head2 agent

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

=head2 orientation

Optional: specify the orientation of the mobile device. Your options
are C<portrait> or C<landscape>; defaults to C<portrait>.

=head1 BUGS

Please report any bugs or feature requests on the bugtracker website
https://github.com/gempesaw/Selenium-Remote-Driver-UserAgent/issues

When submitting a bug or request, please include a test-file or a
patch to an existing test-file that illustrates the bug or desired
feature.

=head1 AUTHOR

Daniel Gempesaw <gempesaw@gmail.com>

=cut
