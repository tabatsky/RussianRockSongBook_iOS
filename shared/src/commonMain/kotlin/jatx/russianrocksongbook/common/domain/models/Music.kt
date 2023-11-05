package jatx.russianrocksongbook.common.domain.models

import io.ktor.http.encodeURLPath

interface Music {
    val searchFor: String

    val yandexMusicUrl: String
        get() {
            val searchForEncoded = searchFor.encodeURLPath()
            return "https://music.yandex.ru/search?text=$searchForEncoded"
        }

    val youtubeMusicUrl: String
        get() {
            val searchForEncoded = searchFor.encodeURLPath()
            return "https://music.youtube.com/search?q=$searchForEncoded"
        }
}