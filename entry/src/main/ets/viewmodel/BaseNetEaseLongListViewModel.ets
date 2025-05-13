import { NetEasePlaylistId } from '../common/constants/NetEaseAPI';
import { HttpUtils } from '../common/network/HttpUtils';
import { MusicInfo, PlaylistType } from '../model/MusicData';
import { DataSource } from './SongDataSource';

/**
 * 长列表
 */
@Observed
export abstract class BaseNetEaseLongListViewModel {
    protected http: HttpUtils = new HttpUtils();
    // 唯一数据源
    songDataSource: DataSource<MusicInfo> = new DataSource<MusicInfo>();
    // 存储完整的音乐列表
    private fullMusicList: MusicInfo[] = [];
    // 标题
    title: string = '';
    // 简介
    brief: string = '';
    // http-查询参数-歌单id
    playListId: string;
    // 播放列表类型
    playlistType: string;
    // 是否正在加载
    isLoading: boolean = false;
    // 批处理数量
    batchSize: number = 20;
    // 动态加载索引
    private loadingIndex: number = 0;

    get musicList(): MusicInfo[] {
        return this.songDataSource.items;
    }

    getPlayListType(): PlaylistType {
        return this.playlistType;
    }

    // 调试信息
    debugInfo() {
        for (let i = 0; i < this.songDataSource.items.length; ++i) {
            console.log(`${i}-${this.songDataSource.items[i]}`);
        }
    }

    protected async loadMusic() {
        if (this.isLoading) return;

        this.isLoading = true;

        // 清空旧数据
        this.songDataSource.clearData();

        try {
            // 获取音乐数据
            // const musics = await this.http.getNetEaseTop(this.playListId);
            const songs = await this.http.getNetEasePlaylistSongs(this.playListId);

            if (songs && songs.length > 0) {
                this.brief = `${songs.length}首`;
                // 仅保存一次
                this.loadingIndex = 0; // 重置加载索引
            } else {
                throw new Error(`${this.title} loadMusic Failed`);
            }

            // 存储获取到的完整数据引用
            this.fullMusicList = songs;
        } finally {
            this.isLoading = false;
        }
    }

    /**
     * 首次加载 batchSize 首
     * @returns Promise<number> 返回加载的歌曲数量
     */
    async loadMusicFirst(): Promise<number> {
        try {
            // 加载音乐数据
            await this.loadMusic();

            // 计算加载前的数量
            const countBefore = this.songDataSource.totalCount();

            // 批量加载到数据源
            this.loadBatchToDataSource();

            // 计算新加载的数量
            const loadedCount = this.songDataSource.totalCount() - countBefore;
            console.log(`${this.title} 加载成功，共加载 ${loadedCount} 首歌曲`);

            return loadedCount;
        } catch (error) {
            console.error(`${this.title} 加载失败: ${error}`);
            this.brief = '加载失败(点击刷新)';

            // 检查网络状态
            const netAvailable = await this.http.netAvailable();
            if (netAvailable)
                throw new Error(`${this.title} 加载失败`);
            else
                throw new Error(`网络不可用`);
        }
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
     * @returns Promise<number> 返回加载的歌曲数量
     */
    async refreshMusic(): Promise<number> {
        // 清空旧数据
        this.songDataSource.clearData();
        this.loadingIndex = 0; // 重置加载索引

        // 调用首次加载并返回结果
        return await this.loadMusicFirst();
    }

    // 资源清理
    destroy() {
        this.http.destroy();
        this.fullMusicList = [];
    }
}
