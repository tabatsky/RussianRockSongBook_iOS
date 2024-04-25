package jatx.russianrocksongbook.common.navigation

import com.arkivanov.decompose.ComponentContext

interface CloudSongTextComponent {
    fun onBackPressed()
}

class DefaultCloudSongTextComponent(
    componentContext: ComponentContext,
    position: Int,
    private val onFinished: () -> Unit
) : CloudSongTextComponent {
    override fun onBackPressed() {
        onFinished()
    }
}