/**
 * 网易云API合集
 */
export class NetEaseAPI {
    private static readonly HOST = 'http://119.3.185.203:8000';
    // 获取用户歌单?uid=
    static readonly USER_PLAYLISTS = NetEaseAPI.HOST + "/user/playlist";
    // 获取歌单所有歌曲 ?id=
    static readonly PLAYLIST_ALL = NetEaseAPI.HOST + "/playlist/track/all";
    // 歌曲/歌手搜索 ?keyword=
    static readonly SEARCH = NetEaseAPI.HOST + "/search";
    // 歌手所有歌曲 ?id=
    static readonly SINGER_SONGS = NetEaseAPI.HOST + "/artist/songs";
    // 随机一曲
    static readonly RAND_SONG = "https://api.52vmy.cn/api/music/wy/rand"
    // 网易云 播放链接 + 歌曲搜索
    static readonly SEARCH_OR_PLAY_URL = "https://api.vkeys.cn/v2/music/netease";
    // 歌词
    static readonly LYRIC = "https://api.vkeys.cn/v2/music/netease/lyric";
}

/**
 * 所有歌单id
 */
export class NetEasePlaylistId {
    // 飙升榜
    static readonly SURGE = "19723756";
    // 新歌榜
    static readonly NEW = '3779629';
    // 原创榜
    static readonly ORIGINAL = "2884035";
    // 热歌榜
    static readonly HOT = "3778678";
    /************************************************************************************************/
    // 云音乐说唱帮
    static readonly RAP = "991319590";
    // 云音乐古典榜
    static readonly CLASSICAL = "71384707";
    // 云音乐电音榜
    static readonly ELECTRONIC = "1978921795";
    // 潮流风向榜
    static readonly TREND = "13372522766";
    // 云音乐欧美热歌榜
    static readonly OCCIDENT_HOT = "2809513713";
    // 云音乐欧美新歌榜
    static readonly OCCIDENT_NEW = "2809577409";
    // 云音乐国风榜
    static readonly NATIONAL_WIND = "5059642708";
    // 云音乐民谣榜
    static readonly FOLK = "5059661515";
    // 俄语榜
    static readonly RUSSIA = "6732051320";
    // 越南语榜
    static readonly VIETNAM = "6732014811";
    // 中文慢摇DJ榜
    static readonly SLOW_ROCK_DJ = "6886768100";
    // 听歌识曲榜
    static readonly LISTEN_HOT = "6688069460";
    // 网络热歌榜
    static readonly NET_HOT = "6723173524";
}

function getRandomPlaylistIds(num: number): string[] {
    // 获取所有歌单 ID
    const allIds = [
        NetEasePlaylistId.RAP,
        NetEasePlaylistId.CLASSICAL,
        NetEasePlaylistId.ELECTRONIC,
        NetEasePlaylistId.TREND,
        NetEasePlaylistId.OCCIDENT_HOT,
        NetEasePlaylistId.OCCIDENT_NEW,
        NetEasePlaylistId.NATIONAL_WIND,
        NetEasePlaylistId.FOLK,
        NetEasePlaylistId.RUSSIA,
        NetEasePlaylistId.VIETNAM,
        NetEasePlaylistId.SLOW_ROCK_DJ,
        NetEasePlaylistId.LISTEN_HOT,
        NetEasePlaylistId.NET_HOT
    ];

    // 检查是否可以生成足够的唯一 ID
    if (num > allIds.length) {
        throw new Error("请求的数量超过了可用的播放列表 ID 数量");
    }

    // 打乱数组顺序
    const shuffledIds = allIds.sort(() => Math.random() - 0.5);

    // 返回前 num 个 ID
    return shuffledIds.slice(0, num);
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
 * QQ音乐 音质 枚举
 */
export enum QQMusicQuality {
    // 音乐试听
    TRIAL = 0,
    // 有损音质 - 1
    LOSSY_1 = 1,
    // 有损音质 - 2
    LOSSY_2 = 2,
    // 有损音质 - 3
    LOSSY_3 = 3,
    // 标准音质 - 1
    STANDARD_1 = 4,
    // 标准音质 - 2
    STANDARD_2 = 5,
    // 标准音质 - 3
    STANDARD_3 = 6,
    // 标准音质 - 4
    STANDARD_4 = 7,
    // HQ高音质
    HQ = 8,
    // HQ高音质（音质增强）
    HQ_ENHANCED = 9,
    // SQ无损音质
    SQ = 10,
    // Hi-Res音质
    HI_RES = 11,
    // 杜比全景声
    DOLBY_ATMOS = 12,
    // 臻品全景声
    PREMIUM_ATMOS = 13,
    // 臻品母带2.0
    PREMIUM_MASTER = 14
}

export const playlistIds: string[] = getRandomPlaylistIds(2);