import SwiftUI
import shared
import SwiftUI_SimpleToast

struct ContentView: View {
    static let songRepo: SongRepository = {
        let factory = DatabaseDriverFactory()
        Injector.companion.initiate(databaseDriverFactory: factory)
        return Injector.Companion.shared.songRepo
    }()

    static let predefinedList = SongRepositoryImplKt.predefinedList
    static let ARTIST_FAVORITE = SongRepositoryKt.ARTIST_FAVORITE
    static let ARTIST_CLOUD_SONGS = SongRepositoryKt.ARTIST_CLOUD_SONGS
    static let defaultArtist = "Кино"
    
    private let toastOptions = SimpleToastOptions(
        hideAfter: 2
    )

	@State var isDrawerOpen: Bool = false
	@State var currentScreenVariant: ScreenVariant = ScreenVariant.start
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
    
    @State var allLikes: Dictionary<CloudSong, Int> = [:]
    @State var allDislikes: Dictionary<CloudSong, Int> = [:]
    
    @State var needShowToast = false
    @State var toastText = ""
    
    @State var needShowWarningDialog = false

	var body: some View {
	    ZStack {
            /// Navigation Bar Title part
            if !self.isDrawerOpen {
                NavigationView {
                    if (self.currentScreenVariant == .start) {
                        StartScreenView(onUpdateDone: onUpdateDone)
                    } else if (self.currentScreenVariant == .songList) {
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
                                     onSaveSongText: saveSongText,
                                     onDeleteToTrashConfirmed: deleteCurrentToTrash,
                                     onShowToast: showToast,
                                     onOpenSongAtYandexMusic: openSongAtYandexMusic,
                                     onOpenSongAtYoutubeMusic: openSongAtYoutubeMusic,
                                     onShowWarningDialog: showWarningDialog
                        )
                    } else if (self.currentScreenVariant == .cloudSearch) {
                        CloudSearchView(cloudSongList: self.currentCloudSongList,
                                        cloudSongIndex: self.currentCloudSongIndex,
                                        orderBy: self.currentCloudOrderBy,
                                        allLikes: self.allLikes,
                                        allDislikes: self.allDislikes,
                                        onLoadSuccess: refreshCloudSongList,
                                        onBackClick: back,
                                        onCloudSongClick: selectCloudSong,
                                        onOrderBySelected: selectOrderBy)
                    } else if (self.currentScreenVariant == .cloudSongText) {
                        CloudSongTextView(cloudSong: self.currentCloudSong!,
                                          cloudSongIndex: self.currentCloudSongIndex,
                                          cloudSongCount: self.currentCloudSongCount,
                                          allLikes: self.allLikes,
                                          allDislikes: self.allDislikes,
                                          onBackClick: back,
                                          onPrevClick: prevCloudSong,
                                          onNextClick: nextCloudSong,
                                          onPerformLike: performLike,
                                          onPerformDislike: performDislike,
                                          onDownloadCurrent: downloadCurrent,
                                          onOpenSongAtYandexMusic: openSongAtYandexMusic,
                                          onOpenSongAtYoutubeMusic: openSongAtYoutubeMusic,
                                          onShowWarningDialog: showWarningDialog
                                        )
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
        .simpleToast(isPresented: $needShowToast, options: toastOptions) {
            Label(self.toastText, systemImage: "exclamationmark.triangle")
               .padding()
               .background(Theme.colorMain.opacity(0.8))
               .foregroundColor(Theme.colorBg)
               .cornerRadius(10)
               .padding(.top)
        }
        .customDialog(isShowing: self.$needShowWarningDialog, dialogContent: {
            WarningDialog(
                onDismiss: {
                    self.needShowWarningDialog = false
                }
            )
        })
    }
    
    func showToast(_ text: String) {
        self.toastText = text
        withAnimation {
            self.needShowToast.toggle()
        }
    }
    
    func onUpdateDone() {
        selectArtist(Self.defaultArtist)
        self.currentScreenVariant = .songList
    }

    func selectArtist(_ artist: String) {
        print("select artist: \(artist)")
        if (Self.predefinedList.contains(artist) && artist != Self.ARTIST_FAVORITE) {
            if (artist == Self.ARTIST_CLOUD_SONGS) {
                self.currentCloudSongIndex = 0
                self.currentCloudOrderBy = OrderBy.byIdDesc
                self.currentScreenVariant = ScreenVariant.cloudSearch
            }
        } else if (self.currentArtist != artist || self.currentCount == 0) {
            print("artist changed")
            self.currentArtist = artist
            let count = Self.songRepo.getCountByArtist(artist: artist)
            self.currentCount = Int(count)
            self.currentSongIndex = 0
        }
        self.isDrawerOpen = false
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
        if (becomeFavorite) {
            showToast("Добавлено в избранное")
        } else {
            showToast("Удалено из избранного")
        }
    }
    
    func deleteCurrentToTrash() {
        print("deleting to trash: \(self.currentSong!.artist) - \(self.currentSong!.title)")
        let song = self.currentSong!.copy() as! Song
        song.deleted = true
        Self.songRepo.updateSong(song: song)
        let count = Self.songRepo.getCountByArtist(artist: self.currentArtist)
        self.currentCount = Int(count)
        if (self.currentCount > 0) {
            if (self.currentSongIndex >= self.currentCount) {
                self.currentSongIndex -= 1
            }
            refreshCurrentSong()
        } else {
            back()
        }
        showToast("Удалено")
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
        
        self.allLikes = [:]
        self.allDislikes = [:]
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
    
    func performLike(_ cloudSong: CloudSong) {
        CloudRepository.shared.voteAsync(
            cloudSong: cloudSong, voteValue: 1,
            onSuccess: {
                print($0)
                let oldCount = self.allLikes[cloudSong] ?? 0
                self.allLikes[cloudSong] = oldCount + 1
                showToast("Ваш голос засчитан")
            }, onServerMessage: {
                showToast($0)
            }, onError: {
                $0.printStackTrace()
                showToast("Ошибка в приложении")
            })
    }
    
    func performDislike(_ cloudSong: CloudSong) {
        CloudRepository.shared.voteAsync(
            cloudSong: cloudSong, voteValue: -1,
            onSuccess: {
                print($0)
                let oldCount = self.allDislikes[cloudSong] ?? 0
                self.allDislikes[cloudSong] = oldCount + 1
                showToast("Ваш голос засчитан")
            }, onServerMessage: {
                showToast($0)
            }, onError: {
                $0.printStackTrace()
                showToast("Ошибка в приложении")
            })
    }
    
    func downloadCurrent(_ cloudSong: CloudSong) {
        Self.songRepo.addSongFromCloud(song: cloudSong.asSong())
        showToast("Аккорды сохранены в локальной базе данных и добавлены в избранное")
    }
    
    func openSongAtYandexMusic(_ music: Music) {
        if let url = URL(string: music.yandexMusicUrl) {
            UIApplication.shared.open(url)
        }
    }
    
    func openSongAtYoutubeMusic(_ music: Music) {
        if let url = URL(string: music.youtubeMusicUrl) {
            UIApplication.shared.open(url)
        }
    }
    
    func showWarningDialog() {
        self.needShowWarningDialog = true
    }
}

enum ScreenVariant {
    case start
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

