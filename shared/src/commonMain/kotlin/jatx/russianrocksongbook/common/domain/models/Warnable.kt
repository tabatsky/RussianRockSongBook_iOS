package jatx.russianrocksongbook.common.domain.models

interface Warnable {
    fun warningWithComment(comment: String): Warning
}