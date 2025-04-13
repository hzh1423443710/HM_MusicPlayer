import image from '@ohos.multimedia.image';
import common from '@ohos.app.ability.common';
import resourceManager from '@ohos.resourceManager';

const TAG = 'MediaTools';

export class MediaTools {
    static async getPixelMapFromResource(context: common.UIAbilityContext, name: resourceManager.Resource): Promise<PixelMap> {
        let resourceMgr = context.resourceManager;
        let fileData = await resourceMgr.getMediaContent(name);
        return await image.createImageSource(fileData.buffer).createPixelMap();
    }

    static async getPixelMapFromFile(id: string, path: string): Promise<image.PixelMap> {
        console.info(TAG, 'getPixelMapFromFile id:' + id + ', path:' + path);
        return await image.createImageSource(path).createPixelMap();
    }

    /**
     * 日期不足两位补 0
     *
     * @param {string} value - 数据值
     * @return {string} - 日期不足两位补 0
     */
    private static fill(value: number): string {
        return (value.toString().padStart(2, '0'));
    }

    /**
     * 毫秒 转 倒计时风格 00:00
     * @param ms
     * @returns
     */
    static msToCountdownTime(ms: number): string {
        if (!ms) {
            return '00:00';
        }
        const days = Math.floor(ms / (1000 * 60 * 60 * 24));
        const hours = Math.floor((ms % (1000 * 60 * 60 * 24)) / (1000 * 60 * 60));
        const minutes = Math.floor((ms % (1000 * 60 * 60)) / (1000 * 60));
        const seconds = Math.floor((ms % (1000 * 60)) / 1000);
        return `${(days ? MediaTools.fill(days) + ':' : '')}${(hours ? MediaTools.fill(hours) + ':' : '')}
      ${MediaTools.fill(minutes)}:${MediaTools.fill(seconds)} `.trim();
    }
}