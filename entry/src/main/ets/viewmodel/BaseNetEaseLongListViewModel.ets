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
    // 唯一数据源
    songDataSource: SongDataSource = new SongDataSource();
    // 存储完整的音乐列表
    private fullMusicList: MusicInfo[] = [];
    // 标题
    title: string = '';
    // 简介
    brief: string = '';
    // http-查询参数-歌单id
    playListId: NetEasePlayListId;
    // 播放列表类型
    playlistType: PlayListType;
    // 是否正在加载
    isLoading: boolean = false;
    // 批处理数量
    batchSize: number = 20;
    // 动态加载索引
    private loadingIndex: number = 0;

    get musicList(): MusicInfo[] {
        return this.songDataSource.musics;
    }

    getPlayListType(): PlayListType {
        return this.playlistType;
    }

    // 调试信息
    debugInfo() {
        for (let i = 0; i < this.songDataSource.musics.length; ++i) {
            console.log(`${i}-${this.songDataSource.musics[i]}`);
        }
    }

    protected async loadMusic() {
        if (this.isLoading) return;

        this.isLoading = true;

        // 清空旧数据
        this.songDataSource.clearData();

        try {
            // 获取音乐数据
            const musics = await this.http.getNetEaseTop(this.playListId);

            if (musics && musics.length > 0) {
                this.brief = `${musics.length}首`;
                // 仅保存一次
                this.loadingIndex = 0; // 重置加载索引
            } else {
                throw new Error(`${this.title} loadMusic Failed`);
            }

            // 存储获取到的完整数据引用
            this.fullMusicList = musics;
        } finally {
            this.isLoading = false;
        }
    }

    /**
     * 首次加载 batchSize 首
     */
    loadMusicFirst() {
        this.loadMusic().then(() => {
            this.loadBatchToDataSource();
            console.log(`${this.title} 加载成功`);
        }).catch(() => {
            console.error(`${this.title} 加载失败`);
        });
    }

    /**
     * 加载批次数据
     */
    private loadBatchToDataSource() {
        const endIndex = Math.min(this.loadingIndex + this.batchSize, this.fullMusicList.length);

        for (; this.loadingIndex < endIndex; this.loadingIndex++) {
            this.songDataSource.pushData(this.fullMusicList[this.loadingIndex]);
        }
    }

    /**
     * 非首次加载
     * @returns 返回加载的数量
     */
    loadMusicNonFirst() {
        if (this.isLoading) return 0;
        if (this.loadingIndex >= this.fullMusicList.length) return 0;

        this.isLoading = true;

        const startIndex = this.loadingIndex;
        this.loadBatchToDataSource();

        this.isLoading = false;
        return this.loadingIndex - startIndex;
    }

    /**
     * 刷新数据源
     */
    refreshMusic() {
        // 清空旧数据
        this.songDataSource.clearData();
        this.loadMusicFirst();
    }

    // 资源清理
    destroy() {
        this.http.destroy();
        this.fullMusicList = [];
    }
}
