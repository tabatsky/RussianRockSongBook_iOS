package jatx.russianrocksongbook.common.state

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