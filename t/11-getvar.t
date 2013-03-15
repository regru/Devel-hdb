use strict;
use warnings;

use lib 't';
use HdbHelper;
use WWW::Mechanize;
use JSON;

use Test::More tests => 25;

my $url = start_test_program();

my $json = JSON->new();
my $value;

my $mech = WWW::Mechanize->new();
my $resp = $mech->get($url.'continue');
ok($resp->is_success, 'continue');

$resp = $mech->post($url.'getvar', {l => 0, v => '$x'});
check_resp($resp,
        { expr => '$x', level => 0, result => 'hello' },
        'Get value of $x at level 0');

$resp = $mech->post($url.'getvar', {l => 0, v => '$y'});
check_resp($resp,
        { expr => '$y', level => 0, result => 2 },
        'Get value of $y at level 0');

$resp = $mech->post($url.'getvar', {l => 0, v => '$z'});
check_resp($resp,
        { expr => '$z', level => 0, result => { one => 1, two => 2 }},
        'Get value of $z at level 0');

$resp = $mech->post($url.'getvar', {l => 1, v => '$x'});
check_resp($resp,
        { expr => '$x', level => 1, result => 1 },
        'Get value of $x at level 1');

$resp = $mech->post($url.'getvar', {l => 1, v => '$y'});
check_resp($resp,
        { expr => '$y', level => 1, result => 2 },
        'Get value of $y at level 1');

$resp = $mech->post($url.'getvar', {l => 1, v => '$z'});
check_resp($resp,
        { expr => '$z', level => 1, result => undef },
        'Get value of $z at level 1');


sub check_resp {
    my $resp = shift;
    my $expected = shift;
    my $msg = shift;

    my $got = $json->decode($resp->content)->{data};

    ok($resp->is_success, $msg);
    is($got->{expr}, $expected->{expr}, 'Response expr matches');
    is($got->{level}, $expected->{level}, 'Level matches');
    is_deeply($got->{result}, $expected->{result},
        'Result is '.(defined($expected->{result}) ? '"'.$expected->{result}.'"' : 'undef'));
}

__DATA__
my $x = 1;
my $y = 2;
foo();
sub foo {
    my $x = 'hello',
    my $z = { one => 1, two => 2 };
    $DB::single=1;
    8;
}
