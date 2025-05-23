import { HttpUtils } from '../common/network/HttpUtils'
import { enumToString, MusicInfo, PlaylistType } from '../model/MusicData';
import { DataSource } from './SongDataSource';

const TAG = 'SearchViewModel';

/**
 * 搜索平台
 */
export enum MusicPlatform {
    NETEASE,
    QQ
}

/**
 * 搜索状态
 */
export enum SearchState {
    IDLE,
    SEARCHING,
    SUCCESS,
    ERROR,
    EMPTY
}


@Observed
export class SearchViewModel {
    http: HttpUtils = new HttpUtils();
    // 搜索结果 数据源
    songDataSource: DataSource<MusicInfo> = new DataSource<MusicInfo>();
    // 播放列表类型
    playlistType: string = PlaylistType.SEARCH;
    searchState: SearchState = SearchState.IDLE;
    platform: MusicPlatform = MusicPlatform.NETEASE;
    errorMessage: string = '';
    keyword: string = '';
    // 搜素结果分页相关
    currentPage: number = 1;
    hasMore: boolean = false;
    pageSize: number = 10; // 每页数据条数

    /**
     * 设置搜索关键字
     * @param keyword
     */
    setKeyword(keyword: string) {
        this.keyword = keyword;
    }

    /**
     * 切换搜索平台
     */
    switchPlatform() {
        this.platform = (this.platform === MusicPlatform.NETEASE) ?
        MusicPlatform.QQ : MusicPlatform.NETEASE;

        // 如果已有搜索内容，切换平台后重新搜索
        if (this.keyword && this.keyword.trim() !== '') {
            this.search();
        }
    }

    /**
     * 获取当前数据源
     * @returns
     */
    getCurrentDataSource() {
        return this.songDataSource;
    }

    /**
     * 重置所有
     */
    resetAll() {
        this.currentPage = 1;
        this.hasMore = false;
        this.errorMessage = '';
        this.keyword = '';
        this.searchState = SearchState.IDLE;

        this.songDataSource.clearData();
    }

    /**
     * 重置搜索状态
     */
    resetSearchState() {
        this.currentPage = 1;
        this.hasMore = false;
        this.errorMessage = '';
        this.keyword = '';
        this.searchState = SearchState.IDLE;

        this.clearCurrentData();
    }

    /**
     *  清空当前数据
     */
    private clearCurrentData() {
        this.songDataSource.clearData();
    }

    /**
     * 搜索
     * @param resetData 是否重置数据
     */
    async search(resetData: boolean = true): Promise<boolean> {
        if (!this.keyword || this.keyword.trim() === '') {
            return false;
        }

        this.searchState = SearchState.SEARCHING;

        // 重置数据：清除数据 并 更新页码为1
        if (resetData) {
            this.clearCurrentData();
            this.currentPage = 1;
        }

        try {
            return await this.searchSongs();
        } catch (e) {
            console.error(`${TAG} search error: ${e}`);
            this.searchState = SearchState.ERROR;
            this.errorMessage = `搜索失败:${e}`;
            return false;
        }
    }

    /**
     * 加载更多
     * @returns
     */
    async loadMore(): Promise<boolean> {
        if (!this.hasMore || this.searchState === SearchState.SEARCHING)
            return false;

        // 不重置数据  继续搜索
        return await this.search(false);
    }

    /**
     * 刷新搜索结果
     * @returns
     */
    async refresh(): Promise<boolean> {
        return await this.search(true);
    }

    /**
     * 搜索歌曲
     * @returns
     */
    async searchSongs(): Promise<boolean> {
        let results: MusicInfo[] = [];
        if (this.platform === MusicPlatform.NETEASE) {
            while (results.length === 0) {
                results = await this.http.getSongsByNetEase(this.keyword, this.currentPage);
            }
            // results = await this.http.getSongsByNetEase(this.keyword, (this.currentPage - 1) * this.pageSize);
        }
        else {
            while (results.length === 0) {
                results = await this.http.getSongsByQQ(this.keyword, this.currentPage);
            }
        }

        // results.forEach((item, index) => {
        //     console.log(`${index}-${item}`);
        // })

        if (results === null) {
            this.searchState = SearchState.ERROR;
            this.errorMessage = '网络错误或服务不可用';
            return false;
        }

        // 搜索结果为空
        if (results.length === 0) {
            this.searchState = this.songDataSource.totalCount() > 0 ? SearchState.SUCCESS : SearchState.EMPTY;
            this.hasMore = false;
            return true;
        }

        // 搜索结果不为空
        results.forEach((item) => {
            this.songDataSource.pushData(item);
        });

        this.searchState = SearchState.SUCCESS;
        this.currentPage++;
        this.hasMore = results.length >= this.pageSize;

        console.log(`${TAG} search songs: ${results.length}, 总数: ${this.songDataSource.totalCount()}首`)

        return true;
    }

    /**
     * 获取状态文本
     * @returns
     */
    getStateText(): string {
        switch (this.searchState) {
            case SearchState.IDLE:
                return '请输入关键字';
            case SearchState.SEARCHING:
                return ' 搜索中';

            case SearchState.ERROR:
                return this.errorMessage || '搜索出错';

            case SearchState.EMPTY:
                return `未找到与"${this.keyword}"相关的歌曲`;

            case SearchState.SUCCESS:
            default:
                return '加载完毕';
        }

    }

    destroy() {
        this.http.destroy();
    }
}

export const searchViewModel = new SearchViewModel();