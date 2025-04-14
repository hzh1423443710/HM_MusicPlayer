import { NetEasePlayListId } from '../common/constants/Netease';
import { PlaylistType } from '../model/MusicData';
import { BaseNetEaseLongListViewModel } from './BaseNetEaseLongListViewModel';

/**
 * 网易云 飙升榜
 */
@Observed
export class NetEaseTopSurgeViewModel extends BaseNetEaseLongListViewModel {
    constructor() {
        super();
        this.title = '飙升榜';
        this.brief = '';
        this.playListId = NetEasePlayListId.SURGE;
        // this.batchSize = 5;
        this.playlistType = PlaylistType.NETEASE_TOP_SURGE;
    }
}

/**
 * 网易云 新歌榜
 */
@Observed
export class NetEaseTopNewViewModel extends BaseNetEaseLongListViewModel {
    constructor() {
        super();
        this.title = '新歌榜';
        this.brief = '';
        this.playListId = NetEasePlayListId.NEW;
        // this.batchSize = 5;
        this.playlistType = PlaylistType.NETEASE_TOP_NEW;
    }
}

/**
 * 网易云 原创榜
 */
@Observed
export class NetEaseTopOriginalViewModel extends BaseNetEaseLongListViewModel {
    constructor() {
        super();
        this.title = '原创榜';
        this.brief = '';
        this.playListId = NetEasePlayListId.ORIGINAL;
        // this.batchSize = 5;
        this.playlistType = PlaylistType.NETEASE_TOP_ORIGINAL;
    }
}

/**
 * 网易云 热歌榜
 */
@Observed
export class NetEaseTopHotViewModel extends BaseNetEaseLongListViewModel {
    constructor() {
        super();
        this.title = '热歌榜';
        this.brief = '';
        this.playListId = NetEasePlayListId.HOT;
        // this.batchSize = 5;
        this.playlistType = PlaylistType.NETEASE_TOP_HOT;
    }
}

// 网易云 飙升榜
export const topSurgeViewModel = new NetEaseTopSurgeViewModel();

// 网易云 新歌榜
export const topNewViewModel = new NetEaseTopNewViewModel();

// 网易云 原创榜
export const topOriginalViewModel = new NetEaseTopOriginalViewModel();

// 网易云 热歌榜
export const topHotViewModel = new NetEaseTopHotViewModel();
