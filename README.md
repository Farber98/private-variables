# Reading private variables vulnerability

Solidity stores the variables defined via 32 bytes slots. This slots are filled sequentially following declaration order in contract.

Storage is optimized to save space. If neighboring variables fit in a single 32 bytes, then they are packed into the same slot, starting from the right. See following example:

```
uint256 public count = 123; --> size: 32B --> SLOT[0]
address public owner = msg.sender; --> size: 20B --> SLOT[1]
bool public isTrue = true; --> size: 1B --> SLOT[1], because 12B still free.
uint16 public u16 = 31; --> size: 2B --> SLOT[1], because 11B are still free.
bytes32 private password; --> size: 32B --> SLOT[2], because doesn't fits in remainig 9B at SLOT[1].
```

Let's see some other edge cases:

```
uint public constant someConst = 123; --> constants are hardcoded, hence no slot given.
bytes32[2] public data; --> gets un SLOT for each item.

struct User --> Needs 2 SLOTS
{
    uint256 id; --> Needs 1 SLOT
    bytes32 password; --> Needs 1 SLOT
}

// Supposing 5 first slots are in use.
// Needs 2 SLOTS for each elm
// Starts at SLOT(hash(first free slot))
User[] private users; --> From SLOT[hash(6)] to SLOT[hash(6) + 2 * len(users)]

// Supposing slot 7 is empty
// Each entry is stored at SLOT[hash(key,first free slot)]
mapping(uint => User) private userId; --> Stores at SLOT[hash(key,7)];

```

Said this, you can see state is stored in a deterministical manner. You can define variables to be private, preventing other contracts from modifiying them but not from reading them if they make a little twist calculating storage slots.

## Reproduction

### 📜 Involves one smart contract.

    1. A vulnerable contract with sensitive information stored in private variables.

## How to prevent it

👁️ Don't store sensitive information on the blockchain.
