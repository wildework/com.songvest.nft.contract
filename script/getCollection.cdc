import SongVest from "../contract/SongVest.cdc"
import NonFungibleToken from "../contract/NonFungibleToken.cdc"

pub fun main(accountAddress: Address): [String] {
  let account = getAccount(accountAddress)

  let collectionCapability = account.getCapability<&SongVest.Collection{NonFungibleToken.CollectionPublic, SongVest.SongCollection}>(SongVest.CollectionPublicPath)

  let collectionRef = collectionCapability.borrow() ?? panic("Couldn't borrow SongVest.CollectionPublicPath from account.")
  let ids = collectionRef.getIDs()

  let list: [String] = []

  var cursor = 0
  while cursor < ids.length {
    let songRef = collectionRef.borrowSong(id: ids[cursor])
    list.append("series ".concat(songRef.series.toString()).concat(" #").concat(songRef.serialNumber.toString()).concat(" – ").concat(songRef.title))
    cursor = cursor + 1
  }

  return list
}
