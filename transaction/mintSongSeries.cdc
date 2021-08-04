import SongVest from "../contract/SongVest.cdc"

transaction(seriesNumber: UInt, title: String, writers: String, artist: String, description: String, creator: String, supply: UInt) {
  let minterRef: &SongVest.Minter
  let collectionRef: &SongVest.Collection
  prepare(account: AuthAccount) {
    self.minterRef = account.borrow<&SongVest.Minter>(from: /storage/SongVestMinter) ?? panic("Couldn't borrow SongVest.Minter")
    self.collectionRef = account.borrow<&SongVest.Collection>(from: /storage/SongVestCollection) ?? panic("Couldn't borrow SongVest.Collection")
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
    var cursor = 0
    while cursor < collection.songs.length {
      let song <- collection.songs.removeFirst()
      self.collectionRef.add(song: <- song, receiverAddress: nil)
    }

    // Destroy empty collection.
    destroy collection
  }
}
