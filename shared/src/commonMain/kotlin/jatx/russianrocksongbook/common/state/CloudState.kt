package jatx.russianrocksongbook.common.state

import jatx.russianrocksongbook.common.networking.CloudSong
import jatx.russianrocksongbook.common.networking.OrderBy

data class CloudState(
    val currentSearchState: SearchState = SearchState.LOADING,
    val currentCloudSongList: List<CloudSong>? = null,
    val currentCloudSongCount: Int = 0,
    val currentCloudSongIndex: Int = 0,
    val currentCloudSong: CloudSong? = null,
    val currentCloudOrderBy: OrderBy = OrderBy.BY_ID_DESC,
    val searchForBackup: String = "",
    val allLikes: Map<CloudSong, Int> = hashMapOf(),
    val allDislikes: Map<CloudSong, Int> = hashMapOf()
) {
    companion object {
        fun newInstance() = CloudState()
    }

    fun changeSearchState(searchState: SearchState) = this.copy(currentSearchState = searchState)

    fun changeCloudSongList(cloudSongList: List<CloudSong>?) =
        this.copy(currentCloudSongList = cloudSongList)

    fun changeCount(count: Int) = this.copy(currentCloudSongCount = count)

    fun changeCloudSongIndex(index: Int) = this.copy(currentCloudSongIndex = index)

    fun changeCloudSong(cloudSong: CloudSong?) = this.copy(currentCloudSong = cloudSong)

    fun changeOrderBy(orderBy: OrderBy) = this.copy(currentCloudOrderBy = orderBy)

    fun changeSearchForBackup(backup: String) = this.copy(searchForBackup = backup)

    fun resetLikes() = this.copy(allLikes = hashMapOf())

    fun resetDislikes() = this.copy(allDislikes = hashMapOf())

    fun addLike(cloudSong: CloudSong): CloudState {
        val mutableLikes = allLikes as? HashMap<CloudSong, Int>
        return mutableLikes?.let {
            val oldCount = mutableLikes[cloudSong] ?: 0
            mutableLikes[cloudSong] = oldCount + 1
            this.copy(allLikes = mutableLikes)
        } ?: this
    }

    fun addDislike(cloudSong: CloudSong): CloudState {
        val mutableLikes = allDislikes as? HashMap<CloudSong, Int>
        return mutableLikes?.let {
            val oldCount = mutableLikes[cloudSong] ?: 0
            mutableLikes[cloudSong] = oldCount + 1
            this.copy(allDislikes = mutableLikes)
        } ?: this
    }
}

enum class SearchState {
    LOADING, LOAD_SUCCESS, LOAD_ERROR, EMPTY_LIST
}