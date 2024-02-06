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
    
    private var appStateMachine: AppStateMachine {
        AppStateMachine()
    }
    
    @State var appState: AppState = AppState()
    
    @State var needShowToast = false
    @State var toastText = ""
    
    @State var orientation = UIDevice.current.orientation

    let orientationChanged = NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification)
        .makeConnectable()
        .autoconnect()

    @State var isReady = true
    
	var body: some View {
	    ZStack {
            /// Navigation Bar Title part
            if !self.appState.localState.isDrawerOpen {
                NavigationView {
                    if (!self.isReady) {
                        VStack {
                            Spacer()
                            HStack {
                                Spacer()
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: self.appState.theme.colorMain))
                                    .scaleEffect(5.0)
                                Spacer()
                            }
                            Spacer()
                        }
                        .background(self.appState.theme.colorBg)
                    } else if (self.appState.currentScreenVariant == .start) {
                        StartScreenView(
                            theme: self.appState.theme,
                            onUpdateDone: onUpdateDone
                        )
                    } else if (self.appState.currentScreenVariant == .songList) {
                        SongListView(theme: self.appState.theme,
                                     localState: self.appState.localState,
                                     onPerformAction: self.performAction
                                     
                        )
                    } else if (self.appState.currentScreenVariant == .songText) {
                        SongTextView(theme: self.appState.theme,
                                     song: self.appState.localState.currentSong!,
                                     onPerformAction: self.performAction
                                     
                        )
                    } else if (self.appState.currentScreenVariant == .cloudSearch) {
                        CloudSearchView(theme: self.appState.theme,
                                        cloudState: self.appState.cloudState,
                                        onPerformAction: self.performAction
                        )
                    } else if (self.appState.currentScreenVariant == .cloudSongText) {
                        CloudSongTextView(theme: self.appState.theme,
                                          cloudState: self.appState.cloudState,
                                          onPerformAction: self.performAction
                        )
                    } else if (self.appState.currentScreenVariant == .settings) {
                        SettingsView(
                            theme: self.appState.theme,
                            onBackClick: back,
                            onReloadSettings: reloadSettings
                        )
                    }
                }
            }
            /// Navigation Drawer part
            NavigationDrawer(theme: self.appState.theme,
                             artists: self.appState.artists,
                             isOpen: self.appState.localState.isDrawerOpen,
                             onArtistClick: selectArtist,
                             onDismiss: { self.appState.localState.isDrawerOpen.toggle() })
                 /// Other behaviors
        }
        .background(self.appState.theme.colorCommon)
        .onTapGesture {
            if self.appState.localState.isDrawerOpen {
                self.appState.localState.isDrawerOpen.toggle()
            }
        }
        .onReceive(self.orientationChanged) { _ in
            forceReload()
        }
        .simpleToast(isPresented: $needShowToast, options: toastOptions) {
            Label(self.toastText, systemImage: "exclamationmark.triangle")
               .padding()
               .background(self.appState.theme.colorMain.opacity(0.8))
               .foregroundColor(self.appState.theme.colorBg)
               .cornerRadius(10)
               .padding(.top)
        }
    }
    
    func performAction(_ action: AppUIAction) {
        if let newState = self.appStateMachine.performAction(appState: self.appState, action: action) {
            self.appState = newState
        } else if (action is LocalPrevClick) {
            self.prevSong()
        } else if (action is LocalNextClick) {
            self.nextSong()
        } else if (action is FavoriteToggle) {
            self.toggleFavorite()
        } else if (action is SaveSongText) {
            self.saveSongText((action as! SaveSongText).newText)
        } else if (action is ConfirmDeleteToTrash) {
            self.deleteCurrentToTrash()
        } else if (action is ShowToast) {
            self.showToast((action as! ShowToast).text)
        } else if (action is OpenSongAtVkMusic) {
            self.openSongAtVkMusic((action as! OpenSongAtVkMusic).music)
        } else if (action is OpenSongAtYandexMusic) {
            self.openSongAtYandexMusic((action as! OpenSongAtYandexMusic).music)
        } else if (action is OpenSongAtYoutubeMusic) {
            self.openSongAtYoutubeMusic((action as! OpenSongAtYoutubeMusic).music)
        } else if (action is SendWarning) {
            self.sendWarning((action as! SendWarning).warning)
        } else if (action is LoadSuccess) {
            self.refreshCloudSongList((action as! LoadSuccess).cloudSongList)
        } else if (action is CloudSongClick) {
            self.selectCloudSong((action as! CloudSongClick).index)
        } else if (action is SelectOrderBy) {
            self.selectOrderBy((action as! SelectOrderBy).orderBy)
        } else if (action is BackupSearchFor) {
            self.backupSearchFor((action as! BackupSearchFor).searchFor)
        } else if (action is CloudPrevClick) {
            self.prevCloudSong()
        } else if (action is CloudNextClick) {
            self.nextCloudSong()
        } else if (action is LikeClick) {
            self.performLike((action as! LikeClick).cloudSong)
        } else if (action is DislikeClick) {
            self.performDislike((action as! DislikeClick).cloudSong)
        } else if (action is DownloadClick) {
            self.downloadCurrent((action as! DownloadClick).cloudSong)
        }
    }
    
    func forceReload() {
        self.isReady = false
        Task.detached {
            try await Task.sleep(nanoseconds: 50 * 100 * 100)
            Task.detached { @MainActor in
                self.isReady = true
            }
        }
    }
    
    func showToast(_ text: String) {
        self.toastText = text
        withAnimation {
            self.needShowToast.toggle()
        }
    }
    
    func onUpdateDone() {
        selectArtist(Self.defaultArtist)
        self.appState.currentScreenVariant = .songList
    }

    func selectArtist(_ artist: String) {
        print("select artist: \(artist)")
        if (Self.predefinedList.contains(artist) && artist != Self.ARTIST_FAVORITE) {
            if (artist == Self.ARTIST_CLOUD_SONGS) {
                self.appState.cloudState.searchForBackup = ""
                self.appState.cloudState.currentCloudSongIndex = 0
                self.appState.cloudState.currentCloudOrderBy = OrderBy.byIdDesc
                self.appState.currentScreenVariant = ScreenVariant.cloudSearch
            }
        } else if (self.appState.localState.currentArtist != artist || self.appState.localState.currentCount == 0) {
            print("artist changed")
            self.appState.localState.currentArtist = artist
            let count = Self.songRepo.getCountByArtist(artist: artist)
            self.appState.localState.currentCount = Int(count)
            self.appState.localState.currentSongIndex = 0
        }
        self.appState.localState.isDrawerOpen = false
    }
    
    func toggleDrawer() {
        self.appState.localState.isDrawerOpen.toggle()
    }

    func selectSong(_ songIndex: Int) {
        print("select song with index: \(songIndex)")
        self.appState.localState.currentSongIndex = songIndex
        refreshCurrentSong()
        self.appState.currentScreenVariant = ScreenVariant.songText
    }
    
    func updateSongIndexByScroll(_ songIndex: Int) {
        //print("scroll: \(songIndex)")
        self.appState.localState.currentSongIndex = songIndex
    }
    
    func prevSong() {
        if (self.appState.localState.currentCount == 0) {
            return
        }
        if (self.appState.localState.currentSongIndex > 0) {
            self.appState.localState.currentSongIndex -= 1
        } else {
            self.appState.localState.currentSongIndex = self.appState.localState.currentCount - 1
        }
        refreshCurrentSong()
    }
    
    func nextSong() {
        if (self.appState.localState.currentCount == 0) {
            return
        }
        self.appState.localState.currentSongIndex = (self.appState.localState.currentSongIndex + 1) % self.appState.localState.currentCount
        refreshCurrentSong()
    }
    
    func toggleFavorite() {
        let song = self.appState.localState.currentSong!.copy() as! Song
        let becomeFavorite = !song.favorite
        song.favorite = becomeFavorite
        Self.songRepo.updateSong(song: song)
        if (!becomeFavorite && self.appState.localState.currentArtist == Self.ARTIST_FAVORITE) {
            let count = Self.songRepo.getCountByArtist(artist: Self.ARTIST_FAVORITE)
            self.appState.localState.currentCount = Int(count)
            if (self.appState.localState.currentCount > 0) {
                if (self.appState.localState.currentSongIndex >= self.appState.localState.currentCount) {
                    self.appState.localState.currentSongIndex -= 1
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
        print("deleting to trash: \(self.appState.localState.currentSong!.artist) - \(self.appState.localState.currentSong!.title)")
        let song = self.appState.localState.currentSong!.copy() as! Song
        song.deleted = true
        Self.songRepo.updateSong(song: song)
        let count = Self.songRepo.getCountByArtist(artist: self.appState.localState.currentArtist)
        self.appState.localState.currentCount = Int(count)
        self.appState.artists = ContentView.songRepo.getArtists()
        if (self.appState.localState.currentCount > 0) {
            if (self.appState.localState.currentSongIndex >= self.appState.localState.currentCount) {
                self.appState.localState.currentSongIndex -= 1
            }
            refreshCurrentSong()
        } else {
            back()
        }
        showToast("Удалено")
    }
    
    func saveSongText(_ newText: String) {
        let song = self.appState.localState.currentSong!.copy() as! Song
        song.text = newText
        Self.songRepo.updateSong(song: song)
        refreshCurrentSong()
    }
    
    func refreshCurrentSong() {
        self.appState.localState.currentSong = Self
            .songRepo
            .getSongByArtistAndPosition(artist: self.appState.localState.currentArtist, position: Int32(self.appState.localState.currentSongIndex))
    }
    
    func refreshCloudSongList(_ cloudSongList: [CloudSong]) {
        print(cloudSongList.count)
        
        self.appState.cloudState.allLikes = [:]
        self.appState.cloudState.allDislikes = [:]
        self.appState.cloudState.currentCloudSongList = cloudSongList
        self.appState.cloudState.currentCloudSongCount = cloudSongList.count
        self.appState.cloudState.currentCloudSongIndex = 0
        self.appState.cloudState.currentCloudSong = nil
    }

    func selectOrderBy(_ orderBy: OrderBy) {
        self.appState.cloudState.currentCloudSongIndex = 0
        self.appState.cloudState.currentCloudSong = nil
        self.appState.cloudState.currentCloudOrderBy = orderBy
    }
    
    func backupSearchFor(_ searchFor: String) {
        self.appState.cloudState.searchForBackup = searchFor
    }
    
    func selectCloudSong(_ index: Int) {
        print("select cloud song: \(index)")
        self.appState.cloudState.currentCloudSongIndex = index
        self.appState.cloudState.currentCloudSong = self.appState.cloudState.currentCloudSongList![index]
        self.appState.currentScreenVariant = .cloudSongText
    }
    
    func prevCloudSong() {
        if (self.appState.cloudState.currentCloudSongIndex - 1 >= 0) {
            selectCloudSong(self.appState.cloudState.currentCloudSongIndex - 1)
        }
    }
    
    func nextCloudSong() {
        if (self.appState.cloudState.currentCloudSongIndex + 1 < self.appState.cloudState.currentCloudSongCount) {
            selectCloudSong(self.appState.cloudState.currentCloudSongIndex + 1)
        }
    }
    
    func back() {
        if (self.appState.currentScreenVariant == .songText) {
            self.appState.currentScreenVariant = .songList
        } else if (self.appState.currentScreenVariant == .cloudSearch) {
            self.appState.cloudState.currentCloudSongList = nil
            self.appState.currentScreenVariant = .songList
        } else if (self.appState.currentScreenVariant == .cloudSongText) {
            self.appState.currentScreenVariant = .cloudSearch
        } else if (self.appState.currentScreenVariant == .settings) {
            self.appState.currentScreenVariant = .songList
        }
    }
    
    func performLike(_ cloudSong: CloudSong) {
        CloudRepository.shared.voteAsync(
            cloudSong: cloudSong, voteValue: 1,
            onSuccess: {
                print($0)
                let oldCount = self.appState.cloudState.allLikes[cloudSong] ?? 0
                self.appState.cloudState.allLikes[cloudSong] = oldCount + 1
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
                let oldCount = self.appState.cloudState.allDislikes[cloudSong] ?? 0
                self.appState.cloudState.allDislikes[cloudSong] = oldCount + 1
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
        self.appState.artists = ContentView.songRepo.getArtists()
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
    
    func openSongAtVkMusic(_ music: Music) {
        if let url = URL(string: music.vkMusicUrl) {
            UIApplication.shared.open(url)
        }
    }
    
    func sendWarning(_ warning: Warning) {
        CloudRepository.shared.addWarningAsync(
            warning: warning,
            onSuccess: {
                showToast("Уведомление отправлено")
            }, onServerMessage: {
                showToast($0)
            }, onError: {
                $0.printStackTrace()
                showToast("Ошибка в приложении")
            })
    }
    
    func openSettings() {
        print("opening settings")
        self.appState.currentScreenVariant = .settings
    }
    
    func reloadSettings() {
        self.appState.theme = Preferences.loadThemeVariant().theme(fontScale: Preferences.loadFontScaleVariant().fontScale())
    }
}

enum ScreenVariant {
    case start
    case songList
    case songText
    case cloudSearch
    case cloudSongText
    case settings
}

struct ContentView_Previews: PreviewProvider {
	static var previews: some View {
		ContentView()
	}
}

