package jatx.russianrocksongbook.common.state

import jatx.russianrocksongbook.common.data.repository.impl.predefinedList
import jatx.russianrocksongbook.common.di.Injector
import jatx.russianrocksongbook.common.domain.repository.ARTIST_CLOUD_SONGS
import jatx.russianrocksongbook.common.domain.repository.ARTIST_FAVORITE
import jatx.russianrocksongbook.common.networking.OrderBy

class KotlinStateMachine {
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

