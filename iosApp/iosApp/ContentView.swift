import SwiftUI
import shared

struct ContentView: View {
    static let songRepo: SongRepository = {
        let factory = DatabaseDriverFactory()
        Injector.companion.initiate(databaseDriverFactory: factory)

        //JsonLoaderKt.fillDBFromJSON()
        
//        let chords = ChordsKt.baseChords.filter { chord in
//            let str = chord as! String
//            return str.starts(with: "C") && !str.starts(with: "C#")
//        } as! Array<String>
//        print(chords.sorted())
//        print(Instrument.guitar.suffixes.sorted())

        return Injector.Companion.shared.songRepo
    }()

    static let predefinedList = SongRepositoryImplKt.predefinedList
    static let ARTIST_FAVORITE = SongRepositoryKt.ARTIST_FAVORITE
    static let ARTIST_CLOUD_SONGS = SongRepositoryKt.ARTIST_CLOUD_SONGS
    static let defaultArtist = "Кино"

	@State var isDrawerOpen: Bool = false
	@State var currentScreenVariant: ScreenVariant = ScreenVariant.songList
    @State var currentArtist: String = Self.defaultArtist
    @State var currentCount: Int = {
        let count = Self.songRepo.getCountByArtist(artist: Self.defaultArtist)
        return Int(count)
    }()
	@State var currentSongIndex: Int = 0
    @State var currentSong: Song? = nil
    
    @State var currentCloudSongList: [CloudSong]? = nil
    @State var currentCloudSongCount: Int = 0
    @State var currentCloudSongIndex: Int = 0
    @State var currentCloudSong: CloudSong? = nil
    @State var currentCloudOrderBy: OrderBy = OrderBy.byIdDesc

	var body: some View {
	    ZStack {
            /// Navigation Bar Title part
            if !self.isDrawerOpen {
                NavigationView {
                    if (self.currentScreenVariant == .songList) {
                        SongListView(artist: currentArtist,
                                     songIndex: currentSongIndex,
                                     onSongClick: selectSong,
                                     onScroll: updateSongIndexByScroll,
                                     onDrawerClick: toggleDrawer)
                            
                    } else if (self.currentScreenVariant == .songText) {
                        SongTextView(song: self.currentSong!,
                                     onBackClick: back,
                                     onPrevClick: prevSong,
                                     onNextClick: nextSong,
                                     onFavoriteToggle: toggleFavorite,
                                     onSaveSongText: saveSongText)
                            
                    } else if (self.currentScreenVariant == .cloudSearch) {
                        CloudSeaachView(cloudSongList: self.currentCloudSongList,
                                        cloudSongIndex: self.currentCloudSongIndex,
                                        orderBy: self.currentCloudOrderBy,
                                        onLoadSuccess: refreshCloudSongList,
                                        onBackClick: back,
                                        onCloudSongClick: selectCloudSong,
                                        onOrderBySelected: selectOrderBy)
                    } else if (self.currentScreenVariant == .cloudSongText) {
                        CloudSongTextView(cloudSong: self.currentCloudSong!,
                                          cloudSongIndex: self.currentCloudSongIndex,
                                          cloudSongCount: self.currentCloudSongCount,
                                          onBackClick: back,
                                          onPrevClick: prevCloudSong,
                                          onNextClick: nextCloudSong)
                    }
                }
            }
            /// Navigation Drawer part
            NavigationDrawer(isOpen: self.isDrawerOpen,
                             onArtistClick: selectArtist,
                             onDismiss: { self.isDrawerOpen.toggle() })
                 /// Other behaviors
        }
        .background(Theme.colorCommon)
        .onTapGesture {
            if self.isDrawerOpen {
                self.isDrawerOpen.toggle()
            }
        }
    }

    func selectArtist(_ artist: String) {
        print("select artist: \(artist)")
        if (Self.predefinedList.contains(artist) && artist != Self.ARTIST_FAVORITE) {
            if (artist == Self.ARTIST_CLOUD_SONGS) {
                self.currentCloudSongIndex = 0
                self.currentCloudOrderBy = OrderBy.byIdDesc
                self.currentScreenVariant = ScreenVariant.cloudSearch
            }
        } else if (self.currentArtist != artist) {
            print("artist changed")
            self.currentArtist = artist
            let count = Self.songRepo.getCountByArtist(artist: artist)
            self.currentCount = Int(count)
            self.currentSongIndex = 0
        }
        self.isDrawerOpen.toggle()
    }
    
    func toggleDrawer() {
        self.isDrawerOpen.toggle()
    }

    func selectSong(_ songIndex: Int) {
        print("select song with index: \(songIndex)")
        self.currentSongIndex = songIndex
        refreshCurrentSong()
        self.currentScreenVariant = ScreenVariant.songText
    }
    
    func updateSongIndexByScroll(_ songIndex: Int) {
        //print("scroll: \(songIndex)")
        self.currentSongIndex = songIndex
    }
    
    func prevSong() {
        if (self.currentCount == 0) {
            return
        }
        if (self.currentSongIndex > 0) {
            self.currentSongIndex -= 1
        } else {
            self.currentSongIndex = self.currentCount - 1
        }
        refreshCurrentSong()
    }
    
    func nextSong() {
        if (self.currentCount == 0) {
            return
        }
        self.currentSongIndex = (self.currentSongIndex + 1) % self.currentCount
        refreshCurrentSong()
    }
    
    func toggleFavorite() {
        let song = self.currentSong!.copy() as! Song
        let becomeFavorite = !song.favorite
        song.favorite = becomeFavorite
        Self.songRepo.updateSong(song: song)
        if (!becomeFavorite && self.currentArtist == Self.ARTIST_FAVORITE) {
            let count = Self.songRepo.getCountByArtist(artist: Self.ARTIST_FAVORITE)
            self.currentCount = Int(count)
            if (self.currentCount > 0) {
                if (self.currentSongIndex >= self.currentCount) {
                    self.currentSongIndex -= 1
                }
                refreshCurrentSong()
            } else {
                back()
            }
        } else {
            refreshCurrentSong()
        }
    }
    
    func saveSongText(newText: String) {
        let song = self.currentSong!.copy() as! Song
        song.text = newText
        Self.songRepo.updateSong(song: song)
        refreshCurrentSong()
    }
    
    func refreshCurrentSong() {
        self.currentSong = Self
            .songRepo
            .getSongByArtistAndPosition(artist: self.currentArtist, position: Int32(self.currentSongIndex))
    }
    
    func refreshCloudSongList(_ cloudSongList: [CloudSong]) {
        print(cloudSongList.count)
        self.currentCloudSongList = cloudSongList
        self.currentCloudSongCount = cloudSongList.count
    }

    func selectOrderBy(_ orderBy: OrderBy) {
        self.currentCloudSongIndex = 0
        self.currentCloudSong = nil
        self.currentCloudOrderBy = orderBy
    }
    
    func selectCloudSong(_ index: Int) {
        print("select cloud song: \(index)")
        self.currentCloudSongIndex = index
        self.currentCloudSong = self.currentCloudSongList![index]
        self.currentScreenVariant = .cloudSongText
    }
    
    func prevCloudSong() {
        if (self.currentCloudSongIndex - 1 >= 0) {
            selectCloudSong(self.currentCloudSongIndex - 1)
        }
    }
    
    func nextCloudSong() {
        if (self.currentCloudSongIndex + 1 < self.currentCloudSongCount) {
            selectCloudSong(self.currentCloudSongIndex + 1)
        }
    }
    
    func back() {
        if (self.currentScreenVariant == .songText) {
            self.currentScreenVariant = .songList
        } else if (self.currentScreenVariant == .cloudSearch) {
            self.currentCloudSongList = nil
            self.currentScreenVariant = .songList
        } else if (self.currentScreenVariant == .cloudSongText) {
            self.currentScreenVariant = .cloudSearch
        }
    }
}

enum ScreenVariant {
    case songList
    case songText
    case cloudSearch
    case cloudSongText
}

struct ContentView_Previews: PreviewProvider {
	static var previews: some View {
		ContentView()
	}
}

