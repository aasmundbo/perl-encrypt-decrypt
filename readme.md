### Perl-encrypt-decrypt
Perl scripts for encrypting a file and decrypting a file.

The scripts are inspired by https://bjornjohansen.no/encrypt-file-using-ssh-key

#### encrypt.pl
Script encrypts the input file and an auto-generated symmetric key.
The input file is encrypted using the symmetric key.
The symmetric key is encrypted using the provided publis RSA key.

#### decrypt.pl
Script decrypts the input file using the provided private RSA key.
