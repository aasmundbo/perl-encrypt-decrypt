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
my $priv_rsa = "~/.ssh/id_rsa";

# Explicitly define global symbol %opts
our(%opts);
# Fetch options and exit if unknown options are specified
usage() if (!getopts('i:k:o:s:v', \%opts) or $num_args == 0);
# Exit if mandatory options are missing
usage() if($opts{i} eq '' or $opts{s} eq '');

my $input_file = $opts{i};
my $encrypted_secret = $opts{s};
my $output_file = "$input_file.dec";
if (length $opts{k}) { $priv_rsa = $opts{"k"}; }
if (length $opts{o}) { $output_file = $opts{"o"}; }

if($opts{v}) {
    $verbose = 1;
    print "Verbose output enabled\n";
}
if ($verbose) {
    print "Encrypted file  : $input_file\n";
    print "RSA key         : $priv_rsa\n";
    print "Encrypted secret: $encrypted_secret\n";
    print "Output file     : $output_file\n";
    print "\n";
}

if (not -e $input_file) { 
    print "Aborting: Input file '$input_file' does not exist." ; exit; 
}
if (not -e $encrypted_secret) { 
    print "Aborting: Secret key  '$encrypted_secret' does not exist." ; exit; 
}
if (not -e $priv_rsa) { 
    print "Aborting: RSA key '$priv_rsa' does not exist."; exit; 
}

print "Decrypting symmetric key...\n" if $verbose;
system("openssl pkeyutl -decrypt -inkey $priv_rsa -in $encrypted_secret -out secret.dec");

print "Decrypting '$input_file' using decrypted key, saving as '$output_file' ...\n" if $verbose;
system("openssl aes-256-cbc -d -in $input_file -out $output_file -pass file:secret.dec");

unlink "secret.dec";

print "Done. Output: '$output_file'\n" if not $verbose;




sub usage {
    
    print "Usage: $script -i <input_file> -s <encrypted_secret> [-k <priv_rsa> -o <output_file> ]\n";
    print "\n";
    print "This script decrypts <input_file> and stores it in <output_file>.\n";
    print "\n";
    print "Parameters:\n";
    print "  -i    input_file\n";
    print "        File to decrypt\n";
    print "  -s    encrypted_secret \n";
    print "        The encrypted secret key (used to decrypt <input_file>)\n";
    print "  -k    priv_rsa\n";
    print "        Optional. Private RSA key (used to decrypt <encrypted_secret>)\n";
	print "        Defaults to '$priv_rsa'\n";
    print "  -o    output_file \n";
    print "        Optional. Name of the encrypted file. <input_file>.dec if not specified\n";

    exit;
}
