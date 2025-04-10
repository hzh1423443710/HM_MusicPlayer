import { NetEaseTopPlayListId } from '../common/constants/Netease';
import { HttpUtils } from '../common/network/HttpUtils';
import { MusicInfo, PlayListType } from '../model/MusicData'
import { MusicListData } from '../viewmodel/MusicDataViewModel'

@Observed
export class NetEaseTopListViewModel {
    protected http: HttpUtils = new HttpUtils();
    topName: string = ''
    playListType: PlayListType;
    topId: NetEaseTopPlayListId;
    musicList: MusicInfo[] = MusicListData;

    constructor(topName: string, playListType: PlayListType, topId: NetEaseTopPlayListId) {
        this.topName = topName;
        this.playListType = playListType;
        this.topId = topId;
    }

    protected getPlayListType(): PlayListType {
        return this.playListType;
    }

    debugInfo() {
        for (let i = 0; i < this.musicList.length; ++i) {
            console.log(`${i}-${this.musicList[i]}`);
        }
    }

    async loadMusic() {
        this.musicList = await this.http.getNetEaseTop(this.topId);
    }

    destroy() {
        this.http.destroy();
    }
}

export const originalTopListViewModel = new NetEaseTopListViewModel('原创榜', PlayListType.NETEASE_ORIGINAL, NetEaseTopPlayListId.ORIGINAL);

export const newEaseTopListViewModel = new NetEaseTopListViewModel('新歌榜', PlayListType.NETEASE_NEW, NetEaseTopPlayListId.NEW);

export const surgeEaseTopListViewModel = new NetEaseTopListViewModel('飙升榜', PlayListType.NETEASE_SURGE, NetEaseTopPlayListId.SURGE);

export const hotEaseTopListViewModel = new NetEaseTopListViewModel('热歌榜', PlayListType.NETEASE_HOT, NetEaseTopPlayListId.HOT);