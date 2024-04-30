package jatx.russianrocksongbook.common.state

interface AppUIAction

interface KotlinUIAction: AppUIAction

data class SelectArtist(
    val artist: String,
    val callback: () -> Unit
): KotlinUIAction