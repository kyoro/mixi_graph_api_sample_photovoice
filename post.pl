#!/usr/bin/perl 

use strict;
use warnings;

use JSON;
use URI;
use URI::QueryParam;
use LWP::UserAgent;


use constant {
    CONSUMER_KEY    => '07c440f6acc01d7ae8f3',
    CONSUMER_SECRET => '4da006f11b4f9b053639998129058febc520d359',
    REDIRECT_URI    => 'http://hakamastyle.net/redirect',
};

my $auth_uri = URI->new("https://mixi.jp/connect_authorize.pl");
$auth_uri->query_form_hash(
    client_id       => CONSUMER_KEY,
    response_type   => 'code',
    scope           => 'w_voice',
    display         => 'pc',
);

print "Aauthorize request in this page :\n";
print $auth_uri->as_string();
print "\n\nPlease input redirest url's 'code' parameter :\n";

my $code;
$code = <STDIN>;
chomp($code);

my $ua = LWP::UserAgent->new;

my $token_res = $ua->post('https://secure.mixi-platform.com/2/token',{
    grant_type      => "authorization_code",
    client_id       => CONSUMER_KEY,
    client_secret   => CONSUMER_SECRET,
    code            => $code,
    redirect_uri    => REDIRECT_URI,
});

my $token_res_hash = JSON::decode_json($token_res->content);
my $access_token = $token_res_hash->{access_token};

my $post_endpoint = sprintf("http://api.mixi-platform.com/2/voice/statuses/update?oauth_token=%s",$access_token);
my $post_res = $ua->post(
    $post_endpoint,
    Content_Type => 'form-data',
    Content => {
        status => 'neko neko koneko',
        photo => [ "sample.jpg" ],
    }
);

if($post_res->is_success){
    print "done.\n";
}
