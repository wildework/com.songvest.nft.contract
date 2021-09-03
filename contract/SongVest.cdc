import NonFungibleToken from "./NonFungibleToken.cdc"

pub contract SongVest: NonFungibleToken {

  pub var totalSupply: UInt64

  pub let CollectionStoragePath: StoragePath
  pub let CollectionPublicPath: PublicPath
  pub let MinterPath: StoragePath

  pub event ContractInitialized()
  pub event Withdraw(id: UInt64, from: Address?)
  pub event Deposit(id: UInt64, to: Address?)

  pub event SongMintEvent(series: UInt, serialNumber: UInt)
  pub event SongAddEvent(series: UInt, serialNumber: UInt, receiverAddress: Address)
  pub event SongRemoveEvent(series: UInt, serialNumber: UInt, senderAddress: Address)

  // The SongVest Song NFT.
  pub resource NFT: NonFungibleToken.INFT {
    pub let id: UInt64

    pub let series: UInt
    pub let title: String
    pub let writers: String
    pub let artist: String
    pub let description: String
    pub let creator: String
    pub let supply: UInt
    pub let serialNumber: UInt

    init(
      series: UInt,
      title: String,
      writers: String,
      artist: String,
      description: String,
      creator: String,
      supply: UInt,
      serialNumber: UInt
    ) {
      self.id = 1_000_000_000 * UInt64(series) + UInt64(serialNumber)

      self.series = series
      self.title = title
      self.writers = writers
      self.artist = artist
      self.description = description
      self.creator = creator
      self.supply = supply
      self.serialNumber = serialNumber
    }
  }

  // pub resource interface CollectionReceiver {
  //   pub fun add(song: @Song, receiverAddress: Address?)
  //   pub fun listSongs(): [String]
  // }

  pub resource Collection: NonFungibleToken.Provider, NonFungibleToken.Receiver, NonFungibleToken.CollectionPublic {
    pub var ownedNFTs: @{UInt64: NonFungibleToken.NFT}
    init() {
      self.ownedNFTs <- {}
    }
    destroy() {
      destroy self.ownedNFTs
    }

    pub fun withdraw(withdrawID: UInt64): @NonFungibleToken.NFT {
      post {
          result.id == withdrawID: "The ID of the withdrawn Song must be the same as the requested ID."
      }
      let token <- self.ownedNFTs.remove(key: withdrawID) ?? panic("Song not found in collection.")

      emit Withdraw(id: token.id, from: self.owner?.address)

      return <- token
    }
    
    pub fun deposit(token: @NonFungibleToken.NFT) {
      let token <- token as! @SongVest.NFT
      let id = token.id
      let existingToken <- self.ownedNFTs[id] <- token

      emit Deposit(id: id, to: self.owner?.address)

      destroy existingToken
    }

    pub fun getIDs(): [UInt64] {
      return self.ownedNFTs.keys
    }
    pub fun borrowNFT(id: UInt64): &NonFungibleToken.NFT {
      return &self.ownedNFTs[id] as &NonFungibleToken.NFT
    }
  }

  pub fun createEmptyCollection(): @Collection {
    post {
      result.getIDs().length == 0: "The created collection must be empty!"
    }
    return <- create Collection()
  }

  pub resource Minter {
    pub var seriesNumber: UInt
    init() {
      self.seriesNumber = 0
    }
    pub fun mintSong(
      seriesNumber: UInt,
      title: String,
      writers: String,
      artist: String,
      description: String,
      creator: String,
      supply: UInt
    ): @Collection {
      var collection <- create Collection()

      if self.seriesNumber >= seriesNumber {
        // This song series was already minted.
        log("Series number \"".concat(seriesNumber.toString()).concat("\" has been used."))
      } else {
        // This is a brand new song series.
        self.seriesNumber = seriesNumber
        var serialNumber: UInt = 0
        while serialNumber < supply {
          emit SongMintEvent(series: self.seriesNumber, serialNumber: serialNumber)
          let song <- create NFT(
            series: self.seriesNumber,
            title: title,
            writers: writers,
            artist: artist,
            description: description,
            creator: creator,
            supply: supply,
            serialNumber: serialNumber
          )
          collection.deposit(token: <- song)
          serialNumber = serialNumber + 1 as UInt
          SongVest.totalSupply = SongVest.totalSupply + 1 as UInt64
        }
      }

      return <- collection
    }
  }

  init() {
    // Initialize the total supply.
    self.totalSupply = 0

    // Paths
    self.CollectionStoragePath = /storage/SongVestCollection
    self.CollectionPublicPath = /public/SongVestCollection
    self.MinterStoragePath = /storage/SongVestMinter

    self.account.save(<- create Minter(), to: self.MinterStoragePath)

    emit ContractInitialized()
  }
}