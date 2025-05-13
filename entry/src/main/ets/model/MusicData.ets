export enum MusicFrom {
    NetEase, //网易云
    QQ //qq音乐
}

/**
 * 播放列表类型
 */
export class PlaylistType {
    static readonly NONE = 'NONE'; // 无播放列表
    static readonly RECENT = 'RECENT'; // 最近播放-上限500首
    static readonly SEARCH = 'SEARCH'; // 搜索结果
    static readonly NETEASE_RANDOM_SONG = 'NETEASE_RANDOM_SONG'; // 随机一曲
    static readonly NETEASE_LISTEN_HOT = 'NETEASE_LISTEN_HOT'; // 大家都爱听
    static readonly NETEASE_NETWORK_HOT = 'NETEASE_NETWORK_HOT'; // 网络热歌
    static readonly NETEASE_TOP_ORIGINAL = 'NETEASE_TOP_ORIGINAL'; // 原创榜
    static readonly NETEASE_TOP_NEW = 'NETEASE_TOP_NEW;'; // 新歌榜
    static readonly NETEASE_TOP_SURGE = 'NETEASE_TOP_SURGE;'; // 飙升榜
    static readonly NETEASE_TOP_HOT = 'NETEASE_TOP_HOT;'; // 热歌榜
}

export function enumToString(enumObj: any, value: number): string {
    return enumObj[value];
}

@Observed
export class MusicInfo {
    // 歌曲id
    id: string = '';
    // 歌曲名
    name: string = '';
    //歌手
    singer: string = '';
    // 外链
    url?: string = '';
    // 封面 pic
    pic?: string = '';
    // 是否收费
    pay?: boolean = false;
    // 来自
    where?: MusicFrom;
    // 播放列表中的索引
    index?: number = -1
    // 用户喜欢
    love?: boolean = false;

    constructor(index: number = 0, id: string = '', name = '', singer = '', url = '', pic = '', pay = false, where = MusicFrom.NetEase) {
        this.index = index;
        this.id = id;
        this.name = name;
        this.singer = singer;
        this.url = url;
        this.pic = pic;
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
        return `id: ${this.id}, name: ${this.name}, singer: ${this.singer}, pay: ${this.pay}, where: ${this.where} ${this.pic}`;
    }
}