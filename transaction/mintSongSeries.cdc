import SongVest from "../contract/SongVest.cdc"
import NonFungibleToken from "../contract/NonFungibleToken.cdc"

transaction(
  seriesNumber: UInt,
  title: String,
  writers: String,
  artist: String,
  description: String,
  creator: String,
  supply: UInt
) {
  let minterRef: &SongVest.Minter
  let collectionRef: &AnyResource{NonFungibleToken.Receiver}
  prepare(account: AuthAccount) {
    self.minterRef = account.borrow<&SongVest.Minter>(from: SongVest.MinterStoragePath) ?? panic("Couldn't borrow SongVest.Minter")
    self.collectionRef = account.getCapability<&AnyResource{NonFungibleToken.Receiver}>(SongVest.CollectionPublicPath).borrow() ?? panic("Couldn't borrow NonFungibleToken.Receiver")
  }
  execute {
    let collection <- self.minterRef.mintSong(
      seriesNumber: seriesNumber,
      title: title,
      writers: writers,
      artist: artist,
      description: description,
      creator: creator,
      supply: supply
    )

    // Transfer all songs to the collection.
    let ids = collection.getIDs()
    var cursor = 0
    while cursor < ids.length {
      let song <- collection.withdraw(withdrawID: ids[cursor])
      self.collectionRef.deposit(token: <- song)
      cursor = cursor + 1
    }

    // Destroy empty collection.
    destroy collection
  }
}
