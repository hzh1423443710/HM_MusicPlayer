/**
 * 网易云API合集
 */
export class NetEaseAPI {
    private static readonly HOST = 'http://119.3.185.203:8000';
    /**
     * 获取歌单详情 "https://163api.qijieya.cn/docs/#/?id=%e8%8e%b7%e5%8f%96%e6%ad%8c%e5%8d%95%e8%af%a6%e6%83%85"
     */
    static readonly PLAYLIST_DETAIL = NetEaseAPI.HOST + "/playlist/detail";
    /**
     * 获取歌单所有歌曲 "https://163api.qijieya.cn/docs/#/?id=%e8%8e%b7%e5%8f%96%e6%ad%8c%e5%8d%95%e6%89%80%e6%9c%89%e6%ad%8c%e6%9b%b2"
     * params: id
     */
    static readonly PLAYLIST_ALL = NetEaseAPI.HOST + "/playlist/track/all";
    /**
     * 搜索 "https://163api.qijieya.cn/docs/#/?id=%e6%90%9c%e7%b4%a2"
     * param: keyword
     */
    // static readonly SEARCH = NetEaseAPI.HOST + "/search";
    /**
     * 获取播放链接 "https://163api.qijieya.cn/docs/#/?id=%e6%90%9c%e7%b4%a2"
     * param: id
     */
    // static readonly SONG_URL = NetEaseAPI.HOST + "/song/url";
    /**
     * 随机一曲
     */
    static readonly RAND_SONG = "https://api.52vmy.cn/api/music/wy/rand"
    /**
     * 网易云播放链接
     */
    static readonly SEARCH_OR_PLAY_URL = "https://api.vkeys.cn/v2/music/netease";
    /**
     * 歌词
     */
    static readonly LYRIC = "https://api.vkeys.cn/v2/music/netease/lyric";
}

/**
 * 所有歌单id
 */
export class NetEasePlaylistId {
    /**
     * 飙升榜
     */
    static readonly SURGE = "19723756";
    /**
     * 新歌榜
     */
    static readonly NEW = '3779629';
    /**
     * 原创榜
     */
    static readonly ORIGINAL = "2884035";
    /**
     * 热歌榜
     */
    static readonly HOT = "3778678";
    /************************************************************************************************/

    /**
     * 云音乐说唱帮
     */
    static readonly RAP = "991319590";
    /**
     * 云音乐古典榜
     */
    static readonly CLASSICAL = "201209";
    /**
     * 云音乐电音榜
     */
    static readonly ELECTRONIC = "1978921795";
    /**
     * 潮流风向榜
     */
    static readonly TREND = "13372522766";
    /**
     * 云音乐欧美热歌榜
     */
    static readonly OCCIDENT_HOT = "2809513713";
    /**
     * 云音乐欧美新歌榜
     */
    static readonly OCCIDENT_NEW = "2809577409";
    /**
     * 云音乐国风榜
     */
    static readonly NATIONAL_WIND = "5059642708";
    /**
     * 云音乐民谣榜
     */
    static readonly FOLK = "5059661515";
    /**
     * 俄语榜
     */
    static readonly RUSSIA = "6732051320";
    /**
     * 越南语榜
     */
    static readonly VIETNAM = "6732014811";
    /**
     * 中文慢摇DJ榜
     */
    static readonly SLOW_ROCK_DJ = "6886768100";
    /**
     * 听歌识曲榜
     */
    static readonly LISTEN_HOT = "6688069460";
    /**
     * 网络热歌榜
     */
    static readonly NET_HOT = "6723173524";
}

/**
 * 网易云 音质 枚举
 */
export enum NetEaseQuality {
    // 标准64k
    STANDARD_64K = 1,
    // 标准128k
    STANDARD_128K = 2,
    // HQ 192k
    HQ_192K = 3,
    // HQ 320k
    HQ_320K = 4,
    // SQ无损
    SQ = 5,
    // 高解析度无损
    HI_RES = 6,
    // 高清臻音
    SPATIAL = 7,
    // 沉浸环绕声
    SURROUND = 8,
    // 超清母带
    MASTER = 9
}

/**
 * 网易云音质显示文本映射
 */
export const NetEaseQualityString: Map<NetEaseQuality, string> = new Map([
    [NetEaseQuality.STANDARD_64K, "标准（64k）"],
    [NetEaseQuality.STANDARD_128K, "标准（128k）"],
    [NetEaseQuality.HQ_192K, "HQ极高（192k）"],
    [NetEaseQuality.HQ_320K, "HQ极高（320k）"],
    [NetEaseQuality.SQ, "SQ无损"],
    [NetEaseQuality.HI_RES, "高解析度无损（Hi-Res）"],
    [NetEaseQuality.SPATIAL, "高清臻音（Spatial Audio）"],
    [NetEaseQuality.SURROUND, "沉浸环绕声（Surround Audio）"],
    [NetEaseQuality.MASTER, "超清母带（Master）"]
]);
