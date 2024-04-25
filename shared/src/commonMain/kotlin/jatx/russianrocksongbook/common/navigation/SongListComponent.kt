package jatx.russianrocksongbook.common.navigation

import com.arkivanov.decompose.ComponentContext

interface SongListComponent {
    fun onSongClicked(position: Int)
}

class DefaultSongListComponent(
    componentContext: ComponentContext,
    private val onSongSelected: (position: Int) -> Unit
) : SongListComponent {

    override fun onSongClicked(position: Int) {
        onSongSelected(position)
    }
}