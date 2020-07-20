# k-encryption
Simple Utilities to Help With Encrypted Data

## Goal
I wanted some very simple utilities to do some sort of encryption and with
the `cryptography` module in Python, that became viable. Within each encrypted
store, I wanted some sort of structure, so there are some tools to manage
formats like JSON and TOML.

For each basic tool, the goal was to really have it do only one thing (and
do it well). The result is scripts in which the argument parsing and help
documentation is generally longer than the implementation itself. This makes
them easy to understand, easy to modify and easy to use. Additionally,
these low-level tools are stateless: their output is based on their input
and command-line parameters alone. There is an intent to add a tool which
uses `keyutils` to store derived keys securely in the kernel, which would
obviously not be stateless.

Over time, the intent is add complex tools that make use of the basic
ones and handle errors somewhat intelligently.

## Overview of Suite and Short Example
All encryption is Fernet based. It is possible to create a random key with
something like `wg genkey` or use the included `k-keygen` which will make a
key based on a given salt and password, so it can be regenerated.

Combined with `k-randomchars`, which generates random characters,
`k-keygen` can do much the same thing as `wg genkey`, albeit in a needlessly
roundabout fashion:

```
$ k-keygen `k-randomchars 32` -p `k-randomchars 32`
```

`k-encrypt` and `d-decrypt` can then use this key to encrypt data.

Assuming the data is meant to be something like a password store, `k-convert`
can be used to transform it between formats or clean it up. Putting this
together, we can initalize some store of this sort:

```
$ k-randomchars 32 > salt  # save the salt somewhere
$ KEY=$(k-keygen $(cat salt))  # generate the key, but don't save it
Password:
$ echo '{}' | k-convert json msgpack | k-encrypt $KEY > vault  # initialize an empty vault
```

We can then add something to it:

```
$ export EDITOR="ed -p >>"  # the editor vipe should use
$ cat vault | k-decrypt $KEY | k-convert msgpack toml | vipe | k-convert toml msgpack | k-encrypt $KEY > tmpvault
0
>>a
[domain]
user='name'
pass='secret'
.
>>wq
35
$ mv tmpvault vault  # assuming the editing went well
$ cat vault | k-decrypt $KEY | k-convert msgpack yaml
domain:
  pass: secret
  user: name
```

As stated previously, the goal is to combine such simple tools into complex ones that handle
specific use cases like the above. In the absence of such tools, the simple tools can be thrown
together in a basic shell script.

Other available tools include `k-list` which will list keys (and optionally values) in the store
to some limited depth and `k-passgen` which is a slight modification to XKCD-based password
generation such that the resultant passwords tend to meet the varied requirements of different
websites and systems administrators.

## Future Work
Only the most critical basic tools are completed so far, and no complex ones have been completed.

In the short term, a tool is needed for filtering data in a key-value store and another for modifying
a store at a specific location. This is important so that only certain parts of vault are exposed to
the user once decrypted. Practice has shown that such tools should incorporate fuzzy matching, at
least on the reading side.

A complex tool that puts passwords on the clipboard.

Implementing graphical interaction via demnu, rofi or similar is planned. There is no intent
to include graphical tools directly.

A `keyutils`-based tool to store derived keys in the kernel is planned to allow keys to persist
beyond the runtime of `k-keygen` with storing them to variables, the clipboard or the file system.
This should roughly align with how `sudo` does not require the user to regularly re-enter their
password.

## Why k-encryption and k-\*?
I always intended to use it for key-value stores and `k-[TAB]` didn't
autocomplete to anything on my machine.

## Requirements

Different tools have different requirements. Fulfilling all of these
is probably not necessary.

### Python Modules

`cryptography` for k-encrypt, k-decrypt, k-keygen
`toml` for TOML support in k-convert, k-filter, k-list
`yaml` for YAML support in k-convert, k-filter, k-list
`msgpack` for MSGPACK support in k-convert, k-filter
`xkcdpass` for `k-passgen`

### External Utilities
`moreutils` for `vipe`, which is probably the only easy way to edit data with k-do
`keyutils` for `keyctl`, needed by `k-keyctl` to temporarily store keys
`jq` is like `k-filter` and `k-list` that only supports JSON, but is far more powerful
