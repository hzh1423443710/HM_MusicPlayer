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
        this.playListType = PlayListType.NETEASE_LISTEN_HOT;
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
        this.playListType = PlayListType.NETEASE_NETWORK_HOT;
    }
}

/**
 * 网易云 飙升榜
 */
@Observed
export class NetEaseTopSurgeViewModel extends BaseNetEasePlayListViewModel {
    constructor() {
        super();
        this.title = '飙升榜';
        this.brief = '';
        this.playListId = NetEasePlayListId.SURGE;
        this.batchSize = 10;
        this.playListType = PlayListType.NETEASE_TOP_SURGE;
        // 重写
        this.loadMusic = async () => {
            this.musicList = await this.http.getNetEaseTop(this.playListId);
            this.brief = `${this.musicList.length}首`;
        };
    }
}

/**
 * 网易云 新歌榜
 */
@Observed
export class NetEaseTopNewViewModel extends BaseNetEasePlayListViewModel {
    constructor() {
        super();
        this.title = '新歌榜';
        this.brief = '';
        this.playListId = NetEasePlayListId.NEW;
        this.batchSize = 10;
        this.playListType = PlayListType.NETEASE_TOP_NEW;
        // 重写
        this.loadMusic = async () => {
            this.musicList = await this.http.getNetEaseTop(this.playListId);
            this.brief = `${this.musicList.length}首`;
        };
    }
}

/**
 * 网易云 原创榜
 */
@Observed
export class NetEaseTopOriginalViewModel extends BaseNetEasePlayListViewModel {
    constructor() {
        super();
        this.title = '原创榜';
        this.brief = '';
        this.playListId = NetEasePlayListId.ORIGINAL;
        this.batchSize = 10;
        this.playListType = PlayListType.NETEASE_TOP_ORIGINAL;
        // 重写
        this.loadMusic = async () => {
            this.musicList = await this.http.getNetEaseTop(this.playListId);
            this.brief = `${this.musicList.length}首`;
        };
    }
}

/**
 * 网易云 热歌榜
 */
@Observed
export class NetEaseTopHotViewModel extends BaseNetEasePlayListViewModel {
    constructor() {
        super();
        this.title = '热歌榜';
        this.brief = '';
        this.playListId = NetEasePlayListId.HOT;
        this.batchSize = 10;
        this.playListType = PlayListType.NETEASE_TOP_HOT;
        // 重写
        this.loadMusic = async () => {
            this.musicList = await this.http.getNetEaseTop(this.playListId);
            this.brief = `${this.musicList.length}首`;
        };
    }

}


// 网易云 听歌识曲榜
export const everyLikeListViewModel = new EveryLikeListViewModel();

// 网易云 网络热歌榜
export const treasureMusicViewModel = new TreasureMusicViewModel();

// 网易云 飙升榜
export const topSurgeViewModel = new NetEaseTopSurgeViewModel();

// 网易云 新歌榜
export const topNewViewModel = new NetEaseTopNewViewModel();

// 网易云 原创榜
export const topOriginalViewModel = new NetEaseTopOriginalViewModel();

// 网易云 热歌榜
export const topHotViewModel = new NetEaseTopHotViewModel();
