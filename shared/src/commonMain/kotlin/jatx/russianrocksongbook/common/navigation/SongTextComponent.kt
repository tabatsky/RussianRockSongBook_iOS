package jatx.russianrocksongbook.common.navigation

import com.arkivanov.decompose.ComponentContext

interface SongTextComponent {
    fun onBackPressed()
}

class DefaultSongTextComponent(
    componentContext: ComponentContext,
    position: Int,
    private val onFinished: () -> Unit
) : SongTextComponent {
    override fun onBackPressed() {
        onFinished()
    }
}