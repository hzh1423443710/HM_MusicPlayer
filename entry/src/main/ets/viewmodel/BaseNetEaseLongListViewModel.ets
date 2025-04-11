import { NetEasePlayListId } from '../common/constants/Netease';
import { HttpUtils } from '../common/network/HttpUtils';
import { MusicInfo, PlayListType } from '../model/MusicData';
import { SongDataSource } from './SongDataSource';

/**
 * 长列表
 */
@Observed
export abstract class BaseNetEaseLongListViewModel {
    protected http: HttpUtils = new HttpUtils();
    // LazyForEach 数据源 动态加载
    songDataSource: SongDataSource = new SongDataSource();
    // 100首歌曲信息
    musicList: MusicInfo[] = [];
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
    // 批处理数量
    batchSize: number = 10;
    // 动态加载索引
    private loadingIndex: number = 0;

    getPlayListType(): PlayListType {
        return this.playListType;
    }

    // 调试信息
    debugInfo() {
        for (let i = 0; i < this.songDataSource.musics.length; ++i) {
            console.log(`${i}-${this.songDataSource.musics[i]}`);
        }
    }

    protected async loadMusic() {
        if (this.isLoading)
            return;

        this.isLoading = true;
        // 获取100首信息
        this.musicList = await this.http.getNetEaseTop(this.playListId);
        if (this.musicList != null)
            this.brief = `${this.musicList.length}首`;
        else {
            this.isLoading = false;
            throw new Error(`${this.title} loadMusic Failed`);
        }

        this.isLoading = false;
    }

    /**
     * 首次加载 batchSize 首
     */
    loadMusicFirst() {
        this.loadMusic().then(() => {
            for (this.loadingIndex = 0; this.loadingIndex < this.batchSize; this.loadingIndex++) {
                this.songDataSource.pushData(this.musicList[this.loadingIndex]);
            }
            console.log(`${this.title} 加载成功`);
        }).catch(() => {
            console.error(`${this.title} 加载失败`);
        });
    }

    /**
     * 非首次加载
     */
    loadMusicNonFirst() {
        if (this.isLoading)
            return;

        if (this.loadingIndex < this.musicList.length) {
            this.isLoading = true;

            for (let i = 0; i < this.batchSize && this.loadingIndex < this.musicList.length; ++i, ++this.loadingIndex) {
                this.songDataSource.pushData(this.musicList[this.loadingIndex]);
            }

            this.isLoading = false;
            return this.batchSize;
        }
        else {
            return 0;
        }

    }

    refreshMusic() {
        // 先清空
        this.songDataSource.clearData();
        this.loadMusicFirst();
    }

    // 资源清理
    destroy() {
        this.http.destroy();
    }
}
