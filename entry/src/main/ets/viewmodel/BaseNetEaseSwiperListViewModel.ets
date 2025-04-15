import { NetEasePlaylistId } from '../common/constants/NetEaseAPI';
import { HttpUtils } from '../common/network/HttpUtils';
import { MusicInfo, PlaylistType } from '../model/MusicData'
import { DataSource } from './SongDataSource'

@Observed
export abstract class BaseNetEasePlayListViewModel {
    protected http: HttpUtils = new HttpUtils();
    // LazyForEach 数据源
    songDataSource: DataSource<MusicInfo> = new DataSource<MusicInfo>();

    get musicList(): MusicInfo[] {
        return this.songDataSource.items;
    }

    // 标题
    title: string = '';
    // 简介
    brief: string = '';
    // http-查询参数-歌单id
    playListId: NetEasePlaylistId;
    // 播放列表类型
    playlistType: PlaylistType;
    // 是否正在加载
    isLoading: boolean = false;
    // 每页显示的歌曲数量
    pageSize: number;

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
            const songs = await this.http.getNetEaseListSongs(this.playListId);
            for (let i = 0; i < 10; ++i) {
                this.songDataSource.pushData(songs[i]);
            }
            // songs.forEach((item) => {
            //     this.songDataSource.pushData(item);
            //     // this.notifyUpdate();
            // })

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
        const startIndex = pageIndex * this.pageSize;
        const endIndex = Math.min(startIndex + this.pageSize, this.songDataSource.totalCount());

        // 从songDataSource获取数据
        const items = [];
        for (let i = startIndex; i < endIndex; i++) {
            items.push(this.songDataSource.getData(i));
        }
        return items;
    }

    // 获取总页数
    public getPageCount(): number {
        return Math.ceil(this.songDataSource.totalCount() / this.pageSize);
    }

    // 资源清理
    public destroy() {
        this.http.destroy();
    }
}
