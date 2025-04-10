import { NetEasePlayListId } from '../common/constants/Netease';
import { BaseNetEasePlayListViewModel } from './BaseNetEasePlayListViewModel'

@Observed
export class EveryLikeListViewModel extends BaseNetEasePlayListViewModel {
    constructor() {
        super();
        this.title = '大家都爱听';
        this.brief = '每周四更新';
        this.playListId = NetEasePlayListId.LISTEN_HOT;
    }
}

@Observed
export class TreasureMusicViewModel extends BaseNetEasePlayListViewModel {
    constructor() {
        super();
        this.title = '宝藏歌曲';
        this.brief = '每周五更新';
        this.playListId = NetEasePlayListId.NET_HOT;
    }
}

export const everyLikeListViewModel = new EveryLikeListViewModel();

export const treasureMusicViewModel = new TreasureMusicViewModel();
