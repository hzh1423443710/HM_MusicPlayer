import { NetEasePlayListId } from '../common/constants/Netease';
import { HttpUtils } from '../common/network/HttpUtils';
import { MusicInfo, PlaylistType } from '../model/MusicData'
import { DataSource } from './SongDataSource'

@Observed
export abstract class BaseNetEasePlayListViewModel {
    protected http: HttpUtils = new HttpUtils();
    // 使用 SongDataSource 作为单一数据源
    songDataSource: DataSource<MusicInfo> = new DataSource<MusicInfo>();

    // 为了兼容性保留 musicList getter
    get musicList(): MusicInfo[] {
        return this.songDataSource.items;
    }

    // 标题
    title: string = '';
    // 简介
    brief: string = '';
    // http-查询参数-歌单id
    playListId: NetEasePlayListId;
    // 播放列表类型
    playlistType: PlaylistType;
    // 是否正在加载
    isLoading: boolean = false;
    // 更新触发器
    updateTrigger: number = 0;
    batchSize: number;

    protected notifyUpdate() {
        this.updateTrigger++;
    }

    public getPlayListType(): PlaylistType {
        return this.playlistType;
    }

    // 调试信息
    public debugInfo() {
        for (let i = 0; i < this.songDataSource.totalCount(); ++i) {
            console.log(`${i}-${this.songDataSource.getData(i)}`);
        }
    }

    public async loadMusic() {
        if (this.isLoading)
            return;

        this.isLoading = true;

        try {
            // 清空旧数据
            this.songDataSource.clearData();

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
                        music.index = this.songDataSource.totalCount() + batch.length;
                        batch.push(music);
                    }
                }

                // 将批次数据添加到数据源
                batch.forEach(item => {
                    this.songDataSource.pushData(item);
                });

                // 通知UI更新
                this.notifyUpdate();
            }

            // 返回音乐列表
            return this.songDataSource.items;
        } catch (error) {
            console.error(`${this.title} 加载失败: ${error}`);
            const isNetworkAvailable = await this.http.netAvailable().catch(() => false);
            if (isNetworkAvailable)
                throw new Error(`${this.title} 加载失败`);
            else
                throw new Error(`网络不可用`);

        } finally {
            this.isLoading = false;
        }
    }

    // 获取指定页的歌曲 (用于分页显示)
    public getMusicItemsForPage(pageIndex: number): MusicInfo[] {
        const startIndex = pageIndex * this.batchSize;
        const endIndex = Math.min(startIndex + this.batchSize, this.songDataSource.totalCount());

        // 从songDataSource获取数据
        const items = [];
        for (let i = startIndex; i < endIndex; i++) {
            items.push(this.songDataSource.getData(i));
        }
        return items;
    }

    // 获取总页数
    public getPageCount(): number {
        return Math.ceil(this.songDataSource.totalCount() / this.batchSize);
    }

    // 资源清理
    public destroy() {
        this.http.destroy();
    }
}
