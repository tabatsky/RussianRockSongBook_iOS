package jatx.russianrocksongbook.common.data

import jatx.russianrocksongbook.common.domain.Song

const val ARTIST_FAVORITE = "Избранное"
const val ARTIST_ADD_ARTIST = "Добавить исполнителя"
const val ARTIST_ADD_SONG = "Добавить песню"
const val ARTIST_CLOUD_SONGS = "Аккорды онлайн"
const val ARTIST_DONATION = "Пожертвования"

interface SongRepository {
    fun getArtists(): List<String>
    fun getCountByArtist(artist: String): Int
    fun getSongsByArtist(artist: String): List<Song>
    fun getSongsByVoiceSearch(voiceSearch: String): List<Song>
    fun getSongByArtistAndPosition(artist: String, position: Int): Song?
    fun getSongByArtistAndTitle(artist: String, title: String): Song?
    fun setFavorite(favorite: Boolean, artist: String, title: String)
    fun updateSong(song: Song)
    fun deleteSongToTrash(song: Song)
    //fun addSongFromCloud(cloudSong: CloudSong)
    fun isSongFavorite(artist: String, title: String): Boolean
    fun insertIgnoreSongs(songs: List<Song>)
    fun insertReplaceUserSongs(songs: List<Song>): List<Song>
    fun insertReplaceUserSong(song: Song): Song
    fun deleteWrongSong(artist: String, title: String)
    fun deleteWrongArtist(artist: String)
    fun patchWrongArtist(wrongArtist: String, actualArtist: String)
}