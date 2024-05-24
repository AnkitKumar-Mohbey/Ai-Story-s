#!/usr/bin/perl

use strict;
use warnings;

# Define port number and max clients
my $port = 8080;
my $max_clients = 5;

# Create a TCP socket
my $socket = IO::Socket::INET->new(
    LocalPort => $port,
    Proto => 'tcp',
    Listen => $max_clients,
)
or die "Couldn't create socket: $!";

print "Server started on port $port, accepting up to $max_clients clients\n";

# Client handling loop
while (1) {
  # Accept incoming connection
  my $client_socket = $socket->accept();
  die "Couldn't accept connection: $!" unless defined $client_socket;

  print "Client connected: ", $client_socket->peerhost, ":", $client_socket->peerport, "\n";

  # Spawn a separate thread to handle each client
  my $pid = fork();
  die "Couldn't fork: $!" unless defined $pid;

  # Child process handles the client communication
  if ($pid == 0) {
    # Close the server socket in the child process (not needed for client communication)
    close($socket);

    # Receive data from the client
    my $data = "";
    while (my $chunk = $client_socket->recv(1024)) {
      $data .= $chunk;
      last if $data =~ /\n/;  # Exit loop on newline character
    }

    # Check if client disconnected prematurely
    if (not defined $data) {
      print "Client disconnected unexpectedly\n";
    } else {
      # Modify received data (demonstrates processing)
      $data = ucfirst($data);  # Convert first letter to uppercase
      print $client_socket $data;
    }

    # Close the client socket and exit child process
    close($client_socket);
    exit(0);
  } else {
    # Parent process closes the client socket immediately (spawning a new thread for next connection)
    close($client_socket);
    print "Client connection handled by child process (PID: $pid)\n";
  }
}

# This line wouldn't be reached due to the infinite loop (included for completeness)
close($socket);

print "Server stopped\n";
