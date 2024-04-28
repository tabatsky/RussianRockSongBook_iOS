package jatx.russianrocksongbook.common.state

import jatx.russianrocksongbook.common.di.Injector
import jatx.russianrocksongbook.common.domain.models.Song

const val defaultArtist = "Кино"

data class LocalState(
    var isDrawerOpen: Boolean = false,
    var currentArtist: String = defaultArtist,
    var currentSongList: List<Song> = Injector.songRepo.getSongsByArtist(defaultArtist),
    var currentCount: Int = Injector.songRepo.getCountByArtist(defaultArtist),
    var currentSongIndex: Int = 0,
    var currentSong: Song? = null
) {
    companion object {
        fun newInstance() = LocalState()
    }

    fun toggleDrawer() = this.copy(isDrawerOpen = !isDrawerOpen)

    fun changeDrawerState(isOpen: Boolean) = this.copy(isDrawerOpen = isOpen)

    fun changeArtist(artist: String) = this.copy(currentArtist = artist)

    fun changeSongIndex(index: Int) = this.copy(currentSongIndex = index)

    fun changeCount(count: Int) = this.copy(currentCount = count)

    fun changeSongList(songList: List<Song>) = this.copy(currentSongList = songList)

    fun changeSong(song: Song?) = this.copy(currentSong = song)
}