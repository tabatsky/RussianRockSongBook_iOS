package jatx.russianrocksongbook.common.dbinit

import jatx.russianrocksongbook.common.domain.repository.SongRepository
import jatx.russianrocksongbook.common.domain.models.Song
import jatx.russianrocksongbook.common.res.Resource
import jatx.russianrocksongbook.MR
import kotlinx.serialization.json.Json

fun testFillDbFromJSON(artists: List<String>, songRepo: SongRepository, onProgressChanged: (Int, Int) -> Unit) {
    val jsonLoader = JsonLoader(artists)
    while (jsonLoader.hasNext()) {
        onProgressChanged(jsonLoader.current + 1, jsonLoader.total)
        val songs = jsonLoader.loadNext()
        songRepo.insertIgnoreSongs(songs)
    }
}

fun fillDbFromJSON(songRepo: SongRepository, onProgressChanged: (Int, Int) -> Unit) {
    val jsonLoader = JsonLoader()
    while (jsonLoader.hasNext()) {
        onProgressChanged(jsonLoader.current + 1, jsonLoader.total)
        val songs = jsonLoader.loadNext()
        songRepo.insertIgnoreSongs(songs)
    }
}

class JsonLoader(
    val artists: List<String> = artistMap.keys.toList()
) {
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
    "7Б" to MR.files.b7_json,
    "Animal ДжаZ" to MR.files.animal_dzhaz_json,
    "Brainstorm" to MR.files.brainstorm_json,
    "Flёur" to MR.files.flyour_json,
    "Louna" to MR.files.louna_json,
    "Lumen" to MR.files.lumen_json,
    "TequilaJazzz" to MR.files.tequilajazzz_json,
    "Uma2rman" to MR.files.umaturnan_json,
    "Znaki" to MR.files.znaki_json,
    "Агата Кристи" to MR.files.agata_json,
    "Адаптация" to MR.files.adaptacia_json,
    "Аквариум" to MR.files.akvarium_json,
    "Алиса" to MR.files.alisa_json,
    "АнимациЯ" to MR.files.animatsya_json,
    "Ария" to MR.files.aria_json,
    "АукцЫон" to MR.files.auktsyon_json,
    "Аффинаж" to MR.files.afinaj_json,
    "Александр Башлачёв" to MR.files.bashlachev_json,
    "Белая Гвардия" to MR.files.b_gvardia_json,
    "Би-2" to MR.files.bi2_json,
    "Браво" to MR.files.bravo_json,
    "Бригада С" to MR.files.brigada_c_json,
    "Бригадный Подряд" to MR.files.brigadnyi_json,
    "Ва-Банкъ" to MR.files.vabank_json,
    "Високосный год" to MR.files.visokosniy_json,
    "Воскресенье" to MR.files.voskresenie_json,
    "Глеб Самойлоff & The Matrixx" to MR.files.samoiloff_json,
    "Год Змеи" to MR.files.god_zmei_json,
    "Гражданская Оборона" to MR.files.grob_json,
    "ДДТ" to MR.files.ddt_json,
    "Дельфин" to MR.files.dolphin_json,
    "Дом Кукол" to MR.files.dom_kukol_json,
    "Звуки Му" to MR.files.zvukimu_json,
    "Земляне" to MR.files.zemlane_json,
    "Земфира" to MR.files.zemfira_json,
    "Зоопарк" to MR.files.zoopark_json,
    "Игорь Тальков" to MR.files.talkov_json,
    "Калинов Мост" to MR.files.kalinovmost_json,
    "Кафе" to MR.files.kafe_json,
    "Кино" to MR.files.kino_json,
    "КняZz" to MR.files.knazz_json,
    "Коридор" to MR.files.koridor_json,
    "Король и Шут" to MR.files.kish_json,
    "Крематорий" to MR.files.krematoriy_json,
    "Кукрыниксы" to MR.files.kukryniksy_json,
    "Ленинград" to MR.files.leningrad_json,
    "Линда" to MR.files.linda_json,
    "Любэ" to MR.files.lyube_json,
    "Ляпис Трубецкой" to MR.files.trubetskoi_json,
    "Магелланово Облако" to MR.files.magelanovo_oblako_json,
    "Марко Поло" to MR.files.marko_polo_json,
    "Маша и Медведи" to MR.files.mashamedv_json,
    "Машина Времени" to MR.files.machina_json,
    "Мельница" to MR.files.melnitsa_json,
    "Мультfильмы" to MR.files.multfilmi_json,
    "Мумий Тролль" to MR.files.mumiytrol_json,
    "Мураками" to MR.files.murakami_json,
    "Наив" to MR.files.naiv_json,
    "Настя" to MR.files.nastia_json,
    "Наутилус Помпилиус" to MR.files.nautilus_json,
    "Неприкасаемые" to MR.files.neprikasaemye_json,
    "Немного Нервно" to MR.files.nervno_json,
    "Ногу Свело" to MR.files.nogusvelo_json,
    "Ноль" to MR.files.nol_json,
    "Ночные Снайперы" to MR.files.snaipery_json,
    "Операция Пластилин" to MR.files.operatsya_plastilin_json,
    "Павел Кашин" to MR.files.kashin_json,
    "Павел Пиковский" to MR.files.pikovskij_pavel_xyugo_json,
    "Пикник" to MR.files.piknik_json,
    "Пилот" to MR.files.pilot_json,
    "План Ломоносова" to MR.files.plan_lomonosova_json,
    "Порнофильмы" to MR.files.pornofilmy_json,
    "Северный Флот" to MR.files.severnyi_flot_json,
    "Секрет" to MR.files.sekret_json,
    "Сектор Газа" to MR.files.sektor_json,
    "СерьГа" to MR.files.serga_json,
    "Слот" to MR.files.slot_json,
    "Смысловые Галлюцинации" to MR.files.smislovie_json,
    "Сплин" to MR.files.splin_json,
    "Танцы Минус" to MR.files.minus_json,
    "Тараканы" to MR.files.tarakany_json,
    "Телевизор" to MR.files.televizor_json,
    "Торба-на-Круче" to MR.files.torba_n_json,
    "Ундервуд" to MR.files.undervud_json,
    "Чайф" to MR.files.chaif_json,
    "Чёрный Кофе" to MR.files.cherniykofe_json,
    "Чёрный Лукич" to MR.files.lukich_json,
    "Чёрный Обелиск" to MR.files.chobelisk_json,
    "Чичерина" to MR.files.chicherina_json,
    "Чиж и Ко" to MR.files.chizh_json,
    "Эпидемия" to MR.files.epidemia_json,
    "Юта" to MR.files.uta_json,
    "Янка Дягилева" to MR.files.yanka_json,
    "Ясвена" to MR.files.yasvena_json
)
