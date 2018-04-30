JaysonChain
===========
**Authors: Simon Yuan, Fynn Faber, Florian Spychiger, Timofey Derkovsky, Henry Trinh, Kevin De Keyser**

This ReadMe is outdated. New code is in MinimalOnChainCode.

First of all the final version is in the master branch!

We have multiple iterated versions of our contract. In order to understand the code, we recommend you to look at the contracts in the following order:

```
CodeJaysonChain/decentralisedMessaging.sol
CodeJaysonChain/decentralisedMessagingKnowable.sol
CodeJaysonChain/decentralisedMessagingKnowableLedger.sol
CodeJaysonChain/decentralisedMessagingKnowableLedgerProofOfOrigin.sol
```

The comments are very important, because they state, what the local API should do (these are only example protocols that can be used with this contract system).
Each contract adds something new to the other one.

We also have Web API implemented, but we were slowed down by the gas limit of web3.js. We didn't have enough time to finish this, but you can see our progress here:
The web interface contains all the GUI a web interface should be capable of.
```
WebInterface/index.html
````
