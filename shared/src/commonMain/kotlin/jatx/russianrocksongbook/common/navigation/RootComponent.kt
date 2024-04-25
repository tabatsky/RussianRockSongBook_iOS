package jatx.russianrocksongbook.common.navigation

import com.arkivanov.decompose.ComponentContext
import com.arkivanov.decompose.router.stack.ChildStack
import com.arkivanov.decompose.router.stack.StackNavigation
import com.arkivanov.decompose.router.stack.childStack
import com.arkivanov.decompose.router.stack.pop
import com.arkivanov.decompose.router.stack.popTo
import com.arkivanov.decompose.router.stack.push
import com.arkivanov.decompose.router.stack.replaceCurrent
import com.arkivanov.decompose.value.Value
import kotlinx.serialization.Serializable

interface RootComponent {
    val stack: Value<ChildStack<*, Child>>

    // It's possible to pop multiple screens at a time on iOS
    fun onBackClicked(toIndex: Int)

    fun onCloudSearchClicked()

    // Defines all possible child components
    sealed class Child {
        class StartChild(val component: StartComponent) : Child()
        class SongListChild(val component: SongListComponent) : Child()
        class SongTextChild(val component: SongTextComponent) : Child()
        class CloudSearchChild(val component: CloudSearchComponent) : Child()
        class CloudSongTextChild(val component: CloudSongTextComponent) : Child()
        class SettingsChild(val component: SettingsComponent) : Child()
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
            initialConfiguration = Config.Start, // The initial child component is List
            handleBackButton = true, // Automatically pop from the stack on back button presses
            childFactory = ::child,
        )

    override fun onCloudSearchClicked() {
        navigation.push(Config.CloudSearch)
    }

    private fun child(config: Config, componentContext: ComponentContext): RootComponent.Child =
        when (config) {
            is Config.Start -> RootComponent.Child.StartChild(startComponent(componentContext))
            is Config.SongList -> RootComponent.Child.SongListChild(songListComponent(componentContext))
            is Config.SongText -> RootComponent.Child.SongTextChild(songTextComponent(componentContext, config))
            is Config.CloudSearch -> RootComponent.Child.CloudSearchChild(cloudSearchComponent(componentContext))
            is Config.CloudSongText -> RootComponent.Child.CloudSongTextChild(cloudSongTextComponent(componentContext, config))
            is Config.Settings -> RootComponent.Child.SettingsChild(settingsComponent(componentContext))
        }

    private fun startComponent(componentContext: ComponentContext): StartComponent =
        DefaultStartComponent(
            componentContext = componentContext,
            onFinished = {
                navigation.replaceCurrent(Config.SongList)
            }
        )

    private fun songListComponent(componentContext: ComponentContext): SongListComponent =
        DefaultSongListComponent(
            componentContext = componentContext,
            onSongSelected = { position: Int -> // Supply dependencies and callbacks
                navigation.push(Config.SongText(position = position)) // Push the details component
            },
            onSettingsSelected = {
                navigation.push(Config.Settings)
            }
        )

    private fun songTextComponent(componentContext: ComponentContext, config: Config.SongText): SongTextComponent =
        DefaultSongTextComponent(
            componentContext = componentContext,
            position = config.position, // Supply arguments from the configuration
            onFinished = navigation::pop, // Pop the details component
        )

    private fun cloudSearchComponent(componentContext: ComponentContext): CloudSearchComponent =
        DefaultCloudSearchComponent(
            componentContext = componentContext,
            onFinished = navigation::pop,
            onCloudSongSelected = { position: Int ->
                navigation.push(Config.CloudSongText(position = position))
            }
        )

    private fun cloudSongTextComponent(componentContext: ComponentContext, config: Config.CloudSongText): CloudSongTextComponent =
        DefaultCloudSongTextComponent(
            componentContext = componentContext,
            position = config.position, // Supply arguments from the configuration
            onFinished = navigation::pop, // Pop the details component
        )

    private fun settingsComponent(componentContext: ComponentContext): SettingsComponent =
        DefaultSettingsComponent(
            componentContext = componentContext,
            onFinished = navigation::pop,
        )

    override fun onBackClicked(toIndex: Int) {
        navigation.popTo(index = toIndex)
    }

    @Serializable // kotlinx-serialization plugin must be applied
    private sealed interface Config {
        @Serializable
        data object Start : Config
        @Serializable
        data object SongList : Config

        @Serializable
        data class SongText(val position: Int) : Config

        @Serializable
        data object CloudSearch : Config

        @Serializable
        data class CloudSongText(val position: Int) : Config

        @Serializable
        data object Settings : Config
    }
}
