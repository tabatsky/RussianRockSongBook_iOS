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
            is SongClick -> {
                selectSong(appState, changeState, action.songIndex)
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

private fun selectSong(appState: AppState, changeState: (AppState) -> Unit, songIndex: Int) {
    println("select song with index: $songIndex")
    var newState = appState
    val newLocalState = newState.localState.changeSongIndex(songIndex)
    newState = newState.changeLocalState(newLocalState)
    refreshCurrentSong(newState) { newState = it }
    newState = newState.changeScreenVariant(ScreenVariant.SONG_TEXT)
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
