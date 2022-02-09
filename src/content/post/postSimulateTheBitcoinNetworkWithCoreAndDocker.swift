let postSimulateTheBitcoinNetworkWithCoreAndDocker = Post("/post/2022-02-09-simulate-the-bitcoin-network-with-core-and-docker", "Simulate the Bitcoin Network with Core and Docker", "2022-02-09T12:00:00Z", .bitcoinCore, "1491386914070753281") { """

For a long time has Bitcoin Core had the ability to run in _regtest_ mode. While the name indicates that this feature is intended for regression testing, it actually serves as a way to create simulated networks – what [btcd](https://github.com/btcsuite/btcd) node runners would know as a _simnet_.

# Test versus simulated networks

In a [test network](https://en.bitcoin.it/wiki/Testnet) participants not known to each other connect to maintain a pretend blockchain made to resemble the real Bitcoin network in every way possible. These networks are seeded by Core developers and are usually kept alive for a couple of years while users perform their dry runs before moving on to the main chain. There's usually one such network at a time which at the time of writing is called `testnet3`.

Simulated networks on the other hand are isolated experiments with known participants. Being able to fully control the variables affecting the environment is key for developers who seek to gain insight into the Bitcoin protocol in order to produce robust well-integrated solutions.

# Configuring a simulated network

Launching a simulated network can be as simple as appending the `-regtest` flag to our daemon invocation:

```sh
bitcoind -regtest
# 2022-02-08T16:43:58Z Bitcoin Core version v22.0.0 (release build)
# …
```

Alternatively we can specify this option in the configuration file:

```sh
cat bitcoin.conf
regtest=1
```

We can now connect to our single `regtest` node and ask for information.

```sh
 bitcoin-cli -regtest -getinfo
# {
#   "blocks": 0,
#   "headers": 0,
#   "connections": {
#     "in": 0,
#     "out": 0,
#     "total": 0
#   },
#   "chain": "regtest",
# }
```

Since we can't have a network with only one node let's spin off another participant. For this we will need to create a new data directory which we will name `hal`. We will also need to provide alternative ports to avoid collisions with our initial instance.

```sh
mkdir hal
bitcoind -datadir=$PWD/hal -regtest -rpcport=18453 -bind=127.0.0.1:18455
# 2022-02-08T16:43:58Z Bitcoin Core version v22.0.0 (release build)
```

We can now connect our nodes with each other.

```sh
bitcoin-cli -datadir=$PWD/hal -regtest -rpcport=18453 addnode 127.0.0.1 onetry
bitcoin-cli -regtest addnode 127.0.0.1:18455 onetry
bitcoin-cli -regtest getnetworkinfo
# {
#   …
#   "connections": 2,
#   "connections_in": 1,
#   "connections_out": 1,
#   …
# }
```

The connection was made successfully but before we continue – we can already see how with all peers being identified by same loopback address can be confusing. Having to specify alternative ports for each of the nodes' interfaces can also get very messy, very quickly. It would be great if we were able to isolate every instance and run them in an IP network of their own where they each get a unique address with default TCP bindings.

# Dockerized `bitcoind`

For a dockerized version of Bitcoin Core we will build our own images using this [`Dockerfile` definition](https://github.com/craigwrong/docker-bitcoin-core/blob/develop/Dockerfile). Note that the process might take a few minutes as we are compiling the binaries directly from source code – as one should.

```sh
git clone https://github.com/craigwrong/docker-bitcoin-core
cd docker-bitcoin-core
docker build --target daemon-wallet -t bitcoind .
docker build --target cli -t bitcoin-cli .
```

We now have an image for the daemon complete with wallet support as well as one for `bitcoin-cli`. We can now proceed with creating a network called `bitcoin-regtest` which will contain all of our Core instances.

```sh
docker network create --subnet=10.0.0.0/16 bitcoin-regtest
```

Before we launch our first instance let's create a simple configuration file in what will be this node's data folder.

```sh
mkdir satoshi
cat << EOF >> satoshi/bitcoin.conf
regtest=1
txindex=1
rpcallowip=10.0.0.0/16
[regtest]
addnode=10.0.0.3
rpcbind=0.0.0.0
EOF
```

Notice that we will attempt to connect to a peer with IP `10.0.0.3`. Let's launch this daemon first with IP `10.0.0.2`.

```sh
docker run --network bitcoin-regtest --ip 10.0.0.2 --name bitcoind-satoshi --rm -t -v $PWD/satoshi:/root/.bitcoin bitcoind
```

We will now do the analogous thing for Hal's node. The only change is that we will connect it to the previously launched node.

```sh
cat << EOF >> hal/bitcoin.conf
regtest=1
txindex=1
rpcallowip=10.0.0.0/16
[regtest]
addnode=10.0.0.2
rpcbind=0.0.0.0
EOF

docker run --network bitcoin-regtest --ip 10.0.0.3 --name bitcoind-hal --rm -t -v $PWD/hal:/root/.bitcoin bitcoind
```

We should see in the respective consoles whether the peers successfully connected with each other.

# Querying nodes

To keep things clean, we want to query our nodes using the CLI from within the virtual network we created using Docker. To do this we will launch an ephemeral container using the `bitcoin-cli` image we built before. We can grab the cookie file from the corresponding data directory for authentication.

```sh
docker run --rm --network bitcoin-regtest -v $PWD/satoshi/regtest/.cookie:/root/.cookie bitcoin-cli -regtest -rpccookiefile=/root/.cookie -rpcconnect=10.0.0.2 -getinfo
```

This should give us confirmation again that the nodes are talking to each other.

For convenience we can define the aliases `bitcoin-satoshi` and `bitcoin-hal` to make it easier to issue further calls.

```sh
alias bitcoin-satoshi="docker run --rm --network bitcoin-regtest -v $PWD/satoshi/regtest/.cookie:/root/.cookie bitcoin-cli -regtest -rpccookiefile=/root/.cookie -rpcconnect=10.0.0.2"
bitcoin-satoshi getpeerinfo
# …
```

We can now play around with mining as well as transacting with real `regtest` coin! Reach out to me on Twitter if you have questions. I hope this guide can help other devs run their own experiments with the Bitcoin protocol.

""" }
