import { LyricData, LyricParserUtil } from '../common/LyricParseUtil';
import { HttpUtils } from '../common/network/HttpUtils';
import { MusicFrom } from '../model/MusicData';

const TAG: string = 'LyricViewModel';

/**
 * 歌词数据视图模型
 * 负责歌词的加载、缓存和管理
 */
export class LyricViewModel {
    httpUtils: HttpUtils = new HttpUtils();
    // 歌词缓存，使用歌曲ID作为键
    lyricCache: Map<string, LyricData> = new Map<string, LyricData>();

    /**
     * 加载歌词
     * @param id 歌曲ID
     * @param from 歌曲来源
     * @returns 歌词数据对象
     */
    public async getLyric(id: string, from: MusicFrom): Promise<{
        lyricData: LyricData,
        error: string
    }> {
        // 检查缓存
        const cacheKey = `${from}-${id}`;
        if (this.lyricCache.has(cacheKey)) {
            return {
                lyricData: this.lyricCache.get(cacheKey),
                error: ''
            };
        }

        // 缓存未命中，从网络加载
        try {
            const lrcText = await this.httpUtils.getMusicLyric(id, from);

            if (lrcText) {
                const lyricData = LyricParserUtil.parse(lrcText);

                if (lyricData.lines.length > 0) {
                    // 保存到缓存
                    this.lyricCache.set(cacheKey, lyricData);

                    return { lyricData: lyricData, error: '' };
                } else {
                    return { lyricData: new LyricData(), error: '暂无歌词' };
                }

            } else {
                return { lyricData: new LyricData(), error: '暂无歌词' };
            }
        } catch (err) {
            console.error(TAG, `加载歌词失败: ${err}`);
            return { lyricData: new LyricData(), error: `加载歌词失败: ${err}` };
        }
    }

    /**
     * 清除指定歌词缓存
     */
    public clearLyricCache(id: string, from: MusicFrom): void {
        const cacheKey = `${from}-${id}`;
        if (this.lyricCache.has(cacheKey)) {
            this.lyricCache.delete(cacheKey);
        }
    }

    /**
     * 清除所有歌词缓存
     */
    public clearAllLyricCache(): void {
        this.lyricCache.clear();
    }

    /**
     * 销毁资源
     */
    public destroy(): void {
        this.httpUtils.destroy();
    }
}

export const lyricViewModel = new LyricViewModel();