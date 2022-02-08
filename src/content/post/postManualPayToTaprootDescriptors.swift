let postManualPayToTaprootDescriptors = Post("/post/2022-02-07-manual-pay-to-taproot-descriptors", "Manual Pay-To-Taproot Descriptors", "2022-02-07T12:00:00Z", .bitcoinCore, "1490766439317442565") { """

Even though Bitcoin Core 22 is the [first version](https://bitcoincore.org/en/releases/22.0/) to support Pay-to-Taproot outputs, its wallet component does not yet initialize with a `tr()` descriptor by default. While this is [expected to change](https://github.com/bitcoin/bitcoin/pull/22364) in version 23, there are still reasons to want to import this output descriptor manually.

# Motivation

We may want to add `bech32m` address generation capabilities to an existing descriptor wallet created by a previous version of Core. Or we might need a wallet which _only_ supports this type of address format. In this article we are going to go through the steps of constructing such a descriptor as well as importing it into an empty wallet.

# Descriptor format

The general format of a `tr()` descriptor as defined by [BIP 380](https://github.com/bitcoin/bips/blob/master/bip-0380.mediawiki#Specification) and [BIP 386](https://github.com/bitcoin/bips/blob/master/bip-0386.mediawiki) reads as follows.

`tr([FINGERPRINT/NUM'/…/NUM']PRIVATE_KEY/NUM/…/*)#CHECKSUM`

Where `FINGERPRINT` is the what identifies the originating public key. `PRIVATE_KEY` is the `xpriv` used to generate all child keys with corresponding addresses. `NUM` represents an index in the derivation path with an optional `'` marker for hardened derivation. Derivation paths are used both to describe the origin of the supplied private key as well as an indication of how exactly new addresses will be generated. Finally a `CHECKSUM` is added at the end for safety.

As an example, final version of a taproot descriptor might look like this:

```
tr([ed493b83/86'/0'/0']xprv9xgqHN7yz9MwCkxsBPN5qetuNdQSUttZNKw1dcYTV4mkaAFiBVGQziHs3NRSWMkCzvgjEe3n9xV8oYywvM8at9yRqyaZVz6TYYhX98VjsUk/0/*)#06sjusfa
```

# Additional tools

In addition to Core we will make use of the [Bitcoin Explorer](https://github.com/libbitcoin/libbitcoin-explorer) command-line tool by [Libbitcoin](https://libbitcoin.info). For extra verification we will also use a [custom tool](https://github.com/craigwrong/schnorr-tool) that can also create `bech32m` addresses.

# Test vectors

Throughout this process we will check our results against the test vectors defined in [BIP 86](https://github.com/bitcoin/bips/blob/master/bip-0086.mediawiki#Test_vectors).

# Deriving a private key

Bitcoin Core does not support mnemonic seeds but we can still use one to generate our private key. Intermediate results are shown as Bash comments after each command and are almost always used as input for the next command.

```sh
bx mnemonic-to-seed abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon about
# 5eb00bbddcf069084889a8ab9155568165f5c453ccb85e70811aaed6f6da5fc19a5ac40b389cd370d086206dec8aa6c43daea6690f20ad3d8d48b2d2ce9e38e4

bx hd-new 5eb00bbddcf069084889a8ab9155568165f5c453ccb85e70811aaed6f6da5fc19a5ac40b389cd370d086206dec8aa6c43daea6690f20ad3d8d48b2d2ce9e38e4
# xprv9s21ZrQH143K3GJpoapnV8SFfukcVBSfeCficPSGfubmSFDxo1kuHnLisriDvSnRRuL2Qrg5ggqHKNVpxR86QEC8w35uxmGoggxtQTPvfUu

bx hd-to-public xprv9s21ZrQH143K3GJpoapnV8SFfukcVBSfeCficPSGfubmSFDxo1kuHnLisriDvSnRRuL2Qrg5ggqHKNVpxR86QEC8w35uxmGoggxtQTPvfUu
# xpub661MyMwAqRbcFkPHucMnrGNzDwb6teAX1RbKQmqtEF8kK3Z7LZ59qafCjB9eCRLiTVG3uxBxgKvRgbubRhqSKXnGGb1aoaqLrpMBDrVxga8
```

# Calculate fingerprint

As per [BIP 32](https://en.bitcoin.it/wiki/BIP_0032) specification we calculate our public key's fingerprint by encoding it, hashing it and taking its first 8 characters.

```sh
bx base58-decode xpub661MyMwAqRbcFkPHucMnrGNzDwb6teAX1RbKQmqtEF8kK3Z7LZ59qafCjB9eCRLiTVG3uxBxgKvRgbubRhqSKXnGGb1aoaqLrpMBDrVxga8
# 0488b21e0000000000000000007923408dadd3c7b56eed15567707ae5e5dca089de972e07f3b860450e2a3b70e03d902f35f560e0470c63313c7369168d9d7df2d49bf295fd9fb7cb109ccee0494c7fe61f5

bx bitcoin160 0488b21e0000000000000000007923408dadd3c7b56eed15567707ae5e5dca089de972e07f3b860450e2a3b70e03d902f35f560e0470c63313c7369168d9d7df2d49bf295fd9fb7cb109ccee0494c7fe61f5
# ed493b8354c1766c6b0a55c906d34582818baa8b

echo ed493b8354c1766c6b0a55c906d34582818baa8b | cut -c 1-8
# ed493b83
```

So in this case the fingerprint identifying our master public key will be `ed493b83`.

# Account keys

The derivation path `86'/0'/0'` is used to compute the account key pair.

```sh
bx hd-private -d -i 86 xprv9s21ZrQH143K3GJpoapnV8SFfukcVBSfeCficPSGfubmSFDxo1kuHnLisriDvSnRRuL2Qrg5ggqHKNVpxR86QEC8w35uxmGoggxtQTPvfUu
# xprv9ukW2Usuz4vBKZJxKfMUwtjtSTD2U4QxW1ue4prK5TYzYM3voo8EEyUPsyYHvHP8jvj9w4Xr6SAdpEGEDVfpQm8q1puVtRTUidX4mgrouHH

bx hd-private -d -i 0 xprv9ukW2Usuz4vBKZJxKfMUwtjtSTD2U4QxW1ue4prK5TYzYM3voo8EEyUPsyYHvHP8jvj9w4Xr6SAdpEGEDVfpQm8q1puVtRTUidX4mgrouHH
# xprv9wMkdjRwYptb4FzqvUNxxehWWywVtgVvrV5X9BKb16bugM5eQJdHLG7dVF3W1r1KkkSHN3s3txMNMEcisTRLK2ogyU4mek8eAPfXkfUqhhG

bx hd-private -d -i 0 xprv9wMkdjRwYptb4FzqvUNxxehWWywVtgVvrV5X9BKb16bugM5eQJdHLG7dVF3W1r1KkkSHN3s3txMNMEcisTRLK2ogyU4mek8eAPfXkfUqhhG
# xprv9xgqHN7yz9MwCkxsBPN5qetuNdQSUttZNKw1dcYTV4mkaAFiBVGQziHs3NRSWMkCzvgjEe3n9xV8oYywvM8at9yRqyaZVz6TYYhX98VjsUk
```

We now have the account private key to use in our descriptor:

```
xprv9xgqHN7yz9MwCkxsBPN5qetuNdQSUttZNKw1dcYTV4mkaAFiBVGQziHs3NRSWMkCzvgjEe3n9xV8oYywvM8at9yRqyaZVz6TYYhX98VjsUk
```


# Obtain the checksum

To calculate the checksum value we use the `getdescriptorinfo` Bitcoin Core command.

```sh
bitcoin-cli getdescriptorinfo "tr([ed493b83/86'/0'/0']xprv9xgqHN7yz9MwCkxsBPN5qetuNdQSUttZNKw1dcYTV4mkaAFiBVGQziHs3NRSWMkCzvgjEe3n9xV8oYywvM8at9yRqyaZVz6TYYhX98VjsUk/0/*)"
# …
# "checksum": "06sjusfa",
# …
```

Ignore the public key descriptor returned by the command, we only care about the value explicitly defined for the key `checksum`. With the correct value `06sjusfa` our descriptor is now complete:

```
tr([ed493b83/86'/0'/0']xprv9xgqHN7yz9MwCkxsBPN5qetuNdQSUttZNKw1dcYTV4mkaAFiBVGQziHs3NRSWMkCzvgjEe3n9xV8oYywvM8at9yRqyaZVz6TYYhX98VjsUk/0/*)#06sjusfa
```

# Importing the descriptor

We are going to use an empty descriptor wallet encoded with a `secret` passphrase.

```sh
bitcoin-cli createwallet taprootwallet false true secret false true true false
# {
#   "name": "taprootwallet",
#   "warning": "Wallet is an experimental descriptor wallet"
# }
```

We need to unlock the wallet first and then import our descriptor.

```sh
bitcoin-cli walletpassphrase secret 60
bitcoin-cli importdescriptors "[
  {
    \"desc\": \"tr([ed493b83/86'/0'/0']xprv9xgqHN7yz9MwCkxsBPN5qetuNdQSUttZNKw1dcYTV4mkaAFiBVGQziHs3NRSWMkCzvgjEe3n9xV8oYywvM8at9yRqyaZVz6TYYhX98VjsUk/0/*)#06sjusfa\",
    \"timestamp\": \"now\",
    \"active\": true,
    \"internal\": false,
    \"range\": [
      0,
      999
    ],
    \"next\": 0
  }
]"
# …
# "success": true
# …
```

We can double-check that the descriptor was imported correctly by using Core command `listdescriptors`.

# Get a `bech32m` address

We now use the `getnewaddress` command and specify the address type `bech32m` for which the wallet will utilize our just-imported descriptor.

```sh
bitcoin-cli getnewaddress "Taproot address" bech32m
# bc1p5cyxnuxmeuwuvkwfem96lqzszd02n6xdcjrs20cac6yqjjwudpxqkedrcr
```

Now we can receive BTC from a Taproot-enabled wallet at address `bc1p5cyxnuxmeuwuvkwfem96lqzszd02n6xdcjrs20cac6yqjjwudpxqkedrcr`.

# Account `xpub`

The process of assembling and importing a descriptor could be repeated with an `xpub` public key. This would be useful for a watch-only wallet, capable of verifying a balance without the ability to spend from it. Or as a way to give out to a payer so that they can issue recurring payments towards us without needing to reuse addresses.

To derive the corresponding public key from our private key we again turn to `bx`.

```sh
bx hd-to-public xprv9xgqHN7yz9MwCkxsBPN5qetuNdQSUttZNKw1dcYTV4mkaAFiBVGQziHs3NRSWMkCzvgjEe3n9xV8oYywvM8at9yRqyaZVz6TYYhX98VjsUk
# xpub6BgBgsespWvERF3LHQu6CnqdvfEvtMcQjYrcRzx53QJjSxarj2afYWcLteoGVky7D3UKDP9QyrLprQ3VCECoY49yfdDEHGCtMMj92pReUsQ
```

The rest of the process is analogous.

# Additional verifications

We want to check our values against the test vectors. We will start by deriving the first receiving address for path `m/86'/0'/0'/0/0`.

```sh
bx hd-private -i 0 xprv9xgqHN7yz9MwCkxsBPN5qetuNdQSUttZNKw1dcYTV4mkaAFiBVGQziHs3NRSWMkCzvgjEe3n9xV8oYywvM8at9yRqyaZVz6TYYhX98VjsUk
# xprvA1n4fAv8WWZbfAECqqZsPxRCCaBUqLXF9VdqK1RMAhcyyAoM3fGx6ytPfVrTHMhqLqGLJP4pgLBsQKYb53tnM3vSDPS6U756uWfrF2TpcXS

bx hd-private -i 0 xprvA1n4fAv8WWZbfAECqqZsPxRCCaBUqLXF9VdqK1RMAhcyyAoM3fGx6ytPfVrTHMhqLqGLJP4pgLBsQKYb53tnM3vSDPS6U756uWfrF2TpcXS
# xprvA449goEeU9okwCzzZaxiy475EQGQzBkc65su82nXEvcwzfSskb2hAt2WymrjyRL6kpbVTGL3cKtp9herYXSjjQ1j4stsXXiRF7kXkCacK3T

bx hd-to-public xprvA449goEeU9okwCzzZaxiy475EQGQzBkc65su82nXEvcwzfSskb2hAt2WymrjyRL6kpbVTGL3cKtp9herYXSjjQ1j4stsXXiRF7kXkCacK3T
# xpub6H3W6JmYJXN49h5TfcVjLC3onS6uPeUTTJoVvRC8oG9vsTn2J8LwigLzq5tHbrwAzH9DGo6ThGUdWsqce8dGfwHVBxSbixjDADGGdzF7t2B
```

For the Schnorr-specific internal and output keys we use `schnorr-tool`. From that we will encode the `bech32m` address which should match the one we got from our wallet.

```sh
bx hd-to-ec xprvA449goEeU9okwCzzZaxiy475EQGQzBkc65su82nXEvcwzfSskb2hAt2WymrjyRL6kpbVTGL3cKtp9herYXSjjQ1j4stsXXiRF7kXkCacK3T
# 41f41d69260df4cf277826a9b65a3717e4eeddbeedf637f212ca096576479361

schnorr-tool internal-key 41f41d69260df4cf277826a9b65a3717e4eeddbeedf637f212ca096576479361
# cc8a4bc64d897bddc5fbc2f670f7a8ba0b386779106cf1223c6fc5d7cd6fc115

schnorr-tool tweak cc8a4bc64d897bddc5fbc2f670f7a8ba0b386779106cf1223c6fc5d7cd6fc115
# 2ca01ed85cf6b6526f73d39a1111cd80333bfdc00ce98992859848a90a6f0258

schnorr-tool output-key cc8a4bc64d897bddc5fbc2f670f7a8ba0b386779106cf1223c6fc5d7cd6fc115 2ca01ed85cf6b6526f73d39a1111cd80333bfdc00ce98992859848a90a6f0258
# a60869f0dbcf1dc659c9cecbaf8050135ea9e8cdc487053f1dc6880949dc684c

schnorr-tool output-script a60869f0dbcf1dc659c9cecbaf8050135ea9e8cdc487053f1dc6880949dc684c
# 5120a60869f0dbcf1dc659c9cecbaf8050135ea9e8cdc487053f1dc6880949dc684c

schnorr-tool address a60869f0dbcf1dc659c9cecbaf8050135ea9e8cdc487053f1dc6880949dc684c
# bc1p5cyxnuxmeuwuvkwfem96lqzszd02n6xdcjrs20cac6yqjjwudpxqkedrcr
```

Seeing that the test vectors and the two addresses match provides verification that the process is correct and that we can trust it to initialize wallets with non-trivial random seed phrases.

# Conclusion

Performing operations like this manually help us understand the inner workings of the protocol as well as increasing our confidence in the use of Bitcoin Core as a tool. Furthermore it allows us to gain finer control of our wallet's behavior.

Make sure to try this on `testnet`/`regtest` first before putting real money on the line.

""" }
