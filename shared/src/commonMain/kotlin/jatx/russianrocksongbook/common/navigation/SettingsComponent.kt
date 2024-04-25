package jatx.russianrocksongbook.common.navigation

import com.arkivanov.decompose.ComponentContext

interface SettingsComponent {
    fun onBackPressed()
}

class DefaultSettingsComponent(
    componentContext: ComponentContext,
    private val onFinished: () -> Unit
) : SettingsComponent {
    override fun onBackPressed() {
        onFinished()
    }
}