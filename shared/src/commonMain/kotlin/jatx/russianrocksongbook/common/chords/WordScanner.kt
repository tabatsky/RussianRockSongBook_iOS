package jatx.russianrocksongbook.common.chords


class WordScanner(private val text: String) {
    private var currentIndex: Int = 0

    private val specialSymbols = listOf('#')

    private fun isLetter(ch: Char): Boolean {
        return (ch in 'A'..'Z') || (ch in 'a'..'z') || (ch in '0'..'9') || (ch in specialSymbols)
    }

    private fun scanNextWord(): Word? {
        return if (!isLetter(text[currentIndex])) {
            currentIndex++
            null
        } else {
            val sb = StringBuilder()
            val start = currentIndex
            while (currentIndex < text.length && isLetter(text[currentIndex])) {
                sb.append(text[currentIndex])
                currentIndex++
            }
            val end = currentIndex
            Word(sb.toString(), start, end)
        }
    }

    fun getWordList(): List<Word> {
        val list = ArrayList<Word>()

        while (currentIndex < text.length) {
            val word = scanNextWord()
            if (word != null) {
                list.add(word)
            }
        }

        return list
    }
}

data class Word(
    val text: String,
    val startIndex: Int,
    val endIndex: Int
)
