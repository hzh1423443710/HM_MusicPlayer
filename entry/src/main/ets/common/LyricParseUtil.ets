const TAG: string = 'LyricParserUtil';

/**
 * 歌词行
 */
export class LyricLine {
    // 时间戳（毫秒）
    time: number = 0;
    // 歌词文本
    text: string = '';

    constructor(time: number, text: string) {
        this.time = time;
        this.text = text;
    }
}

/**
 * 歌词数据
 */
export class LyricData {
    // 歌词行列表
    lines: LyricLine[] = [];

    /**
     * 根据当前播放时间获取当前应显示的歌词行索引
     * @param currentTime 当前播放时间（毫秒）
     */
    getCurrentIndex(currentTime: number): number {
        // 空歌词处理
        if (this.lines.length === 0) return -1;

        // 如果播放时间小于第一行时间，返回第一行
        if (currentTime < this.lines[0].time) return 0;

        // 查找当前时间所处的行
        for (let i = 0; i < this.lines.length - 1; i++) {
            if (currentTime >= this.lines[i].time && currentTime < this.lines[i + 1].time) {
                return i;
            }
        }

        // 如果已经播放到最后一行之后，返回最后一行
        return this.lines.length - 1;
    }

    /**
     * 检查是否是元数据行
     * @param time 时间（毫秒）
     * @param text 文本内容
     */
    private isMetadata(time: number, text: string): boolean {
        // 通常元数据在歌词开头，时间戳较小，且包含冒号分隔的键值对
        return time < 15000 && text.includes(':');
    }
}

/**
 * LRC歌词解析器
 */
export class LyricParserUtil {
    /**
     * 解析LRC格式歌词
     * @param lrcText LRC格式歌词文本
     * @returns 解析后的歌词数据
     */
    static parse(lrcText: string): LyricData {
        if (!lrcText) {
            console.warn(TAG, '歌词文本为空');
            return new LyricData();
        }

        const result = new LyricData();
        const lines = lrcText.split('\n');

        // 解析每一行
        for (const line of lines) {
            if (!line.trim()) continue;

            // 匹配时间标签 [mm:ss.xx]
            const timeRegex = /\[(\d{2}):(\d{2})\.(\d{2,3})\]/g;
            let match;
            let lineText = line;
            const timeTags: {
                time: number,
                tag: string
            }[] = [];
            // 提取所有时间标签
            while ((match = timeRegex.exec(line)) !== null) {
                const minutes = parseInt(match[1]);
                const seconds = parseInt(match[2]);
                // 处理毫秒，支持2位或3位
                let milliseconds = parseInt(match[3]);
                if (match[3].length === 2) {
                    milliseconds *= 10; // 两位数需要乘以10
                }

                const time = minutes * 60 * 1000 + seconds * 1000 + milliseconds;
                timeTags.push({ time: time, tag: match[0] });
            }

            // 移除所有时间标签，获取纯文本
            for (const tag of timeTags) {
                lineText = lineText.replace(tag.tag, '');
            }
            lineText = lineText.trim();

            // 处理每个时间标签
            for (const tag of timeTags) {
                result.lines.push(new LyricLine(tag.time, lineText));
            }
        }

        // 按时间排序
        result.lines.sort((a, b) => a.time - b.time);

        // 去除可能的重复行
        const uniqueLines: LyricLine[] = [];
        const seen = new Set<string>();

        for (const line of result.lines) {
            // 使用时间和文本组合作为唯一键
            const key = `${line.time}_${line.text}`;
            if (!seen.has(key)) {
                seen.add(key);
                uniqueLines.push(line);
            }
        }

        result.lines = uniqueLines;

        // QQ音乐歌词
        if (lines[0].indexOf('-') !== -1) {
            result.lines.shift();
        }

        return result;
    }
}