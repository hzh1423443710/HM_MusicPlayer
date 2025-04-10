import { MusicFrom, MusicInfo, PlayListType, } from '../model/MusicData'
import { HttpUtils } from '../common/network/HttpUtils'

// const randMusic: MusicInfo = {
//     id: "208902",
//     name: "红色高跟鞋",
//     singer: "蔡健雅",
//     url: "https://api.ilingku.com/int/v1/rand_netease?type=url&id=208902&timestamp=1743934798&auth=86a4dc016e0eb6cb63374a25dc82b66d",
//     pic: "https://p3.music.126.net/XNdKT7m3fHGTbkfSUMP6oQ==/109951170645349505.jpg?param=300y300",
//     duration: "03:26",
//     lrc: "https://api.ilingku.com/int/v1/rand_netease?type=lrc&id=208902&timestamp=1743934798&auth=5ae9e15d7ad2b8e1f1e370b880d4d749",
//     pay: true,
//     where: MusicFrom.netease
// }

@Observed
export class RandPlayViewModel {
    musicInfo: MusicInfo = new MusicInfo();
    name: string = '随机一曲';
    title: string = '放松吧';
    brief: string = '尝试来点音乐提提神吧';
    private http: HttpUtils = new HttpUtils();

    async loadMusic() {
        let music = await this.http.getRandMusic();
        if (music === null) {
            throw new Error('获取随机音乐失败');
        } else {
            this.musicInfo = music;
            this.musicInfo.playList = PlayListType.NETEASE_RAND;
            // TODO 索引
        }
    }

    debugInfo() {
        console.log(`${this.musicInfo}`)
    }

    destroy() {
        this.http.destroy();
    }
}

export const randPlayViewModel = new RandPlayViewModel();