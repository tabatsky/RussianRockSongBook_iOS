package jatx.russianrocksongbook

interface Platform {
    val name: String
}

expect fun getPlatform(): Platform