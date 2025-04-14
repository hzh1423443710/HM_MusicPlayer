import { MusicInfo, PlayListType } from '../model/MusicData'
import { HttpUtils } from '../common/network/HttpUtils'

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
     * @returns
     */
    async getBatchMusic() {
        let musics: MusicInfo[] = [];

        for (let i = 0; i < this.batch; ++i) {
            let music = await this.http.getRandMusic();
            if (music === null) {
                throw new Error('获取随机音乐失败');
            } else {
                musics.push(music);
            }
        }

        return musics;
    }

    destroy() {
        this.http.destroy();
    }
}

export const randPlayViewModel = new RandPlayViewModel();