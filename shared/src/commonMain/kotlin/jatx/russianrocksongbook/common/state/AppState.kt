package jatx.russianrocksongbook.common.state

import jatx.russianrocksongbook.common.di.Injector

data class AppState(
    val themeVariant: ThemeVariant,
    val fontScaleVariant: FontScaleVariant,
    val currentScreenVariant: ScreenVariant = ScreenVariant.START,
    val artists: List<String> = Injector.songRepo.getArtists(),
    val localState: LocalState = LocalState(),
    val cloudState: CloudState = CloudState()
) {
    companion object {
        fun newInstance(themeVariant: ThemeVariant, fontScaleVariant: FontScaleVariant) =
            AppState(themeVariant = themeVariant, fontScaleVariant = fontScaleVariant)
    }

    fun changeThemeVariant(themeVariant: ThemeVariant) = this.copy(themeVariant = themeVariant)

    fun changeFontScaleVariant(fontScaleVariant: FontScaleVariant) =
        this.copy(fontScaleVariant = fontScaleVariant)

    fun changeScreenVariant(screenVariant: ScreenVariant) =
        this.copy(currentScreenVariant = screenVariant)

    fun changeArtists(artists: List<String>) = this.copy(artists = artists)

    fun changeLocalState(localState: LocalState) = this.copy(localState = localState)

    fun changeCloudState(cloudState: CloudState) = this.copy(cloudState = cloudState)
}

enum class ThemeVariant {
    DARK, LIGHT;

    val index = ordinal

    companion object {
        fun getByIndex(index: Int) = entries[index]
    }
}

enum class FontScaleVariant {
    XS, S, M, L, XL;

    val index = ordinal - 2

    companion object {
        fun getByIndex(index: Int) = entries[index + 2]
    }
}

enum class ScreenVariant {
    START, SONG_LIST, SONG_TEXT, CLOUD_SEARCH, CLOUD_SONG_TEXT, SETTINGS
}