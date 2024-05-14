package jatx.russianrocksongbook.common.state

import jatx.russianrocksongbook.common.domain.models.Music
import jatx.russianrocksongbook.common.domain.models.Warning
import jatx.russianrocksongbook.common.networking.CloudSong
import jatx.russianrocksongbook.common.networking.OrderBy

interface AppUIAction

interface KotlinUIAction: AppUIAction

data class SelectArtist(
    val artist: String,
    val callback: () -> Unit
): KotlinUIAction

object OpenSettings: KotlinUIAction

data class ReloadSettings(
    val themeVariant: ThemeVariant,
    val fontScaleVariant: FontScaleVariant
): KotlinUIAction

data class SongClick(
    val songIndex: Int
): KotlinUIAction

data class LocalScroll(
    val songIndex: Int
): KotlinUIAction

object DrawerClick: KotlinUIAction

object BackClick: KotlinUIAction

object LocalPrevClick: KotlinUIAction

object LocalNextClick: KotlinUIAction

data class FavoriteToggle(
    val emptyListCallback: () -> Unit
): KotlinUIAction

data class ConfirmDeleteToTrash(
    val emptyListCallback: () -> Unit
): KotlinUIAction

data class SaveSongText(
    val newText: String
): KotlinUIAction

object UploadCurrentToCloud: KotlinUIAction

data class SendWarning(
    val warning: Warning
): KotlinUIAction

data class CloudSearch(
    val searchFor: String,
    val orderBy: OrderBy
): KotlinUIAction

data class CloudSongClick(
    val index: Int
): KotlinUIAction

object CloudPrevClick: KotlinUIAction
object CloudNextClick: KotlinUIAction

data class SelectOrderBy(
    val orderBy: OrderBy
): KotlinUIAction

data class BackupSearchFor(
    val searchFor: String
): KotlinUIAction

data class LikeClick(
    val cloudSong: CloudSong
): KotlinUIAction

data class DislikeClick(
    val cloudSong: CloudSong
): KotlinUIAction

data class DownloadClick(
    val cloudSong: CloudSong
): KotlinUIAction

object UpdateDone: KotlinUIAction

data class OpenSongAtVkMusic(
    val music: Music
): KotlinUIAction

data class OpenSongAtYandexMusic(
    val music: Music
): KotlinUIAction

data class OpenSongAtYoutubeMusic(
    val music: Music
): KotlinUIAction

data class ShowToast(
    val text: String
): KotlinUIAction