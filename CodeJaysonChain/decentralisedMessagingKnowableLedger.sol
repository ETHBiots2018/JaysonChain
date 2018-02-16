pragma solidity ^0.4.18;

//For terminology purposes, the user that creates the contract is called the owner and the users using the contract as a messaging system are called accounts.
contract DecentralisedMessagingKnowableLedger {
    //DM Features:
    //Everyone that wants to use this contract must generate a private and public key according to some asymmetrical cryptograhy method, for example RSA.
    //Then he needs to call initAccount

    //DMK Features:
    //The decentralisedMessagingKnowable adds the additional functionality that we can see whether a message was read.
    //This is done by adding a new information to AccountData, namely mostRecentlyReadIndex, which can be updated by the reader.
    //Messages should be read one after another in the messageTable 
    //If the user follows the protocol, you can now be sure that the receiver read the message, if mostRecentlyReadIndex is greater than the message index you sent.
    //This system basically works the same way WhatsApps blueflag system works, you can either tell everyone when you read the messages or nobody.
    //If you only want to notify certain people that you read their messages, you can create a new account for these specific people.
    //This system also enables a way to remember, what the last message was you read from the messageTable.

    //DMKL Features:
    //This version adds one ledger to every account. Every account can add anything he wants to his own ledger.
    //Every ledger table entry should be encrypted with a symmetric key. Following the protocol,
    //the symmetric key is generated by the hash of the ledger entry index and the private key of the account.
    //Notice, that we can now share messages to multiple trusted people using the following protocol:
    //1. Write your message to your own ledger.
    //2. Send a message to everyone using the DM (decentralised messaging system) containing the symmetric key of the ledger entry that contains message you want to broadcast.
    //3. Send a message to everyone with the symmetric key of the ledger table entry.

    
    //However you don't store the plain (decrypted) message entry, you encrypt the message entry with a seperate symmetric key and then add it to the ledger.
    //The symmetric key is generated by the hash of the ledger entry index and the private key of the account.
    //You can now add to your ledger messages from the messageTable accor
    //Everybody that follows the protocol should only add messages from the messageTable to his ledger according to the above method.
    //If somoene adds something else to his ledger (for example simply a message with some random encrypted), this doesn't effect anyone else who follows the protocol.
    //You can show other accounts whats in your ledger by sharing the symmetric key of the respective ledger table entry.
    //The symmetric key can be shared using the message table as a simple message.
    //In this system account A can send something to account B. Now account B can show account C that he received this message from account A (by showing his ledger table entry).
    //However account C needs to trust account B to send him the correct message, since account B can  put anything in his ledger.
    //In the next version account C does not need to trust account B anymore.
    //Using the ledgers, we can also send messages to multiple trusted accounts by giving the shared symmetric key to each of them. Notice, this wasn't previously possible, since you can't share your private key.

    modifier accountInitialized(address _address) {
        require(accountDatas[_address].account != 0);
        _;
    }

    struct LedgerTableEntry {
        string symmetricallyEncryptedMessage;
    }

    struct AccountData {
        address account;
        uint256 publicKey;
        uint256 mostRecentlyReadIndex;

        uint256 ledgerTableLength;
        mapping(uint256 => LedgerTableEntry) ledgerTable;
    }
    mapping(address => AccountData) accountDatas;


    function initAccount (uint256 _publicKey) public {
        require(accountDatas[msg.sender].account == 0); //checks if the account was never initialised before.
        AccountData memory accountData;
        accountData.account = msg.sender;
        accountData.publicKey = _publicKey;
        accountData.mostRecentlyReadIndex = messageTable.length - 1;
        accountData.ledgerTableLength = 0;
        accountDatas[msg.sender] = accountData;
    }

    //According to the protocol
    function addLedgerTableEntry(string _symmetricallyEncryptedMessage) public accountInitialized(msg.sender) {
        LedgerTableEntry memory ledgerTableEntry;
        ledgerTableEntry.symmetricallyEncryptedMessage = _symmetricallyEncryptedMessage;
        accountDatas[msg.sender].ledgerTable[accountDatas[msg.sender].ledgerTableLength] = ledgerTableEntry;
        accountDatas[msg.sender].ledgerTableLength++;
    }

    //This is simply a function that allows you to view the ledger table entry of any account. Keep in mind its only read-able if you have the symmetric key.
    function getLedgerTableEntry(address _accountAddress, uint256 _ledgerTableEntryIndex) public view accountInitialized(msg.sender) accountInitialized(_accountAddress)
    returns (string symmetricallyEncryptedMessage) {
        require(accountDatas[_accountAddress].ledgerTableLength > _ledgerTableEntryIndex);
        LedgerTableEntry storage ledgerTableEntryPointer = accountDatas[_accountAddress].ledgerTable[_ledgerTableEntryIndex];
        return ledgerTableEntryPointer.symmetricallyEncryptedMessage;
    }

    struct MessageTableEntry {
        //This is public anyway, so we store it here.
        address sender;
        uint256 unixTime;

        string encryptedTo; //if decrypted, this is an address
        string encryptedMessage; //if decrypted, this is a string
    }
    MessageTableEntry[] public messageTable;

    //In order to send a message, you have to encrypt the parameters of sendMessage with the public key of the receiver.
    function sendMessage(string _encryptedTo, string _encryptedMessage) public accountInitialized(msg.sender) {
        MessageTableEntry memory messageTableEntry;
        messageTableEntry.sender = msg.sender;
        messageTableEntry.unixTime = now;

        messageTableEntry.encryptedTo = _encryptedTo; 
        messageTableEntry.encryptedMessage = _encryptedMessage;
        messageTable.push(messageTableEntry);
    }

    function updateMostRecentlyReadIndex (uint256 _newIndex) public accountInitialized(msg.sender) {
        require(_newIndex < messageTable.length && accountDatas[msg.sender].mostRecentlyReadIndex < _newIndex);
        accountDatas[msg.sender].mostRecentlyReadIndex = _newIndex;
    }

    //In order to read a message 
    function getMessage(uint256 _messageIndex) view public accountInitialized(msg.sender)
    returns (address sender, uint256 unixTime, string encryptedTo, string encryptedMessage) {
        return (messageTable[_messageIndex].sender, messageTable[_messageIndex].unixTime, messageTable[_messageIndex].encryptedTo, messageTable[_messageIndex].encryptedMessage);
    }
}