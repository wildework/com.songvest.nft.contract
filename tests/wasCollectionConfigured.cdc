import SongVest from "../contract/SongVest.cdc"

pub fun main(userAddress: Address, randomAddress: Address): {Address: Bool} {
  let checks: {Address: Bool} = {}
  
  checks[userAddress] = getAccount(userAddress)
    .getCapability<&AnyResource{SongVest.CollectionReceiver}>(/public/SongVestCollectionReceiver)
    .check()

  checks[randomAddress] = getAccount(randomAddress)
    .getCapability<&AnyResource{SongVest.CollectionReceiver}>(/public/SongVestCollectionReceiver)
    .check()

  return checks
}