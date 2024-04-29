package jatx.russianrocksongbook.common.state

enum class ThemeVariant {
    DARK, LIGHT;

    val index = ordinal

    companion object {
        fun getByIndex(index: Int) = entries[index]
    }
}

enum class FontScaleVariant {
    XS, S, M, L, XL;

    val index = ordinal - 2

    companion object {
        fun getByIndex(index: Int) = entries[index + 2]
    }
}