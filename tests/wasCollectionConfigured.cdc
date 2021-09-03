import SongVest from "../contract/SongVest.cdc"
import NonFungibleToken from "../contract/NonFungibleToken.cdc"

pub fun main(userAddress: Address, randomAddress: Address): {Address: Bool} {
  let checks: {Address: Bool} = {}
  
  checks[userAddress] = getAccount(userAddress)
    .getCapability<&AnyResource{NonFungibleToken.Receiver, NonFungibleToken.CollectionPublic}>(SongVest.CollectionPublicPath)
    .check()

  checks[randomAddress] = getAccount(randomAddress)
    .getCapability<&AnyResource{NonFungibleToken.Receiver, NonFungibleToken.CollectionPublic}>(SongVest.CollectionPublicPath)
    .check()

  return checks
}