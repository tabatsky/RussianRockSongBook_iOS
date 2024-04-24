package jatx.russianrocksongbook.common.navigation

import com.arkivanov.decompose.ComponentContext
import com.arkivanov.decompose.router.stack.ChildStack
import com.arkivanov.decompose.router.stack.StackNavigation
import com.arkivanov.decompose.router.stack.childStack
import com.arkivanov.decompose.router.stack.pop
import com.arkivanov.decompose.router.stack.popTo
import com.arkivanov.decompose.router.stack.push
import com.arkivanov.decompose.value.Value
import kotlinx.serialization.Serializable

interface RootComponent {
    val stack: Value<ChildStack<*, Child>>

    // It's possible to pop multiple screens at a time on iOS
    fun onBackClicked(toIndex: Int)

    // Defines all possible child components
    sealed class Child {
        class SongListChild(val component: SongListComponent) : Child()
        class SongTextChild(val component: SongTextComponent) : Child()
    }
}

class DefaultRootComponent(
    componentContext: ComponentContext,
) : RootComponent, ComponentContext by componentContext {
    private val navigation = StackNavigation<Config>()

    override val stack: Value<ChildStack<*, RootComponent.Child>> =
        childStack(
            source = navigation,
            serializer = Config.serializer(),
            initialConfiguration = Config.SongList, // The initial child component is List
            handleBackButton = true, // Automatically pop from the stack on back button presses
            childFactory = ::child,
        )

    private fun child(config: Config, componentContext: ComponentContext): RootComponent.Child =
        when (config) {
            is Config.SongList -> RootComponent.Child.SongListChild(songListComponent(componentContext))
            is Config.SongText -> RootComponent.Child.SongTextChild(songTextComponent(componentContext, config))
        }

    private fun songListComponent(componentContext: ComponentContext): SongListComponent =
        DefaultSongListComponent(
            componentContext = componentContext,
            onSongSelected = { position: Int -> // Supply dependencies and callbacks
                navigation.push(Config.SongText(position = position)) // Push the details component
            },
        )

    private fun songTextComponent(componentContext: ComponentContext, config: Config.SongText): SongTextComponent =
        DefaultSongTextComponent(
            componentContext = componentContext,
            position = config.position, // Supply arguments from the configuration
            onFinished = navigation::pop, // Pop the details component
        )

    override fun onBackClicked(toIndex: Int) {
        navigation.popTo(index = toIndex)
    }

    @Serializable // kotlinx-serialization plugin must be applied
    private sealed interface Config {
        @Serializable
        data object SongList : Config

        @Serializable
        data class SongText(val position: Int) : Config
    }
}

interface SongListComponent {
    fun onSongClicked(position: Int)
}

class DefaultSongListComponent(
    componentContext: ComponentContext,
    private val onSongSelected: (position: Int) -> Unit,
) : SongListComponent {

    override fun onSongClicked(position: Int) {
        onSongSelected(position)
    }
}

interface SongTextComponent {
    fun finish()
}

class DefaultSongTextComponent(
    componentContext: ComponentContext,
    position: Int,
    private val onFinished: () -> Unit
) : SongTextComponent {
    override fun finish() {
        onFinished()
    }
}