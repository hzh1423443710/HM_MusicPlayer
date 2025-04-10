/**
 * 网易云 音质
 */
export class NetEaseQuality {
    // 标准64k
    static readonly standard_64K = 1;
    // 标准128k
    static readonly standard_128K = 2;
    // HQ 192k
    static readonly HQ_192K = 3;
    // HQ 320k
    static readonly HQ_320K = 4;
    // SQ无损
    static readonly SQ = 5;
    // 高解析度无损
    static readonly HI_RES = 6;
    // 高清臻音
    static readonly SPATIAL = 7;
    // 沉浸环绕声
    static readonly SURROUND = 8;
    // 超清母带
    static readonly MASTER = 9;
}

/**
 * 网易云 歌单/榜单 ID
 */
export class NetEasePlayListId {
    // 听歌识曲榜
    static readonly LISTEN_HOT = "6688069460";
    // 网络热歌榜
    static readonly NET_HOT = "6723173524";
}

/**
 * 网易云 top榜单 ID
 */
export enum NetEaseTopPlayListId {
    ORIGINAL, // 原创榜
    NEW, // 新歌榜
    SURGE, // 飙升榜
    HOT, // 热歌榜
}