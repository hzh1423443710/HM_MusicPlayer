import { NetEasePlayListId } from '../common/constants/Netease';
import { PlayListType } from '../model/MusicData';
import { BaseNetEasePlayListViewModel } from './BaseNetEasePlayListViewModel'

/**
 * 网易云 听歌识曲榜
 */
@Observed
export class EveryLikeListViewModel extends BaseNetEasePlayListViewModel {
    constructor() {
        super();
        this.title = '大家都爱听';
        this.brief = '每周四更新';
        this.batchSize = 3;
        this.playListId = NetEasePlayListId.LISTEN_HOT;
        this.playlistType = PlayListType.NETEASE_LISTEN_HOT;
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
        this.brief = '每周五更新';
        this.batchSize = 3;
        this.playListId = NetEasePlayListId.NET_HOT;
        this.playlistType = PlayListType.NETEASE_NETWORK_HOT;
    }
}



// 网易云 听歌识曲榜
export const everyLikeListViewModel = new EveryLikeListViewModel();

// 网易云 网络热歌榜
export const treasureMusicViewModel = new TreasureMusicViewModel();