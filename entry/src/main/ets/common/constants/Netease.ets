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

/**
 * 网易云 歌单/榜单 ID 枚举
 * 注意: 部分ID是字符串，需要特殊处理
 */
export enum NetEasePlayListId {
    // top10 听歌识曲榜
    LISTEN_HOT = "6688069460",
    // top10 网络热歌榜
    NET_HOT = "6723173524",
    // top100 原创榜
    ORIGINAL = 1,
    // top100 新歌榜
    NEW = 2,
    // top100 飙升榜
    SURGE = 3,
    // top100 热歌榜
    HOT = 4
}