package jatx.russianrocksongbook.common.domain.models

import kotlinx.serialization.Serializable

const val TYPE_CLOUD = "cloud"
const val TYPE_OUT_OF_THE_BOX = "outOfTheBox"

@Serializable
data class Warning(
    val warningType: String,
    val artist: String,
    val title: String,
    val variant: Int,
    val comment: String
)