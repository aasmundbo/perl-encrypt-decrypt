### Perl-encrypt-decrypt
Perl scripts for encrypting a file and decrypting a file.

The scripts are inspired by https://bjornjohansen.no/encrypt-file-using-ssh-key

Developed and tested using Cygwin on Windows 10.

#### Required Cygwin packages
- openssh

#### encrypt.pl
Script encrypts the input file and an auto-generated symmetric key.
The input file is encrypted using the symmetric key.
The symmetric key is encrypted using the provided public RSA key.

#### decrypt.pl
Script decrypts the input file using the provided encrypted symmetric key (decrypted using private RSA key).
