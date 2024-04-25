package jatx.russianrocksongbook.common.navigation

import com.arkivanov.decompose.ComponentContext

interface SongListComponent {
    fun onSongClicked(position: Int)
    fun onSettingsClicked()
}

class DefaultSongListComponent(
    componentContext: ComponentContext,
    private val onSongSelected: (position: Int) -> Unit,
    private val onSettingsSelected: () -> Unit
) : SongListComponent {

    override fun onSongClicked(position: Int) {
        onSongSelected(position)
    }

    override fun onSettingsClicked() {
        onSettingsSelected()
    }
}