import { NetEasePlaylistId, playlistIds } from '../common/constants/MusicAPI';
import { PlaylistType } from '../model/MusicData';
import { BaseNetEasePlayListViewModel } from './BaseNetEaseSwiperListViewModel'

/**
 * 网易云 听歌识曲榜
 */
@Observed
export class EveryLikeListViewModel extends BaseNetEasePlayListViewModel {
    constructor() {
        super();
        this.title = '大家都爱听';
        // this.brief = '每周四更新';
        this.pageSize = 3;
        // this.playListId = NetEasePlaylistId.LISTEN_HOT;
        this.playListId = playlistIds[0];
        this.playlistType = PlaylistType.NETEASE_LISTEN_HOT;
    }
}

/**
 * 网易云 网络热歌榜
 */
@Observed
export class TreasureMusicViewModel extends BaseNetEasePlayListViewModel {
    constructor() {
        super();
        this.title = '宝藏歌曲';
        // this.brief = '每周五更新';
        this.pageSize = 3;
        // this.playListId = NetEasePlaylistId.NET_HOT;
        this.playListId = playlistIds[1];
        this.playlistType = PlaylistType.NETEASE_NETWORK_HOT;
    }
}


// 网易云 听歌识曲榜
export const everyLikeListViewModel = new EveryLikeListViewModel();

// 网易云 网络热歌榜
export const treasureMusicViewModel = new TreasureMusicViewModel();