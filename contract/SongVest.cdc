pub contract SongVest {

  pub event SongMintEvent(series: UInt, serialNumber: UInt)
  pub event SongAddEvent(series: UInt, serialNumber: UInt, receiverAddress: Address)
  pub event SongRemoveEvent(series: UInt, serialNumber: UInt, senderAddress: Address)

  pub resource Song {
    pub let series: UInt
    pub let title: String
    pub let writers: String
    pub let artist: String
    pub let description: String
    pub let creator: String
    pub let supply: UInt
    pub let serialNumber: UInt

    init(series: UInt, title: String, writers: String, artist: String, description: String, creator: String, supply: UInt, serialNumber: UInt) {
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

  pub resource interface CollectionReceiver {
    pub fun add(song: @Song, receiverAddress: Address?)
    pub fun listSongs(): [String]
  }

  pub resource Collection: CollectionReceiver {
    pub var songs: @[Song]
    init() {
      self.songs <- []
    }
    destroy() {
      var cursor = 0
      while cursor < self.songs.length {
        destroy self.songs.remove(at: cursor)
        cursor = cursor + 1
      }
      destroy self.songs
    }
    pub fun add(song: @Song, receiverAddress: Address?) {
      if receiverAddress != nil {
        emit SongAddEvent(series: song.series, serialNumber: song.serialNumber, receiverAddress: receiverAddress!)
      }
      
      self.songs.append(<- song)
    }
    pub fun remove(series: UInt, serialNumber: UInt, senderAddress: Address): @Song {
      var cursor = 0
      while cursor < self.songs.length {
        if (self.songs[cursor].series == series && self.songs[cursor].serialNumber == serialNumber) {
          emit SongRemoveEvent(series: self.songs[cursor].series, serialNumber: self.songs[cursor].serialNumber, senderAddress: senderAddress)
          return <- self.songs.remove(at: cursor)
        }
        cursor = cursor + 1
      }

      return panic("Song with series and serial number wasn't found.")
    }
    pub fun listSongs(): [String] {
      let list: [String] = []

      var cursor = 0
      while cursor < self.songs.length {
        list.append("series ".concat(self.songs[cursor].series.toString()).concat(" #").concat(self.songs[cursor].serialNumber.toString()).concat(" – ").concat(self.songs[cursor].title))
        cursor = cursor + 1
      }

      return list
    }
  }

  pub fun createCollection(): @Collection {
    return <- create Collection()
  }

  pub resource Minter {
    pub var seriesNumber: UInt
    init() {
      self.seriesNumber = 0
    }
    pub fun mintSong(seriesNumber: UInt, title: String, writers: String, artist: String, description: String, creator: String, supply: UInt): @Collection {
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
          collection.add(
            song: <- create Song(
              series: self.seriesNumber,
              title: title,
              writers: writers,
              artist: artist,
              description: description,
              creator: creator,
              supply: supply,
              serialNumber: serialNumber
            ),
            receiverAddress: nil
          )
          serialNumber = serialNumber + 1 as UInt
        }
      }

      return <- collection
    }
  }

  init() {
    self.account.save(<- create Minter(), to: /storage/SongVestMinter)
  }
}