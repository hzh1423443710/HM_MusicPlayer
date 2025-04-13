export enum MusicFrom {
    NetEase, //网易云
    QQ //qq音乐
}

/**
 * 播放列表类型
 */
export enum PlayListType {
    NONE, // 无播放列表
    RECENT, // 最近播放-上限500首
    QQ_SEARCH, // 搜索结果
    NETEASE_RANDOM_SONG, // 随机一曲
    NETEASE_LISTEN_HOT, // 大家都爱听
    NETEASE_NETWORK_HOT, // 网络热歌
    NETEASE_TOP_ORIGINAL, // 原创榜
    NETEASE_TOP_NEW, // 新歌榜
    NETEASE_TOP_SURGE, // 飙升榜
    NETEASE_TOP_HOT, // 热歌榜
    USER_LOVE, // 用户收藏-歌单
    USER_NETEASE_PLAYLIST, // 用户 网易云-歌单
    USER_QQ_PLAYLIST, // 用户 QQ-歌单
}

export function enumToString(enumObj: any, value: number): string {
    return enumObj[value];
}

@Observed
export class MusicInfo {
    // 歌曲id
    id: string = '';
    // 歌曲名
    name: string = '谁(Live)';
    //歌手
    singer: string = '廖俊涛';
    // 外链
    url?: string = '';
    // 封面 pic
    pic?: string = '';
    // 歌词链接
    lrc?: string = '';
    // 是否收费
    pay?: boolean = false;
    // 来自
    where?: MusicFrom;
    // 播放列表中的索引
    index?: number = -1
    // 用户喜欢
    love?: boolean = false;

    constructor(index: number = 0, id: string = '', name = '谁(Live)', singer = '廖俊涛', url = '', pic = '', lrc = '', pay = false, where = MusicFrom.NetEase) {
        this.index = index;
        this.id = id;
        this.name = name;
        this.singer = singer;
        this.url = url;
        this.pic = pic;
        this.lrc = lrc;
        this.pay = pay;
        this.where = where;
    }

    /**
     * 判断音乐标识 是否相同
     * @param other
     * @returns
     */
    equals(other: MusicInfo): boolean {
        return this.id === other.id && this.where === other.where;
    }

    toString(): string {
        return `id: ${this.id}, name: ${this.name}, singer: ${this.singer}, url: ${this.url}, cover_url: ${this.pic}, lrc_url: ${this.lrc}, pay: ${this.pay}, where: ${this.where}`;
    }
}