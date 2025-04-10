import { HttpUtils } from '../common/network/HttpUtils';
import { MusicFrom, MusicInfo, PlayListType } from '../model/MusicData'
import { MusicListData } from './MusicDataViewModel'

@Observed
export abstract class BaseNetEasePlayListViewModel {
    protected http: HttpUtils = new HttpUtils();
    musicList: MusicInfo[] = MusicListData;
    title: string = '';
    brief: string = '';
    // 网易云歌单id
    playListId: string;
    // 播放列表类型
    playListType: PlayListType;
    // 是否正在加载
    isLoading: boolean = false;
    // 更新触发器
    updateTrigger: number = 0;

    protected notifyUpdate() {
        this.updateTrigger++;
    }

    getPlayListType(): PlayListType {
        return this.playListType;
    }

    // 调试信息
    debugInfo() {
        for (let i = 0; i < this.musicList.length; ++i) {
            console.log(`${i}-${this.musicList[i]}`);
        }
    }

    async loadMusic() {
        if (this.isLoading)
            return;

        this.isLoading = true;
        this.musicList = [];

        // 获取所有的音乐id
        let ids: string[];
        while (true) {
            ids = await this.http.getNetEaseListId(this.playListId) as string[];
            if (ids === null)
                throw new Error(`获取网易云歌单id失败, id: ${this.playListId}`);
            if (ids.length === 0)
                continue;
            break;
        }

        // let tmp_list: MusicInfo[] = [];
        for (let i = 0; i < ids.length; i++) {
            let music: MusicInfo = await this.http.getNetEaseMusic(ids[i]);
            if (music === null)
                throw new Error(`获取网易云音乐失败, id: ${ids[i]}`);

            music.index = i;
            music.playList = this.playListType;
            // tmp_list.push(info);
            this.musicList.push(music);
            this.notifyUpdate();
        }

        // this.musicList = tmp_list;

        this.isLoading = false;
    }

    // 资源清理
    destroy() {
        this.http.destroy();
    }
}
