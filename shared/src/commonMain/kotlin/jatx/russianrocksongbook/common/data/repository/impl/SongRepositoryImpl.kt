package jatx.russianrocksongbook.common.data.repository.impl

import jatx.russianrocksongbook.common.data.converters.toSong
import jatx.russianrocksongbook.common.data.converters.toSongEntity
import jatx.russianrocksongbook.common.domain.models.Song
import jatx.russianrocksongbook.common.domain.repository.ARTIST_ADD_ARTIST
import jatx.russianrocksongbook.common.domain.repository.ARTIST_ADD_SONG
import jatx.russianrocksongbook.common.domain.repository.ARTIST_CLOUD_SONGS
import jatx.russianrocksongbook.common.domain.repository.ARTIST_DONATION
import jatx.russianrocksongbook.common.domain.repository.ARTIST_FAVORITE
import jatx.russianrocksongbook.common.domain.repository.SongRepository
import jatx.russianrocksongbook.db.AppDatabase

val predefinedList = listOf(
    ARTIST_FAVORITE,
    ARTIST_ADD_ARTIST,
    ARTIST_ADD_SONG,
    ARTIST_CLOUD_SONGS,
    ARTIST_DONATION
)

class SongRepositoryImpl(
    private val appDatabase: AppDatabase
): SongRepository {
    override fun getArtists(): List<String> =
        predefinedList.plus(
            appDatabase
                .songEntityQueries
                .getArtists()
                .executeAsList()
                .filter { !predefinedList.contains(it) }
        )

    override fun getCountByArtist(artist: String) =
        if (artist == ARTIST_FAVORITE)
            appDatabase
                .songEntityQueries
                .getCountFavorite()
                .executeAsOne()
                .toInt()
        else
            appDatabase
                .songEntityQueries
                .getCountByArtist(artist)
                .executeAsOne()
                .toInt()


    override fun getSongsByArtist(artist: String): List<Song> =
        if (artist == ARTIST_FAVORITE)
            appDatabase
                .songEntityQueries
                .getSongsFavorite()
                .executeAsList()
                .map { it.toSong() }
        else
            appDatabase
                .songEntityQueries
                .getSongsByArtist(artist)
                .executeAsList()
                .map { it.toSong() }


    override fun getSongsByVoiceSearch(voiceSearch: String): List<Song> {
        TODO("Not yet implemented")
    }

    override fun getSongByArtistAndPosition(artist: String, position: Int): Song? {
        val songEntity = if (artist == ARTIST_FAVORITE)
            appDatabase
                .songEntityQueries
                .getSongByPositionFavorite(position.toLong())
                .executeAsOneOrNull()
        else
            appDatabase
                .songEntityQueries
                .getSongByPositionAndArtist(artist, position.toLong())
                .executeAsOneOrNull()
        return songEntity?.toSong()
    }

    override fun getSongByArtistAndTitle(artist: String, title: String): Song? {
        TODO("Not yet implemented")
    }

    override fun setFavorite(favorite: Boolean, artist: String, title: String) {
        TODO("Not yet implemented")
    }

    override fun updateSong(song: Song) =
        song.toSongEntity().let {
            appDatabase
                .songEntityQueries
                .updateSong(
                    it.text,
                    it.favorite,
                    it.deleted,
                    it.id
                )
        }

    override fun deleteSongToTrash(song: Song) {
        TODO("Not yet implemented")
    }

    override fun isSongFavorite(artist: String, title: String): Boolean {
        TODO("Not yet implemented")
    }

    override fun insertIgnoreSongs(songs: List<Song>) {
        val songEntityQueries = appDatabase.songEntityQueries
        songEntityQueries.transaction {
            songs.map { it.toSongEntity() }.forEach {
                songEntityQueries
                    .insertIgnoreSong(
                        it.artist,
                        it.title,
                        it.text,
                        it.favorite,
                        it.deleted,
                        it.outOfTheBox,
                        it.origTextMD5
                    )
            }
        }
    }

    override fun insertReplaceUserSongs(songs: List<Song>): List<Song> {
        TODO("Not yet implemented")
    }

    override fun insertReplaceUserSong(song: Song): Song {
        TODO("Not yet implemented")
    }

    override fun deleteWrongSong(artist: String, title: String) {
        TODO("Not yet implemented")
    }

    override fun deleteWrongArtist(artist: String) {
        TODO("Not yet implemented")
    }

    override fun patchWrongArtist(wrongArtist: String, actualArtist: String) {
        TODO("Not yet implemented")
    }
}