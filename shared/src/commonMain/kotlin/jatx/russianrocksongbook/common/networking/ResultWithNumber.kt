package jatx.russianrocksongbook.common.networking

import kotlinx.serialization.Serializable

@Serializable
data class ResultWithNumber(
    val status: String,
    val message: String? = null,
    val data: Float? = null
)