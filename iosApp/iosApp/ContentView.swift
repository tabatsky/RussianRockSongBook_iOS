import SwiftUI
import shared

struct ContentView: View {
    static let songRepo: SongRepository = {
        let factory = DatabaseDriverFactory()
        Injector.companion.initiate(databaseDriverFactory: factory)

        JsonLoaderKt.fillDBFromJSON()

        return Injector.Companion.shared.songRepo
    }()

    static let predefinedList = SongRepositoryImplKt.predefinedList
    static let ARTIST_FAVORITE = SongRepositoryKt.ARTIST_FAVORITE
    static let defaultArtist = "Кино"

	@State var isDrawerOpen: Bool = false
	@State var currentScreenVariant: ScreenVariant = ScreenVariant.songList
    @State var currentArtist: String = ContentView.defaultArtist
    @State var currentCount: Int = {
        let count = ContentView.songRepo.getCountByArtist(artist: ContentView.defaultArtist)
        return Int(count)
    }()
	@State var currentSongIndex: Int = 0
    @State var currentSong: Song? = nil

	var body: some View {
	    ZStack {
            /// Navigation Bar Title part
            if !self.isDrawerOpen {
                NavigationView {
                    if (self.currentScreenVariant == ScreenVariant.songList) {
                        SongListView(artist: currentArtist, songIndex: currentSongIndex, onSongClick: selectSong, onDrawerClick: toggleDrawer)
                            
                    } else if (self.currentScreenVariant == ScreenVariant.songText) {
                        SongTextView(song: self.currentSong!, onBackClick: back, onPrevClick: prevSong, onNextClick: nextSong, onFavoriteToggle: toggleFavorite)
                            
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
        NSLog("select artist: \(artist)")
        if (ContentView.predefinedList.contains(artist) && artist != ContentView.ARTIST_FAVORITE) {
            return
        }
        self.currentArtist = artist
        let count = ContentView.songRepo.getCountByArtist(artist: artist)
        self.currentCount = Int(count)
        self.isDrawerOpen.toggle()
    }
    
    func toggleDrawer() {
        self.isDrawerOpen.toggle()
    }

    func selectSong(_ songIndex: Int) {
        NSLog("select song with index: \(songIndex)")
        self.currentSongIndex = songIndex
        refreshCurrentSong()
        self.currentScreenVariant = ScreenVariant.songText
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
        ContentView.songRepo.updateSong(song: song)
        if (!becomeFavorite && self.currentArtist == ContentView.ARTIST_FAVORITE) {
            let count = ContentView.songRepo.getCountByArtist(artist: ContentView.ARTIST_FAVORITE)
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
    
    func refreshCurrentSong() {
        self.currentSong = ContentView
            .songRepo
            .getSongByArtistAndPosition(artist: self.currentArtist, position: Int32(self.currentSongIndex))
    }

    func back() {
        if (self.currentScreenVariant == ScreenVariant.songText) {
            self.currentScreenVariant = ScreenVariant.songList
        }
    }
}

enum ScreenVariant {
    case songList
    case songText
}

struct ContentView_Previews: PreviewProvider {
	static var previews: some View {
		ContentView()
	}
}

