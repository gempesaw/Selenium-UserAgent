# NAME

Selenium::Remote::Driver::UserAgent - Emulate mobile devices by setting user agents when using webdriver

# VERSION

version 0.03

# SYNOPSIS

    my $dua = Selenium::Remote::Driver::UserAgent->new(
        browserName => 'chrome',
        agent => 'iphone'
    );

    my $caps = $dua->caps;
    my $driver = Selenium::Remote::Driver->new_from_caps(%$caps);

# DESCRIPTION

This package will help you test your websites on mobile devices by
convincing your browsers to masquerade as a mobile device. You can
start up Firefox or Chrome with the same user agents that your mobile
browsers would send, along with the same screen resolution and layout.

Although the experience may not be 100% the same as manually testing
on an actual mobile device, the advantage of testing this way is that
you hardly need any additional infrastructure if you've already got a
webdriver testing suite set up.

NB: There is a bug in v2.42.2 of the Selenium standalone server for
Retina displays, like on MacBook Pros: the scaling for Firefox will be
doubled in both the width and height dimensions. You can either use an
older version of the standalone server or wait for a new release.

# ATTRIBUTES

## browserName

Required: specify which browser type to use. Currently, we only
support `Chrome` and `Firefox`.

    my $dua = Selenium::Remote::Driver::UserAgent->new(
        browserName => 'chrome',
        agent => 'ipad'
    );

## agent

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

## orientation

Optional: specify the orientation of the mobile device. Your options
are `portrait` or `landscape`; defaults to `portrait`.

# METHODS

## caps

Call this after initiating the ::UserAgent object to get the
capabilities that you should pass to S::R::D's's
["new\_from\_caps" in Selenium::Remote::Driver](https://metacpan.org/pod/Selenium::Remote::Driver#new_from_caps) function. This function
returns a hashref with the following keys:

- inner\_window\_size - this will set the window size immediately
after browser creation
- desired\_capabilities - this will set the browserName and the
appropriate options needed

If you're using Firefox and you'd like to continue editing the Firefox
profile before passing it to the Driver, pass in `unencoded =` 1>
as the argument to this function.

# BUGS

Please report any bugs or feature requests on the bugtracker website
https://github.com/gempesaw/Selenium-Remote-Driver-UserAgent/issues

When submitting a bug or request, please include a test-file or a
patch to an existing test-file that illustrates the bug or desired
feature.

# AUTHOR

Daniel Gempesaw <gempesaw@gmail.com>
