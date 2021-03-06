package Regexp::Log::Common;

use warnings;
use strict;
use base qw( Regexp::Log );
use vars qw( $VERSION %DEFAULT %FORMAT %REGEXP );

$VERSION = '0.10';

=head1 NAME

Regexp::Log::Common - A regular expression parser for the Common Log Format

=head1 SYNOPSIS

    my $foo = Regexp::Log::Common->new(
        format  => '%date %request',
        capture => [qw( ts request )],
    );

    # the format() and capture() methods can be used to set or get
    $foo->format('%date %request %status %bytes');
    $foo->capture(qw( ts req ));

    # this is necessary to know in which order
    # we will receive the captured fields from the regexp
    my @fields = $foo->capture;

    # the all-powerful capturing regexp :-)
    my $re = $foo->regexp;

    while (<>) {
        my %data;
        @data{@fields} = /$re/;    # no need for /o, it's a compiled regexp

        # now munge the fields
        ...
    }

=head1 DESCRIPTION

Regexp::Log::Common uses Regexp::Log as a base class, to generate regular
expressions for performing the usual data munging tasks on log files that
cannot be simply split().

This specific module enables the computation of regular expressions for
parsing the log files created using the Common Log Format. An example of
this format are the logs generated by the httpd web server using the
keyword 'common'.

The module also allows for the use of the Extended Common Log Format.

For more information on how to use this module, please see Regexp::Log.

=head1 ABSTRACT

Enables simple parsing of log files created using the Common Log Format or the
Extended Common Log Format, such as the logs generated by the httpd/Apache web
server using the keyword 'common'.

=cut

# default values
%DEFAULT = (
    format  => '%host %rfc %authuser %date %request %status %bytes %referer %useragent',
    capture => [ 'host', 'rfc', 'authuser', 'date', 'ts', 'request', 'req',
                 'status', 'bytes', 'referer', 'ref', 'useragent', 'ua' ],
);

# predefined format strings
%FORMAT = (
    ':default'  => '%host %rfc %authuser %date %request %status %bytes',
    ':common'   => '%host %rfc %authuser %date %request %status %bytes',
    ':extended' => '%host %rfc %authuser %date %request %status %bytes %referer %useragent',
);

# the regexps that match the various fields
%REGEXP = (
#   %a  Remote IP-address
#   %A  Local IP-address
    '%a'            => '(?#=a)\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}(?#!a)',
    '%A'            => '(?#=A)\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}(?#!A)',
    '%remoteip'     => '(?#=remoteip)\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}(?#!remoteip)',
    '%localip'      => '(?#=localip)\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}(?#!localip)',

#   %B  Size of response in bytes, excluding HTTP headers.
#   %b  Size of response in bytes, excluding HTTP headers. In CLF format, i.e. a '-' rather than a 0 when no bytes are sent.
    '%B'            => '(?#=B)\d+(?#!B)',                                   # bytes (non-CLF format)
    '%b'            => '(?#=b)-|\d+(?#!b)',                                 # bytes (CLF format)
    '%bytes'        => '(?#=bytes)-|\d+(?#!bytes)',                         # bytes (CLF and non-CLF format)

#   %D  The time taken to serve the request, in microseconds.
    '%D'            => '(?#=D)\d+(?#!D)',                                   # response time (in microseconds)
    '%time'         => '(?#=time)\d+(?#!time)',                             # response time (in microseconds)

#   %f  Filename
    '%F'            => '(?#=F)\S+(?#!F)',                                   # filename
    '%filename'     => '(?#=filename)\S+(?#!filename)',                     # filename

#   %h  Remote host
    '%h'            => '(?#=h)\S+(?#!h)',                                   # numeric or name of remote host
    '%host'         => '(?#=host)\S+(?#!host)',                             # numeric or name of remote host
    '%remotehost'   => '(?#=remotehost)\S+(?#!remotehost)',                 # numeric or name of remote host

#   %H  The request protocol
    '%H'            => '(?#=H)\S+(?#!H)',                                   # protocol
    '%protcol'      => '(?#=protocol)\S+(?#!protocol)',                     # protocol

#   %{Foobar}i  The contents of Foobar: header line(s) in the request sent to the server.
    '%referer'      => '(?#=referer)\"(?#=ref).*?(?#!ref)\"(?#!referer)',   # "referer"     from \"%{Referer}i\"
    '%useragent'    => '(?#=useragent)\"(?#=ua).*?(?#!ua)\"(?#!useragent)', # "user_agent"  from \"%{User-Agent}i\"

#   %k  Number of keepalive requests handled on this connection. Interesting if KeepAlive is being used, so that, for example, a '1' means the first keepalive request after the initial one, '2' the second, etc...; otherwise this is always 0 (indicating the initial request). Available in versions 2.2.11 and later.
    '%k'            => '(?#=k)\d+(?#!k)',                                   # keep alive requests
    '%keepalive'    => '(?#=keepalive)\d+(?#!keepalive)',                   # keep alive requests

#   %l  Remote logname (from identd, if supplied). This will return a dash unless mod_ident is present and IdentityCheck is set On.
    '%l'            => '(?#=F)\S+(?#!F)',                                   # logname
    '%logname'      => '(?#=logname)\S+(?#!logname)',                       # logname
    '%rfc'          => '(?#=rfc)\S+(?#!rfc)',                               # rfc931

#   %m  The request method
    '%m'            => '(?#=F)\S+(?#!F)',                                   # request method
    '%method'       => '(?#=method)\S+(?#!method)',                         # request method

#   %p  The canonical port of the server serving the request
    '%p'            => '(?#=p)\d+(?#!p)',                                   # port
    '%port'         => '(?#=port)\d+(?#!port)',                             # port

#   %P  The process ID of the child that serviced the request.
    '%P'            => '(?#=P)\d+(?#!P)',                                   # process id
    '%pid'          => '(?#=pid)\d+(?#!pid)',                               # process id

#   %q  The query string (prepended with a ? if a query string exists, otherwise an empty string)
    '%q'            => '(?#=q)\".*?\"(?#!q)',                                   # "query string"
    '%queryatring'  => '(?#=queryatring)\"(?#=qs).*?(?#!qs)\"(?#!queryatring)', # "query string"

#   %r  First line of request
    '%r'            => '(?#=r)\".*?\"(?#!r)',                               # "request"
    '%request'      => '(?#=request)\"(?#=req).*?(?#!req)\"(?#!request)',   # "request"

#   %s  Status. For requests that got internally redirected, this is the status of the *original* request --- %>s for the last.
    '%s'            => '(?#=s)\d+(?#!s)',                                   # status
    '%status'       => '(?#=status)\d+(?#!status)',                         # status

#   %t  Time the request was received (standard english format)
    '%t'            => '(?#=t)\[\d{2}\/\w{3}\/\d{4}(?::\d{2}){3} [-+]\d{4}\](?#!t)',                        # [date] (see note 1)
    '%date'         => '(?#=date)\[(?#=ts)\d{2}\/\w{3}\/\d{4}(?::\d{2}){3} [-+]\d{4}(?#!ts)\](?#!date)',    # [date] (see note 1)

#   %T  The time taken to serve the request, in seconds.
    '%T'            => '(?#=T)\d+(?#!T)',                                   # response time (in seconds)
    '%seconds'         => '(?#=seconds)\d+(?#!seconds)',                    # response time (in seconds)

#   %u  Remote user (from auth; may be bogus if return status (%s) is 401)
    '%u'            => '(?#=u)\S+(?#!u)',                                   # authuser
    '%authuser'     => '(?#=authuser)\S+(?#!authuser)',                     # authuser

#   %U  The URL path requested, not including any query string.
    '%U'            => '(?#U)\".*?\"(?#!U)',                                # request
    '%request'      => '(?#=request)\"(?#=req).*?(?#!req)\"(?#!request)',   # "request"

#   %v  The canonical ServerName of the server serving the request.
#   %V  The server name according to the UseCanonicalName setting.
    '%v'            => '(?#=v)\S+(?#!v)',                                   # server name
    '%V'            => '(?#=V)\S+(?#!V)',                                   # server name
    '%servername'   => '(?#=servername)\S+(?#!servername)',                 # server name


#   %X  Connection status when response is completed:
    '%X'            => '(?#=X)\S+(?#!X)',                                   # connection status (X, + or -)
    '%connection'   => '(?#=connection)\S+(?#!connection)',                 # connection status (X, + or -)

#   %I  Bytes received, including request and headers, cannot be zero. You need to enable mod_logio to use this.
#   %O  Bytes sent, including headers, cannot be zero. You need to enable mod_logio to use this.
    '%I'            => '(?#=I)\S+(?#!I)',                                   # Bytes recieved
    '%O'            => '(?#=O)\S+(?#!O)',                                   # Bytes sent
);

# note 1: date is in the format [01/Jan/1997:13:07:21 -0600]

1;

__END__

=head1 LOG FORMATS

=head2 Common Log Format

The Common Log Format is made up of several fields, each delimited by a single
space.

=over 4

=item * Apache LogFormat:

    LogFormat "%h %l %u %t \"%r\" %>s %b common

Note that the name at end, in this case 'common' is purely to identify the
format locally, so that you can create a different LogFormat for different
purposes. You then define in your virtual host a log line such as:

    CustomLog /var/www/logs/mysite-access.log common

=item * Fields:

  remotehost rfc931 authuser [date] "request" status bytes

=item * Example:

  127.0.0.1 - - [19/Jan/2005:21:47:11 +0000] "GET /brum.css HTTP/1.1" 304 0

  For the above example:
  remotehost: 127.0.0.1
  rfc931: -
  authuser: -
  [date]: [19/Jan/2005:21:47:11 +0000]
  "request": "GET /brum.css HTTP/1.1"
  status: 304
  bytes: 0

=item * Available Capture Fields

  * host
  * rfc
  * authuser
  * date
  ** ts (date without the [])
  * request
  ** req (request without the quotes)
  * status
  * bytes

=item * Method Call

    my $foo = Regexp::Log::Common->new( format  => ':common' );

=back

=head2 Extended Common Log Format

The Extended Common Log Format is made up of several fields, each delimited by
a single space.

=over 4

=item * Apache LogFormat:

    LogFormat "%h %l %u %t \"%r\" %>s %b \"%{Referer}i\" \"%{User-agent}i\" extended

=item * Fields:

  remotehost rfc931 authuser [date] "request" status bytes "referer" "user_agent"

=item * Example:

  127.0.0.1 - - [19/Jan/2005:21:47:11 +0000] "GET /brum.css HTTP/1.1" 304 0 "http://birmingham.pm.org/" "Mozilla/2.0GoldB1 (Win95; I)"

  For the above example:
  remotehost: 127.0.0.1
  rfc931: -
  authuser: -
  [date]: [19/Jan/2005:21:47:11 +0000]
  "request": "GET /brum.css HTTP/1.1"
  status: 304
  bytes: 0
  "referer": "http://birmingham.pm.org/"
  "user_agent": "Mozilla/2.0GoldB1 (Win95; I)"

=item * Available Capture Fields

  * host
  * rfc
  * authuser
  * date
  ** ts (date without the [])
  * request
  ** req (request without the quotes)
  * status
  * bytes
  * referer
  ** ref (referer without the quotes)
  * useragent
  ** ua (useragent without the quotes)

=item * Method Call

    my $foo = Regexp::Log::Common->new( format  => ':extended' );

=back

=head2 Custom Log Formats

There are any number of LogFormat lines you can define, and although this
module doesn't define all the formats, you can specify your own customer format
to extract fields as necessary.

=over 4

=item * Apache LogFormat:

Perhaps, you need to extend the 'extended' format:

    LogFormat "%h %l %u %t \"%r\" %>s %b \"%{Referer}i\" \"%{User-agent}i\" %D %v" custom

=item * Example:

This can produce a log line such as:

    103.245.44.14 - - [23/May/2014:21:38:01 +0100] "GET /volume/201109 HTTP/1.0" 200 37748 "-" "binlar_2.6.3 test@mgmt.mic" 2259292 blog.cpantesters.org

=item * Available Capture Fields

Depending on how you define the capture, this can be broken down into fields in
a few different ways.

  host rfc authuser [date] "request" status bytes "referer" "useragent" time servername

or a shorthand vareity

  h l u t "r" s b "referer" "useragent" D v

Note that referer and useragent don't have single letter counterparts, as both
the %{xxx}i and %{xxx}e format fields need to be defined explicitly. Currently
only referer and useragent are defined from the %{xxx}i field set, and none are
defined for the %{xxx}e field set. This may be expanded in the future.

=item * Method Call

To define these you would call the constructor, or the individual methods as:

    my $foo = Regexp::Log::Common->new(
        format  => '%host %rfc %authuser %date %request %status %bytes' .
                   '%referer %useragent %time %servername',
        capture => [qw( host rfc authuser ts request status bytes
                        referer useragent time servername)],
    );

or

    my $foo = Regexp::Log::Common->new(
        format  => '%h %l %u %t %r %s %b %referer %useragent %D %v',
        capture => [qw( h l u t r s b refereer useragent D v)],
    );

=back

=head1 FORMAT FIELDS

There are several format fields available, although this module does not 
support them all. The ones it does currently support are as follows:

    shorthand       => longhand (if applicable)

    '%a'            => '%remoteip'
    '%A'            => '%localip'
    '%B'            => '%bytes'
    '%b'            => '%bytes'
    '%D'            => '%time'
    '%F'            => '%filename'
    '%h'            => '%host' or '%remotehost'
    '%H'            => '%protcol'
    '%k'            => '%keepalive'
    '%l'            => '%logname' or '%rfc'
    '%m'            => '%method'
    '%p'            => '%port'
    '%P'            => '%pid'
    '%q'            => '%queryatring'
    '%r'            => '%request'
    '%s'            => '%status'
    '%t'            => '%date', also '%ts' (excluding surrounding '[]')
    '%T'            => '%seconds'
    '%u'            => '%authuser'
    '%U'            => '%request' or '%req' (excluding surrounding '"')
    '%v'            => '%servername'
    '%V'            => '%servername'
    '%X'            => '%connection'
    '%I'
    '%O'
    
    %{Foobar}i fields
    
    '%referer'      => or '%ref' (excluding surrounding '"')
    '%useragent'    => or '%ua' (excluding surrounding '"')

For a more detail explanation, please see the Apache Log Formats documentation
at L<http://httpd.apache.org/docs/2.2/mod/mod_log_config.html#formats>.

=head1 BUGS, PATCHES & FIXES

There are no known bugs at the time of this release. However, if you spot a
bug or are experiencing difficulties that are not explained within the POD
documentation, please submit a bug to the RT system (see link below). However,
it would help greatly if you are able to pinpoint problems or even supply a
patch.

Fixes are dependent upon their severity and my availability. Should a fix not
be forthcoming, please feel free to (politely) remind me by sending an email
to barbie@cpan.org .

RT: L<http://rt.cpan.org/Public/Dist/Display.html?Name=Regexp-Log-Common>

=head1 SEE ALSO

L<Regexp::Log>

=head1 CREDITS

BooK for initially putting the idea into my head, and the thread on a perl
message board, that wanted the help that was solved with this exact module.

=head1 AUTHOR

  Barbie <barbie@cpan.org>
  for Miss Barbell Productions, L<http://www.missbarbell.co.uk>

=head1 COPYRIGHT AND LICENSE

  Copyright (C) 2005-2014 Barbie for Miss Barbell Productions.

  This distribution is free software; you can redistribute it and/or
  modify it under the Artistic License v2.

=cut
