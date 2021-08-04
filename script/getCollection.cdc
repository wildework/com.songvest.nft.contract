import SongVest from "../contract/SongVest.cdc"

pub fun main(accountAddress: Address): [String] {
  let account = getAccount(accountAddress)

  let collectionCapability = account.getCapability<&AnyResource{SongVest.CollectionReceiver}>(/public/SongVestCollectionReceiver)

  let collectionRef = collectionCapability.borrow() ?? panic("Couldn't borrow /public/SongVestCollectionReceiver from account.")

  return collectionRef.listSongs()
}
