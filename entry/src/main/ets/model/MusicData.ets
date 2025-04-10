export enum MusicFrom {
    NetEase, //网易云
    QQ //qq音乐
}

/**
 * 播放列表类型
 */
export enum PlayListType {
    NETEASE_RAND, // 随机播放
    QQ_SEARCH, // 搜索
    NETEASE_LISTEN_HOT, // 大家都爱听
    NETEASE_NETWORK_HOT, // 网络热歌
    NETEASE_ORIGINAL, // 原创榜
    NETEASE_NEW, // 新歌榜
    NETEASE_SURGE, // 飙升榜
    NETEASE_HOT, // 热歌榜
}

@Observed
export class MusicInfo {
    // 歌曲id
    id: string
    // 歌曲名
    name: string
    //歌手
    singer: string
    // 外链
    url: string
    // 封面 pic
    pic: string
    // 时长
    duration?: string
    // 歌词链接
    lrc?: string
    // 是否收费
    pay: boolean
    // 来自
    where: MusicFrom
    // 播放列表中的索引
    index?: number = -1
    // 播放列表id
    playList?: PlayListType = PlayListType.NETEASE_RAND

    toString(): string {
        return `id: ${this.id}, name: ${this.name}, singer: ${this.singer}, url: ${this.url}, cover_url: ${this.pic}, lrc_url: ${this.lrc}, pay: ${this.pay}, where: ${this.where}`;
    }
}