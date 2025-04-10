import { NetEasePlayListId } from '../common/constants/Netease';
import { HttpUtils } from '../common/network/HttpUtils';
import { MusicFrom, MusicInfo, PlayListType } from '../model/MusicData'
import { MusicListData } from './MusicDataViewModel'
import { SongDataSource } from './SongDataSource';

@Observed
export abstract class BaseNetEasePlayListViewModel {
    protected http: HttpUtils = new HttpUtils();
    // 播放列表
    musicList: MusicInfo[] = MusicListData;
    // 标题
    title: string = '';
    // 简介
    brief: string = '';
    // http-查询参数-歌单id
    playListId: NetEasePlayListId;
    // 播放列表类型
    playListType: PlayListType;
    // 是否正在加载
    isLoading: boolean = false;
    // 更新触发器
    updateTrigger: number = 0;
    batchSize: number;

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

        // 批量处理
        for (let i = 0; i < ids.length; i += this.batchSize) {
            let batch = [];
            const end = Math.min(i + this.batchSize, ids.length);

            for (let j = i; j < end; j++) {
                let music = await this.http.getNetEaseMusic(ids[j]);
                if (music) {
                    music.index = this.musicList.length + batch.length;
                    music.playList = this.playListType;
                    batch.push(music);
                }
            }

            // 一次更新多首歌曲
            this.musicList = [...this.musicList, ...batch];
            this.notifyUpdate();
        }

        this.isLoading = false;
    }

    // 资源清理
    destroy() {
        this.http.destroy();
    }
}
