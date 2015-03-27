#! /usr/bin/perl

use strict;

require '/var/ipfire/general-functions.pl';
require "${General::swroot}/lang.pl";
require "${General::swroot}/header.pl";

my $url='';
my %snortsettings = (
  'RULES' => '',
  'OINKCODE' => ''
);
&General::readhash("${General::swroot}/snort/settings", \%snortsettings);

my $user_name = "nobody";
$) = getgrnam($user_name);
$> = getpwnam($user_name);
$( = $);
$< = $>;

if ($snortsettings{'RULES'} eq 'subscripted') {
  $url = " https://www.snort.org/rules/snortrules-snapshot-2962.tar.gz?oinkcode=$snortsettings{'OINKCODE'}";
} elsif ($snortsettings{'RULES'} eq 'registered') {
  $url = " https://www.snort.org/rules/snortrules-snapshot-2962.tar.gz?oinkcode=$snortsettings{'OINKCODE'}";
} elsif ($snortsettings{'RULES'} eq 'community') {
  $url = " https://www.snort.org/rules/community";
} else {
  $url = "http://rules.emergingthreats.net/open/snort-2.9.0/emerging.rules.tar.gz";
}

my @df = `/bin/df -B M /var`;
foreach my $line (@df) {
  next if $line =~ m/^Filesystem/;
  if ($line =~ m/dev/) {
    $line =~ m/^.* (\d+)M.*$/;
    my @temp = split(/ +/,$line);
    if ($1 < 300) {
      print "$Lang::tr{'not enough disk space'} < 300MB, /var $1MB\n";
    } else {
      if (downloadrulesfile() == 0) {
        system("/usr/local/bin/oinkmaster.pl -v -s -u file:///var/tmp/snortrules.tar.gz -C /var/ipfire/snort/oinkmaster.conf -o /etc/snort/rules && /usr/local/bin/snortctrl restart");
      } else {
        print "Something went wrong while downloading: $url\n";
      }
    }
  }
}

sub downloadrulesfile {
  my ($peer, $peerport);
  unless (-e "${General::swroot}/red/active") {
    print $Lang::tr{'could not download latest updates'}."\n";
    return 1;
  }

  my %proxysettings=();
  &General::readhash("${General::swroot}/proxy/settings", \%proxysettings);
  if ($_=$proxysettings{'UPSTREAM_PROXY'}) {
    ($peer, $peerport) = (/^(?:[a-zA-Z ]+\:\/\/)?(?:[A-Za-z0-9\_\.\-]*?(?:\:[A-Za-z0-9\_\.\-]*?)?\@)?([a-zA-Z0-9\.\_\-]*?)(?:\:([0-9]{1,5}))?(?:\/.*?)?$/);
  }

  if ($peer) {
    return system("wget -r --proxy=on --proxy-user=$proxysettings{'UPSTREAM_USER'} --proxy-passwd=$proxysettings{'UPSTREAM_PASSWORD'} -e http_proxy=http://$peer:$peerport/ --no-check-certificate --output-document=/var/tmp/snortrules.tar.gz $url");
  } else {
    return system("wget -r --no-check-certificate --output-document=/var/tmp/snortrules.tar.gz $url");
  }
}
