#!/usr/bin/perl

$SCRPATH="/home/snack/scripts";

@ciscodevice=();
@ciscodevicedone=();

sub launchCmd {
    $host = $_[0];
    $login = $_[1];
    $password = $_[2];
    $enablepassword = $_[3];
    $cmd = $_[4];
    system("nc -vnz -w 5 $host 22 >/dev/null 2>/dev/null");
    if ($? == 0) {
       $cmd="$SCRPATH/ssh.expect $host $login $password $enablepassword \"$cmd\" > /tmp/cdp";
       #print "$cmd\n";
       system($cmd);
    }
}

sub cdp {
    open(FILE1, "/tmp/cdp");
    while (<FILE1>) {
        if( $_ =~ /------------------------/ ) {
            @ciscoinfos=();
        }
        if( $_ =~ /(IP address:\s+.*)\n/ ) { 
            $ipaddress = "$1";
            push(@ciscoinfos, $ipaddress);
        }
        if( $_ =~ /Device ID:\s+(.*)/ ) {
            $deviceid = "$_";
        }
        if( $_ =~ /Platform:\s+(.*)/ ) {
            $platform = $1;
            push(@ciscoinfos, $platform);
            if ( $platform =~ /Capabilities:\s+(.*)/ ) {
                $capabilities = "$_";
                if ( $capabilities =~ /Switch IGMP/ ) {
                    push(@ciscodevice, $deviceid);
                    push(@ciscodevice, @ciscoinfos);
                    push(@ciscodevice, "-------")
                } 
            }
        }
    }
    push(@ciscodevicedone, $host);
    #foreach $ciscoid (@ciscodevice) {
    #    print "test $ciscoid\n";
    #}
}

sub print_cdp {
    foreach $ciscoid (@ciscodevice) {

        print "test $ciscoid\n";
    }
}

$host=$ARGV[0];
$login=$ARGV[1];
$password=$ARGV[2];
$enablepassword=$ARGV[3];
$cmd="show cdp neighbors detail";
launchCmd($host, $login, $password, $enablepassword, $cmd);
cdp();
print_cdp();