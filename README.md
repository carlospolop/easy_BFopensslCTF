# easy_BFopensslCTF

Bash script that given a password (or a wordlist) tries to decrypt an OpenSSL encrypted file using several algorithms.

## Help message
```bash
bf_openssl.bash -f input_file [-v] [-a] [-b] [-h] [-t password] [-p pass_file]
  v: Verbose level
  a: All cyphers
  b: Base64
  h: Help
  t: Use pass
  p: Use pass file
```

It doesn't show empty, data, Non-ISO extended-ASCII, DOS executable, COM executable for DOS, PGP Secret Key discovered files.
