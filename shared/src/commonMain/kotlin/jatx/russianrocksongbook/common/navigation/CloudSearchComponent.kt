package jatx.russianrocksongbook.common.navigation

import com.arkivanov.decompose.ComponentContext

interface CloudSearchComponent {
    fun onBackPressed()
    fun onCloudSongClicked(position: Int)
}

class DefaultCloudSearchComponent(
    componentContext: ComponentContext,
    private val onFinished: () -> Unit,
    private val onCloudSongSelected: (position: Int) -> Unit,
) : CloudSearchComponent {

    override fun onBackPressed() {
        onFinished()
    }
    override fun onCloudSongClicked(position: Int) {
        onCloudSongSelected(position)
    }
}