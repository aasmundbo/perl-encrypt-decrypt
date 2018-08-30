#!/usr/bin/perl
# BSD 3-Clause License
# 
# Copyright (c) 2018, aasmundbo
# All rights reserved.
# 
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
# 
# * Redistributions of source code must retain the above copyright notice, this
#   list of conditions and the following disclaimer.
# 
# * Redistributions in binary form must reproduce the above copyright notice,
#   this list of conditions and the following disclaimer in the documentation
#   and/or other materials provided with the distribution.
# 
# * Neither the name of the copyright holder nor the names of its
#   contributors may be used to endorse or promote products derived from
#   this software without specific prior written permission.
# 
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
# DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
# FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
# SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
# CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
# OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
# OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

use strict;
use warnings;
use Getopt::Std;

my $script = $0;
my $verbose = 0;
my $num_args = $#ARGV + 1;
my $public_rsa = "~/.ssh/id_rsa.pub";

# Explicitly define global symbol %opts
our(%opts);
# Fetch options and exit if unknown options are specified
usage() if !getopts('i:k:o:s:v', \%opts) or $num_args == 0;
# Exit if mandatory options are missing
usage() if($opts{i} eq '');

my $input_file = $opts{i};
my $output_file = "$input_file.enc";
my $output_secret = "$input_file.key.enc";

if (length $opts{k}) { $public_rsa = $opts{"k"}; }
if (length $opts{o}) { $output_file = $opts{"o"}; }
if (length $opts{s}) { $output_secret = $opts{"s"}; }

if (not -e $input_file) { 
    print "Aborting: Input file '$input_file' does not exist." ; exit; 
}
if (not -e $public_rsa) { 
    print "Aborting: RSA key '$public_rsa' does not exist."; exit; 
}

if($opts{v}) {
    $verbose = 1;
    print "Verbose output enabled\n";
}

if ($verbose) {
    print "Input file      : $input_file\n";
    print "RSA key         : $public_rsa\n";
    print "Output file     : $output_file\n";
    print "Encrypted secret: $output_secret\n";
    print "\n";
}

print "Generating 256 bit symmetric key...\n" if $verbose;
system("openssl rand 32 -out secret.key.tmp");

print "Encrypting '$input_file', saving as '$output_file' ...\n" if $verbose;
system("openssl aes-256-cbc -in $input_file -out $output_file -pass file:secret.key.tmp");

print "Encrypting symmetric key, storing as '$output_secret' ...\n" if $verbose;
system("ssh-keygen -e -f $public_rsa -m PKCS8 > key.tmp");
system("openssl pkeyutl -encrypt -pubin -inkey key.tmp -in secret.key.tmp -out $output_secret");

unlink "key.tmp";
unlink "secret.key.tmp";

print "Done. Output: Encrypted '$output_file' and encrypted key '$output_secret'.\n" if not $verbose;




sub usage {
    
    print "Usage: $script -i <input_file> [-k <public_rsa> -o <output_file> -s <output_secret>]\n";
    print "\n";
    print "This encrypts encrypts <input_file> and stores it as <output_file> together with the\n";
    print "generated secret key (encrypted using <rsa_key>).\n";
    print "\n";
    print "Parameters:\n";
    print "  -i    input_file\n";
    print "        File to be encrypted\n";
    print "  -k    public_rsa\n";
    print "        Optional. Public RSA key. Defaults to '$public_rsa'\n";
    print "  -o    output_file \n";
    print "        Optional. Name of the encrypted file. <input_file>.enc if not specified\n";
    print "  -s    output_secret \n";
    print "        Optional. Name of encrypted secret. <input_file>.key.enc if not specified\n";

    exit;
}
