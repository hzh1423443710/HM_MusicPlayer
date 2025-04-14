
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

/**
 * QQ音乐音质显示文本映射
 */
export const QQMusicQualityString: Map<QQMusicQuality, string> = new Map([
    [QQMusicQuality.TRIAL, "音乐试听"],
    [QQMusicQuality.LOSSY_1, "有损音质"],
    [QQMusicQuality.LOSSY_2, "有损音质"],
    [QQMusicQuality.LOSSY_3, "有损音质"],
    [QQMusicQuality.STANDARD_1, "标准音质"],
    [QQMusicQuality.STANDARD_2, "标准音质"],
    [QQMusicQuality.STANDARD_3, "标准音质"],
    [QQMusicQuality.STANDARD_4, "标准音质"],
    [QQMusicQuality.HQ, "HQ高音质"],
    [QQMusicQuality.HQ_ENHANCED, "HQ高音质（音质增强）"],
    [QQMusicQuality.SQ, "SQ无损音质"],
    [QQMusicQuality.HI_RES, "Hi-Res音质"],
    [QQMusicQuality.DOLBY_ATMOS, "杜比全景声"],
    [QQMusicQuality.PREMIUM_ATMOS, "臻品全景声"],
    [QQMusicQuality.PREMIUM_MASTER, "臻品母带2.0"]
]);