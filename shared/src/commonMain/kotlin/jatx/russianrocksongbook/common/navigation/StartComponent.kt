package jatx.russianrocksongbook.common.navigation

import com.arkivanov.decompose.ComponentContext

interface StartComponent {
    fun onUpdateDone()
}

class DefaultStartComponent(
    componentContext: ComponentContext,
    private val onFinished: () -> Unit
) : StartComponent {
    override fun onUpdateDone() {
        onFinished()
    }
}