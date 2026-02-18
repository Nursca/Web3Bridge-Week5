# Assignment1

## requirement
- Where are your structs, mappings and arrays stored
- Why don't you need to specify memory or storage with mappings
- How do structs, mappingss and arrays behave when exected or called

# 1. Where are your structs, mappings and arrays stored?

Everything depends on where ther are declared. Data can be stored in either **Storage,** **Memory,** **Calldata**.


If **Struct**, and **Arrays** are declared at contract level which makes them state variables, that means they are stored in storage. 
If declared within a function and no data location is specified within a function, they default to storage in older Solidity versions, but modern best practice and more recent compiler versions require an explicit location for local variables of these types.

For **Mapping**, if declared within a function, they cannot exist in memory or calldata, it can only be stored as Storage.

# 2. How do structs, mappingss and arrays behave when exected or called?

* **Struct in Storage:** When explicitly declared as storage, the struct when executed it modifies the original storage directly.
* **Struct in Memory:** When explicitly declared as memory, the struct when executed, it modifies only the copy. Storage remains unchanged unless reassigned.

* **Array in Storage:** When explicitly declared as storage, when executed it modifies the original array.
* **Array in Memory:** When explicitly declared as memory, when executed it modifies just the copy, Original storage array remains unchanged.

# 3. Why don't you need to specify memory or storage with mappings?

The reason why you don't need too specify between memory or storage for mappings is because mappings can only exist in storage.

**Why?**

Mappings are not linear data structures.

They:

* Do not store keys
* Do not store data sequentially
* Compute storage location using: keccak256(key . slot)
This hashing logic is tied directly to EVM storage layout.

# Summary

## Structs

* Can live in storage or memory
* Storage = reference
* Memory = copy

## Arrays

* Can live in storage or memory
* Storage = reference
* Memory = copy

## Mappings

* Only live in storage
* Always reference-based
* Cannot exist in memory or calldata
* No need to specify data location when declared as state variable