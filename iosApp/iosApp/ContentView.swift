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
    @State var isCurrentFavorite: Bool = false

	var body: some View {
	    ZStack {
            /// Navigation Bar Title part
            if !self.isDrawerOpen {
                NavigationView {
                    if (self.currentScreenVariant == ScreenVariant.songList) {
                        SongListView(artist: currentArtist, onSongClick: selectSong)
                            .toolbar(content: {
                                ToolbarItemGroup(placement: .navigationBarLeading) {
                                    Button(action: {
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                            self.isDrawerOpen.toggle()
                                        }
                                    }) {
                                        Image("ic_drawer")
                                            .resizable()
                                            .frame(width: 32.0, height: 32.0)
                                    }
                                    Text(self.currentArtist)
                                        .bold()
                                }
                            })
                            .navigationBarTitleDisplayMode(.inline)
                            .navigationBarColor(backgroundColor: Theme.colorCommon, titleColor: colorBlack)
                    } else if (self.currentScreenVariant == ScreenVariant.songText) {
                        SongTextView(song: self.currentSong!)
                            .toolbar(content: {
                                ToolbarItem(placement: .navigationBarLeading) {
                                    Button(action: {
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                            back()
                                        }
                                    }) {
                                        Image("ic_back")
                                            .resizable()
                                            .frame(width: 32.0, height: 32.0)
                                    }
                                }
                                ToolbarItemGroup(placement: .navigationBarTrailing) {
                                    Button(action: {
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                            prevSong()
                                        }
                                    }) {
                                        Image("ic_left")
                                            .resizable()
                                            .frame(width: 32.0, height: 32.0)
                                    }
                                    Button(action: {
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                            toggleFavorite()
                                        }
                                    }) {
                                        if (self.isCurrentFavorite) {
                                            Image("ic_delete")
                                                .resizable()
                                                .frame(width: 32.0, height: 32.0)
                                        } else {
                                            Image("ic_star")
                                                .resizable()
                                                .frame(width: 32.0, height: 32.0)
                                        }
                                    }
                                    Button(action: {
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                            nextSong()
                                        }
                                    }) {
                                        Image("ic_right")
                                            .resizable()
                                            .frame(width: 32.0, height: 32.0)
                                    }
                                }
                            })
                            .navigationBarTitleDisplayMode(.inline)
                            .navigationBarColor(backgroundColor: Theme.colorCommon, titleColor: colorBlack)
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
        self.isCurrentFavorite = self.currentSong!.favorite
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

struct SongListView: View {
    let artist: String
    let onSongClick: (Int) -> ()

    var body: some View {
        GeometryReader { geometry in
            ScrollView(.vertical) {
                let columns = [
                    GridItem(.flexible())
                ]
                let currentSongList = ContentView.songRepo.getSongsByArtist(artist: self.artist)
                LazyVGrid(columns: columns, spacing: 0) {
                    ForEach(0..<currentSongList.count, id: \.self) { index in
                        let title = currentSongList[index].title
                        Text(title)
                            .foregroundColor(Theme.colorMain)
                            .padding(16)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Theme.colorBg)
                            .highPriorityGesture(
                                 TapGesture()
                                     .onEnded { _ in
                                         onSongClick(index)
                                     }
                             )
                        Rectangle()
                            .fill(Theme.colorCommon)
                            .frame(height: 3)
                            .edgesIgnoringSafeArea(.horizontal)
                    }.frame(maxWidth: .infinity, maxHeight: geometry.size.height)
                }
                Spacer()
            }
            .background(Theme.colorBg)
        }
    }
}

struct SongTextView: View {
    let song: Song

    var body: some View {
        GeometryReader { geometry in
            let title = song.title
            
            VStack {
                Text(title)
                    .bold()
                    .padding(24)
                    .frame(maxWidth: geometry.size.width, alignment: .leading)
                
                ScrollView(.vertical) {
                    let text = song.text
                    Text(text)
                        .padding(8)
                        .frame(maxWidth: geometry.size.width, alignment: .leading)
                }
            }
        }
    }
}

struct NavigationDrawer: View {
    private let width = UIScreen.main.bounds.width - 100
    private let height = UIScreen.main.bounds.height
    let isOpen: Bool
    let onArtistClick: (String) -> ()
    let onDismiss: () -> ()

    var body: some View {
        HStack {
            DrawerContent(onArtistClick: onArtistClick, onDismiss: onDismiss)
                .frame(width: self.width)
                .background(Theme.colorMain)
                .offset(x: self.isOpen ? 0 : -self.width)
                .animation(.default)
            Spacer()
        }
        .navigationBarColor(backgroundColor: Theme.colorCommon, titleColor: colorBlack)
    }
}

struct DrawerContent: View {
    let onArtistClick: (String) -> ()
    let onDismiss: () -> ()

    var body: some View {
        VStack {
            GeometryReader { geometry in
                ScrollView(.vertical) {
                    let columns = [
                        GridItem(.flexible())
                    ]
                    let artists = ContentView.songRepo.getArtists()
                    HStack {
                        Button(action: {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                onDismiss()
                            }
                        }) {
                            Image("ic_drawer")
                                .resizable()
                                .frame(width: 32.0, height: 32.0)
                        }
                        Text("Меню")
                            .bold()
                            .foregroundColor(Theme.colorBg)
                    }
                        .padding(16)
                        .frame(maxWidth: geometry.size.width, alignment: .leading)
                        .background(Theme.colorCommon)
                    LazyVGrid(columns: columns, spacing: 0) {
                        ForEach(0..<artists.count, id: \.self) { index in
                            let artist = artists[index]
                            let isBold = ContentView.predefinedList.contains(artist)
                            Text(artist)
                                .font(Font.headline.weight(isBold ? .bold : .regular))
                                .foregroundColor(Theme.colorBg)
                                .padding(16)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(Theme.colorMain)
                                .highPriorityGesture(
                                    TapGesture()
                                        .onEnded { _ in
                                            onArtistClick(artist)
                                        }
                                )
                            Rectangle()
                                .fill(Theme.colorCommon)
                                .frame(height: 3)
                                .edgesIgnoringSafeArea(.horizontal)
                        }.frame(maxWidth: .infinity, maxHeight: geometry.size.height)
                    }
                    Spacer()
                }
                .background(Theme.colorMain)
            }
        }
    }
}
