package jatx.russianrocksongbook.common.state

import jatx.russianrocksongbook.common.data.repository.impl.predefinedList
import jatx.russianrocksongbook.common.di.Injector
import jatx.russianrocksongbook.common.domain.models.Music
import jatx.russianrocksongbook.common.domain.models.Warning
import jatx.russianrocksongbook.common.domain.repository.ARTIST_CLOUD_SONGS
import jatx.russianrocksongbook.common.domain.repository.ARTIST_FAVORITE
import jatx.russianrocksongbook.common.networking.CloudRepository
import jatx.russianrocksongbook.common.networking.CloudSong
import jatx.russianrocksongbook.common.networking.OrderBy
import jatx.russianrocksongbook.common.networking.asCloudSong
import jatx.russianrocksongbook.common.networking.asSong

class KotlinStateMachine(
    val showToast: (String) -> Unit,
    val openUrl: (String) -> Unit
) {
    fun canPerformAction(action: AppUIAction) = action is KotlinUIAction

    fun performAction(appState: AppState, action: AppUIAction, changeState: (AppState) -> Unit) {
        when (action) {
            is SelectArtist -> {
                selectArtist(appState, changeState, action.artist, action.callback)
            }
            is OpenSettings -> {
                openSettings(appState, changeState)
            }
            is ReloadSettings -> {
                reloadSettings(appState, changeState, action.themeVariant, action.fontScaleVariant)
            }
            is SongClick -> {
                selectSong(appState, changeState, action.songIndex)
            }
            is LocalScroll -> {
                updateSongIndexByScroll(appState, changeState, action.songIndex)
            }
            is DrawerClick -> {
                toggleDrawer(appState, changeState)
            }
            is BackClick -> {
                back(appState, changeState)
            }
            is LocalPrevClick -> {
                prevSong(appState, changeState)
            }
            is LocalNextClick -> {
                nextSong(appState, changeState)
            }
            is FavoriteToggle -> {
                toggleFavorite(appState, changeState, action.emptyListCallback)
            }
            is ConfirmDeleteToTrash -> {
                deleteCurrentToTrash(appState, changeState, action.emptyListCallback)
            }
            is SaveSongText -> {
                saveSongText(appState, changeState, action.newText)
            }
            is UploadCurrentToCloud -> {
                uploadCurrentToCloud(appState)
            }
            is SendWarning -> {
                sendWarning(action.warning)
            }
            is CloudSearch -> {
                searchSongs(appState, changeState, action.searchFor, action.orderBy)
            }
            is CloudSongClick -> {
                selectCloudSong(appState, changeState, action.index)
            }
            is CloudPrevClick -> {
                prevCloudSong(appState, changeState)
            }
            is CloudNextClick -> {
                nextCloudSong(appState, changeState)
            }
            is SelectOrderBy -> {
                selectOrderBy(appState, changeState, action.orderBy)
            }
            is BackupSearchFor -> {
                backupSearchFor(appState, changeState, action.searchFor)
            }
            is LikeClick -> {
                performLike(appState, changeState, action.cloudSong)
            }
            is DislikeClick -> {
                performDislike(appState, changeState, action.cloudSong)
            }
            is DownloadClick -> {
                downloadCurrent(appState, changeState, action.cloudSong)
            }
            is UpdateDone -> {
                onUpdateDone(appState, changeState)
            }
            is OpenSongAtVkMusic -> {
                openSongAtVkMusic(action.music)
            }
            is OpenSongAtYandexMusic -> {
                openSongAtYandexMusic(action.music)
            }
            is OpenSongAtYoutubeMusic -> {
                openSongAtYoutubeMusic(action.music)
            }
            is ShowToast -> {
                showToast(action.text)
            }
        }
    }

    private fun selectArtist(appState: AppState, changeState: (AppState) -> Unit, artist: String, callback: () -> Unit) {
        println("select artist: $artist")
        var newState = appState
        if (artist in predefinedList && artist != ARTIST_FAVORITE) {
            if (artist == ARTIST_CLOUD_SONGS) {
                val newCloudState = newState.cloudState
                    .changeSearchForBackup("")
                    .changeCloudSongIndex(0)
                    .changeOrderBy(OrderBy.BY_ID_DESC)
                    .changeCloudSongList(null)
                newState = newState
                    .changeCloudState(newCloudState)
                    .changeScreenVariant(ScreenVariant.CLOUD_SEARCH)
            }
        } else if (appState.localState.currentArtist != artist || appState.localState.currentCount == 0) {
            println("artist changed")
            val count = Injector.songRepo.getCountByArtist(artist)
            val songList = Injector.songRepo.getSongsByArtist(artist)
            val newLocalState = newState.localState
                .changeArtist(artist)
                .changeCount(count)
                .changeSongList(songList)
                .changeSongIndex(0)
            newState = newState
                .changeLocalState(newLocalState)
        }
        newState = newState.changeLocalState(
            newState.localState
                .changeDrawerState(false)
        )
        callback()
        changeState(newState)
    }

    private fun openSettings(appState: AppState, changeState: (AppState) -> Unit) {
        println("opening settings")
        val newState = appState.changeScreenVariant(ScreenVariant.SETTINGS)
        changeState(newState)
    }

    private fun reloadSettings(appState: AppState, changeState: (AppState) -> Unit,
                               themeVariant: ThemeVariant, fontScaleVariant: FontScaleVariant) {
        val newState = appState
            .changeThemeVariant(themeVariant)
            .changeFontScaleVariant(fontScaleVariant)
        changeState(newState)
    }

    private fun selectSong(appState: AppState, changeState: (AppState) -> Unit, songIndex: Int) {
        println("select song with index: $songIndex")
        var newState = appState
        val newLocalState = newState.localState.changeSongIndex(songIndex)
        newState = newState.changeLocalState(newLocalState)
        refreshCurrentSong(newState) { newState = it }
        newState = newState.changeScreenVariant(ScreenVariant.SONG_TEXT)
        changeState(newState)
    }

    private fun prevSong(appState: AppState, changeState: (AppState) -> Unit) {
        val currentCount = appState.localState.currentCount
        if (currentCount == 0) return
        val currentIndex = appState.localState.currentSongIndex
        val newIndex = if (currentIndex > 0) {
            currentIndex - 1
        } else {
            currentCount - 1
        }
        val newLocalState = appState.localState.changeSongIndex(newIndex)
        var newState = appState.changeLocalState(newLocalState)
        refreshCurrentSong(newState) { newState = it }
        changeState(newState)
    }

    private fun nextSong(appState: AppState, changeState: (AppState) -> Unit) {
        val currentCount = appState.localState.currentCount
        if (currentCount == 0) return
        val currentIndex = appState.localState.currentSongIndex
        val newIndex = (currentIndex + 1) % currentCount
        val newLocalState = appState.localState.changeSongIndex(newIndex)
        var newState = appState.changeLocalState(newLocalState)
        refreshCurrentSong(newState) { newState = it }
        changeState(newState)
    }

    private fun refreshCurrentSong(appState: AppState, changeState: (AppState) -> Unit) {
        val newSong = Injector.songRepo.getSongByArtistAndPosition(
            appState.localState.currentArtist,
            appState.localState.currentSongIndex
        )
        val newLocalState = appState.localState.changeSong(newSong)
        val newState = appState.changeLocalState(newLocalState)
        changeState(newState)
    }

    private fun updateSongIndexByScroll(appState: AppState, changeState: (AppState) -> Unit, songIndex: Int) {
        val newLocalState = appState.localState.changeSongIndex(songIndex)
        val newState = appState.changeLocalState(newLocalState)
        changeState(newState)
    }

    private fun toggleDrawer(appState: AppState, changeState: (AppState) -> Unit) {
        val newLocalState = appState.localState.toggleDrawer()
        val newState = appState.changeLocalState(newLocalState)
        changeState(newState)
    }

    private fun back(appState: AppState, changeState: (AppState) -> Unit) {
        var newState = appState
        val newScreenVariant = when (newState.currentScreenVariant) {
            ScreenVariant.SONG_TEXT -> ScreenVariant.SONG_LIST
            ScreenVariant.CLOUD_SEARCH -> {
                val newCloudState = newState.cloudState.changeCloudSongList(null)
                newState = newState.changeCloudState(newCloudState)
                ScreenVariant.SONG_LIST
            }
            ScreenVariant.CLOUD_SONG_TEXT -> ScreenVariant.CLOUD_SEARCH
            ScreenVariant.SETTINGS -> ScreenVariant.SONG_LIST
            else -> throw IllegalStateException("Impossible variant")
        }
        println("back: ${newState.currentScreenVariant} -> $newScreenVariant")
        newState = newState.changeScreenVariant(newScreenVariant)
        changeState(newState)
    }

    private fun toggleFavorite(appState: AppState, changeState: (AppState) -> Unit, emptyListCallback: () -> Unit) {
        var newState = appState
        val song = newState.localState.currentSong!!.copy()
        val becomeFavorite = !song.favorite
        song.favorite = becomeFavorite
        Injector.songRepo.updateSong(song)
        if (!becomeFavorite && appState.localState.currentArtist == ARTIST_FAVORITE) {
            val count = Injector.songRepo.getCountByArtist(ARTIST_FAVORITE)
            var newLocalState = newState.localState.changeCount(count)
            newState = newState.changeLocalState(newLocalState)
            if (count > 0) {
                if (newState.localState.currentSongIndex >= count) {
                    val newIndex = count - 1
                    newLocalState = newLocalState.changeSongIndex(newIndex)
                    newState = newState.changeLocalState(newLocalState)
                }
                refreshCurrentSong(newState) { newState = it }
            } else {
                back(appState, changeState)
                emptyListCallback()
            }
            val newSongList = Injector.songRepo.getSongsByArtist(ARTIST_FAVORITE)
            newLocalState = newState.localState.changeSongList(newSongList)
            newState = newState.changeLocalState(newLocalState)
        } else {
            refreshCurrentSong(newState) { newState = it }
        }
        changeState(newState)
        if (becomeFavorite) {
            showToast("Добавлено в избранное")
        } else {
            showToast("Удалено из избранного")
        }
    }

    private fun deleteCurrentToTrash(appState: AppState, changeState: (AppState) -> Unit, emptyListCallback: () -> Unit) {
        var newState = appState
        val song = newState.localState.currentSong!!.copy()
        println("deleting to trash: ${song.artist} - ${song.title}")
        song.deleted = true
        Injector.songRepo.updateSong(song)
        val count = Injector.songRepo.getCountByArtist(newState.localState.currentArtist)
        var newLocalState = newState.localState.changeCount(count)
        newState = newState
            .changeLocalState(newLocalState)
            .changeArtists(Injector.songRepo.getArtists())
        if (count > 0) {
            if (newState.localState.currentSongIndex >= count) {
                val newIndex = count - 1
                newLocalState = newLocalState.changeSongIndex(newIndex)
                newState = newState.changeLocalState(newLocalState)
            }
            refreshCurrentSong(newState) { newState = it }
        } else {
            back(appState, changeState)
            emptyListCallback()
        }
        val newSongList = Injector.songRepo.getSongsByArtist(newState.localState.currentArtist)
        newLocalState = newState.localState.changeSongList(newSongList)
        newState = newState.changeLocalState(newLocalState)
        changeState(newState)
        showToast("Удалено")
    }

    private fun saveSongText(appState: AppState, changeState: (AppState) -> Unit, newText: String) {
        val song = appState.localState.currentSong!!.copy()
        song.text = newText
        Injector.songRepo.updateSong(song)
        refreshCurrentSong(appState, changeState)
    }

    private fun uploadCurrentToCloud(appState: AppState) {
        println("upload to cloud")
        val song = appState.localState.currentSong!!
        val textWasChanged = song.textWasChanged
        if (!textWasChanged) {
            showToast("Нельзя залить в облако: данный вариант аккордов поставляется вместе с приложением либо был сохранен из облака")
        } else {
            CloudRepository.addCloudSongAsync(
                cloudSong = song.asCloudSong(),
                onSuccess = {
                    showToast("Успешно добавлено в облако")
                },
                onServerMessage = {
                    showToast(it)
                }, onError = {
                    it.printStackTrace()
                    showToast("Ошибка в приложении")
                }
            )
        }
    }

    private fun sendWarning(warning: Warning) {
        CloudRepository.addWarningAsync(
            warning = warning,
            onSuccess = {
                showToast("Уведомление отправлено")
            }, onServerMessage = {
                showToast(it)
            }, onError = {
                it.printStackTrace()
                showToast("Ошибка в приложении")
            }
        )
    }

    private fun searchSongs(appState: AppState, changeState: (AppState) -> Unit, searchFor: String, orderBy: OrderBy) {
        val newCloudState = appState.cloudState.changeSearchState(SearchState.LOADING)
        val newState = appState.changeCloudState(newCloudState)
        changeState(newState)
        CloudRepository.searchSongsAsync(
            searchFor = searchFor,
            orderBy = orderBy,
            onSuccess = { data ->
                var _newState = newState
                refreshCloudSongList(_newState, { _newState = it }, data)
                _newState = if (data.isEmpty()) {
                    val _newCloudState =
                        _newState.cloudState.changeSearchState(SearchState.EMPTY_LIST)
                    _newState.changeCloudState(_newCloudState)
                } else {
                    val _newCloudState =
                        _newState.cloudState.changeSearchState(SearchState.LOAD_SUCCESS)
                    _newState.changeCloudState(_newCloudState)
                }
                changeState(_newState)
            }, onServerMessage = {
                val _newCloudState = newState.cloudState.changeSearchState(SearchState.LOAD_ERROR)
                val _newState = newState.changeCloudState(_newCloudState)
                changeState(_newState)
            }, onError = { t ->
                t.printStackTrace()
                val _newCloudState = newState.cloudState.changeSearchState(SearchState.LOAD_ERROR)
                val _newState = newState.changeCloudState(_newCloudState)
                changeState(_newState)
            }
        )
    }

    private fun refreshCloudSongList(appState: AppState, changeState: (AppState) -> Unit, cloudSongList: List<CloudSong>) {
        println(cloudSongList.size)

        val newCloudState = appState.cloudState
            .resetLikes()
            .resetDislikes()
            .changeCloudSongList(cloudSongList)
            .changeCount(cloudSongList.size)
            .changeCloudSongIndex(0)
            .changeCloudSong(null)
        val newState = appState.changeCloudState(newCloudState)

        changeState(newState)
    }

    private fun selectCloudSong(appState: AppState, changeState: (AppState) -> Unit, index: Int) {
        println("select cloud song: $index")
        val newCloudState = appState.cloudState
            .changeCloudSongIndex(index)
            .changeCloudSong(appState.cloudState.currentCloudSongList!![index])
        val newState = appState.changeCloudState(newCloudState)
            .changeScreenVariant(ScreenVariant.CLOUD_SONG_TEXT)
        changeState(newState)
    }

    private fun prevCloudSong(appState: AppState, changeState: (AppState) -> Unit) {
        val currentIndex = appState.cloudState.currentCloudSongIndex
        if (currentIndex - 1 >= 0) {
            selectCloudSong(appState, changeState, currentIndex - 1)
        }
    }

    private fun nextCloudSong(appState: AppState, changeState: (AppState) -> Unit) {
        val currentIndex = appState.cloudState.currentCloudSongIndex
        val count = appState.cloudState.currentCloudSongCount
        if (currentIndex + 1 < count) {
            selectCloudSong(appState, changeState, currentIndex + 1)
        }
    }

    private fun selectOrderBy(appState: AppState, changeState: (AppState) -> Unit, orderBy: OrderBy) {
        val newCloudState = appState.cloudState
                                .changeCloudSongIndex(0)
                                .changeCloudSong(null)
                                .changeOrderBy(orderBy)
        val newState = appState.changeCloudState(newCloudState)
        changeState(newState)
    }

    private fun backupSearchFor(appState: AppState, changeState: (AppState) -> Unit, searchFor: String) {
        val newCloudState = appState.cloudState.changeSearchForBackup(searchFor)
        val newState = appState.changeCloudState(newCloudState)
        changeState(newState)
    }

    private fun performLike(appState: AppState, changeState: (AppState) -> Unit, cloudSong: CloudSong) {
        CloudRepository.voteAsync(
            cloudSong = cloudSong,
            voteValue = 1,
            onSuccess = {
                println(it)
                val newCloudState = appState.cloudState.addLike(cloudSong)
                val newState = appState.changeCloudState(newCloudState)
                changeState(newState)
                showToast("Ваш голос засчитан")
            }, onServerMessage = {
                showToast(it)
            }, onError = {
                it.printStackTrace()
                showToast("Ошибка в приложении")
            }
        )
    }

    private fun performDislike(appState: AppState, changeState: (AppState) -> Unit, cloudSong: CloudSong) {
        CloudRepository.voteAsync(
            cloudSong = cloudSong,
            voteValue = -1,
            onSuccess = {
                println(it)
                val newCloudState = appState.cloudState.addDislike(cloudSong)
                val newState = appState.changeCloudState(newCloudState)
                changeState(newState)
                showToast("Ваш голос засчитан")
            }, onServerMessage = {
                showToast(it)
            }, onError = {
                it.printStackTrace()
                showToast("Ошибка в приложении")
            }
        )
    }

    private fun downloadCurrent(appState: AppState, changeState: (AppState) -> Unit, cloudSong: CloudSong) {
        Injector.songRepo.addSongFromCloud(cloudSong.asSong())
        var newState = appState
        newState = newState.changeArtists(Injector.songRepo.getArtists())
        val count = Injector.songRepo.getCountByArtist(newState.localState.currentArtist)
        val newLocalState = newState.localState
            .changeCount(count)
            .changeSongList(Injector.songRepo.getSongsByArtist(newState.localState.currentArtist))
        newState = newState.changeLocalState(newLocalState)
        changeState(newState)
        showToast("Аккорды сохранены в локальной базе данных и добавлены в избранное")
    }

    private fun onUpdateDone(appState: AppState, changeState: (AppState) -> Unit) {
        performAction(
            appState = appState,
            action = SelectArtist(defaultArtist, {}),
            changeState = {
                val newState = it.changeScreenVariant(ScreenVariant.SONG_LIST)
                changeState(newState)
            }
        )
    }

    private fun openSongAtVkMusic(music: Music) {
        openUrl(music.vkMusicUrl)
    }

    private fun openSongAtYandexMusic(music: Music) {
        openUrl(music.yandexMusicUrl)
    }

    private fun openSongAtYoutubeMusic(music: Music) {
        openUrl(music.youtubeMusicUrl)
    }
}
