package jatx.russianrocksongbook.common.dbinit

import jatx.russianrocksongbook.common.domain.repository.SongRepository
import jatx.russianrocksongbook.common.domain.models.Song
import jatx.russianrocksongbook.common.res.Resource
import jatx.russianrocksongbook.MR
import kotlinx.serialization.json.Json

fun fillDbFromJSON(songRepo: SongRepository, onProgressChanged: (Int, Int) -> Unit) {
    val jsonLoader = JsonLoader()
    while (jsonLoader.hasNext()) {
        onProgressChanged(jsonLoader.current + 1, jsonLoader.total)
        val songs = jsonLoader.loadNext()
        songRepo.insertIgnoreSongs(songs)
    }
}

class JsonLoader {
    var current = 0
    val total: Int
        get() = artists.size

    fun hasNext() = current < artists.size

    fun loadNext(): List<Song> {
        try {
            val artist = artists[current]
            val dict = artistMap[artist]

            current++

            dict?.apply {
                val jsonStr = Resource.openRaw(this)

                val songbook = Json.decodeFromString<SongBookGson>(jsonStr)

                return songbook.songbook.map { it asSongWithArtist artist }
            }
        } catch (e: Throwable) {
            e.printStackTrace()
        }

        return listOf()
    }
}

val artistMap = mapOf(
    "7Б" to MR.files.b7,
    "Animal ДжаZ" to MR.files.animal_dzhaz,
    "Brainstorm" to MR.files.brainstorm,
    "Flёur" to MR.files.flyour,
    "Louna" to MR.files.louna,
    "Lumen" to MR.files.lumen,
    "TequilaJazzz" to MR.files.tequilajazzz,
    "Uma2rman" to MR.files.umaturnan,
    "Znaki" to MR.files.znaki,
    "Агата Кристи" to MR.files.agata,
    "Адаптация" to MR.files.adaptacia,
    "Аквариум" to MR.files.akvarium,
    "Алиса" to MR.files.alisa,
    "АнимациЯ" to MR.files.animatsya,
    "Ария" to MR.files.aria,
    "АукцЫон" to MR.files.auktsyon,
    "Аффинаж" to MR.files.afinaj,
    "Александр Башлачёв" to MR.files.bashlachev,
    "Белая Гвардия" to MR.files.b_gvardia,
    "Би-2" to MR.files.bi2,
    "Браво" to MR.files.bravo,
    "Бригада С" to MR.files.brigada_c,
    "Бригадный Подряд" to MR.files.brigadnyi,
    "Ва-Банкъ" to MR.files.vabank,
    "Високосный год" to MR.files.visokosniy,
    "Воскресенье" to MR.files.voskresenie,
    "Глеб Самойлоff & The Matrixx" to MR.files.samoiloff,
    "Год Змеи" to MR.files.god_zmei,
    "Гражданская Оборона" to MR.files.grob,
    "ДДТ" to MR.files.ddt,
    "Дельфин" to MR.files.dolphin,
    "Дом Кукол" to MR.files.dom_kukol,
    "Звуки Му" to MR.files.zvukimu,
    "Земляне" to MR.files.zemlane,
    "Земфира" to MR.files.zemfira,
    "Зоопарк" to MR.files.zoopark,
    "Игорь Тальков" to MR.files.talkov,
    "Калинов Мост" to MR.files.kalinovmost,
    "Кафе" to MR.files.kafe,
    "Кино" to MR.files.kino,
    "КняZz" to MR.files.knazz,
    "Коридор" to MR.files.koridor,
    "Король и Шут" to MR.files.kish,
    "Крематорий" to MR.files.krematoriy,
    "Кукрыниксы" to MR.files.kukryniksy,
    "Ленинград" to MR.files.leningrad,
    "Линда" to MR.files.linda,
    "Любэ" to MR.files.lyube,
    "Ляпис Трубецкой" to MR.files.trubetskoi,
    "Магелланово Облако" to MR.files.magelanovo_oblako,
    "Марко Поло" to MR.files.marko_polo,
    "Маша и Медведи" to MR.files.mashamedv,
    "Машина Времени" to MR.files.machina,
    "Мельница" to MR.files.melnitsa,
    "Мультfильмы" to MR.files.multfilmi,
    "Мумий Тролль" to MR.files.mumiytrol,
    "Мураками" to MR.files.murakami,
    "Наив" to MR.files.naiv,
    "Настя" to MR.files.nastia,
    "Наутилус Помпилиус" to MR.files.nautilus,
    "Неприкасаемые" to MR.files.neprikasaemye,
    "Немного Нервно" to MR.files.nervno,
    "Ногу Свело" to MR.files.nogusvelo,
    "Ноль" to MR.files.nol,
    "Ночные Снайперы" to MR.files.snaipery,
    "Операция Пластилин" to MR.files.operatsya_plastilin,
    "Павел Кашин" to MR.files.kashin,
    "Павел Пиковский" to MR.files.pikovskij_pavel_xyugo,
    "Пикник" to MR.files.piknik,
    "Пилот" to MR.files.pilot,
    "План Ломоносова" to MR.files.plan_lomonosova,
    "Порнофильмы" to MR.files.pornofilmy,
    "Северный Флот" to MR.files.severnyi_flot,
    "Секрет" to MR.files.sekret,
    "Сектор Газа" to MR.files.sektor,
    "СерьГа" to MR.files.serga,
    "Слот" to MR.files.slot,
    "Смысловые Галлюцинации" to MR.files.smislovie,
    "Сплин" to MR.files.splin,
    "Танцы Минус" to MR.files.minus,
    "Тараканы" to MR.files.tarakany,
    "Телевизор" to MR.files.televizor,
    "Торба-на-Круче" to MR.files.torba_n,
    "Ундервуд" to MR.files.undervud,
    "Чайф" to MR.files.chaif,
    "Чёрный Кофе" to MR.files.cherniykofe,
    "Чёрный Лукич" to MR.files.lukich,
    "Чёрный Обелиск" to MR.files.chobelisk,
    "Чичерина" to MR.files.chicherina,
    "Чиж и Ко" to MR.files.chizh,
    "Эпидемия" to MR.files.epidemia,
    "Юта" to MR.files.uta,
    "Янка Дягилева" to MR.files.yanka,
    "Ясвена" to MR.files.yasvena
)

val artists = artistMap.keys.toTypedArray()
