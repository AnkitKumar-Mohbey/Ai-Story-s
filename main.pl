#!/usr/bin/perl

use strict;
use warnings;

# Define the website URL
my $url = "https://www.example.com";

# Extract hostname and port from the URL
my ($host, $port) = split /:/, $url;

# Default port for HTTPS is 443
$port = 443 unless defined $port;

# Create a socket
my $socket = IO::Socket::INET->new(
    PeerAddr => $host,
    PeerPort => $port,
    Proto => 'tcp',
)
or die "Couldn't create socket: $!";

# Send a GET request to the server
print $socket "GET / HTTP/1.1\r\n";
print $socket "Host: $host\r\n";
print $socket "Connection: close\r\n\r\n";

# Read the response from the server
my $response = "";
while (my $data = $socket->recv(1024)) {
  $response .= $data;
}

# Close the socket
close($socket);

# Print the first line of the response (usually the status code)
print substr($response, 0, index($response, "\r\n"));

# You can uncomment this block to print the entire response
# print $response;
