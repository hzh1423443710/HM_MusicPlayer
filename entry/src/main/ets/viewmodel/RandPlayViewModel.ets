import { HttpUtils } from '../common/network/HttpUtils';
import { MusicInfo, PlayListType } from '../model/MusicData'

@Observed
export class RandPlayViewModel {
    name: string = '随机一曲';
    title: string = '放松吧';
    brief: string = '尝试来点音乐提提神吧';
    batch: number = 5;
    playlistType: PlayListType = PlayListType.NETEASE_RANDOM_SONG;
    private http: HttpUtils = new HttpUtils();

    /**
     * 获取一批 随机一曲音乐
     * @returns Promise<MusicInfo[]>
     */
    async getBatchMusic(): Promise<MusicInfo[]> {
        let musics: MusicInfo[] = [];

        try {
            for (let i = 0; i < this.batch; ++i) {
                let music = await this.http.getRandMusic();
                if (music === null)
                    throw new Error();
                else
                    musics.push(music);
            }

            return musics;
        } catch (error) {
            const isNetworkAvailable = await this.http.netAvailable().catch(() => false);
            if (isNetworkAvailable)
                throw new Error('获取随机音乐失败');
            else
                throw new Error('网络不可用');
        }
    }

    destroy() {
        this.http.destroy();
    }
}

export const randPlayViewModel = new RandPlayViewModel();