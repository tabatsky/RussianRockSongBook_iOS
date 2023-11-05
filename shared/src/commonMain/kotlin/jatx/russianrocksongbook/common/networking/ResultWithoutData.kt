package jatx.russianrocksongbook.common.networking

import kotlinx.serialization.Serializable

@Serializable
data class ResultWithoutData(
    val status: String,
    val message: String? = null
)