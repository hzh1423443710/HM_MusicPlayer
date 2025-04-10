import http from '@ohos.net.http';
import hilog from '@ohos.hilog';
import { MusicFrom, MusicInfo } from '../../model/MusicData';
import { NetEaseQuality, NetEasePlayListId } from '../constants/Netease';
import ConnectionUtil from './ConnectionUtils'

const TAG: string = 'HttpUtils';

export class HttpUtils {
    httpReq: http.HttpRequest = null;

    constructor() {
        this.httpReq = http.createHttp();
    }

    destroy() {
        this.httpReq.destroy();
    }

    async netAvailable() {
        return await ConnectionUtil.isNetworkConnected();
    }

    /**
     * 随机获取一首网易云音乐
     * @param url
     * @returns
     */
    async getRandMusic(): Promise<MusicInfo> {
        if (!await this.netAvailable()) {
            hilog.error(0x0000, TAG, 'getRandMusic: 网络不可用')
            return null;
        }

        let music_info = null;
        let api_url = await getContext(this).resourceManager.getStringValue($r("app.string.api_rand_music"));

        await this.httpReq.request(api_url).then((data: http.HttpResponse) => {
            let resultObj = JSON.parse(data.result as string);

            if (data.responseCode === 200 && resultObj["code"] === 200) {
                music_info = new MusicInfo();
                music_info.id = resultObj["data"]["id"];
                music_info.name = resultObj["data"]["song"];
                music_info.singer = resultObj["data"]["singer"];
                music_info.duration = null;
                music_info.url = resultObj["data"]["Music"];
                music_info.pic = resultObj["data"]["cover"];
                music_info.lrc = null;
                music_info.pay = false;
                music_info.where = MusicFrom.NetEase;
            } else {
                hilog.error(0x0000, TAG, `getRandMusic: ${data.responseCode}`);
            }
        }).catch((err) => {
            hilog.error(0x0000, TAG, `getRandMusic: ${err}`);
        })

        return music_info;
    }

    /**
     * 获取 歌单/榜单 音乐 id
     * @param id
     * @returns
     */
    async getNetEaseListId(id: NetEasePlayListId): Promise<string[]> {
        if (!await this.netAvailable()) {
            hilog.error(0x0000, TAG, 'getNetEaseListId: 网络不可用')
            return null;
        }

        let api_url = await getContext(this).resourceManager.getStringValue($r("app.string.api_NetEase_playlist_id"));
        api_url += `?id=${id}`;

        const ret_musicIds: string[] = [];

        await this.httpReq.request(api_url).then((data: http.HttpResponse) => {
            let result = JSON.parse(data.result as string);

            if (data.responseCode == 200 && result.code == 200) {
                // 获取歌曲列表
                const tracks = result.result.tracks;
                // 遍历tracks数组，提取每首歌的ID
                for (const track of tracks) {
                    ret_musicIds.push(track.id);
                }
            } else {
                hilog.error(0x0000, TAG, `getNetEaseListId: ${data.responseCode} ${result.code}`)
            }
        }).catch((e) => {
            hilog.error(0x0000, TAG, `getNetEaseListId: ${e}`);
        });

        return ret_musicIds;
    }


    /**
     * 网易云点歌
     * @returns
     */
    async getNetEaseMusic(id: string, quality: NetEaseQuality = NetEaseQuality.SQ): Promise<MusicInfo> {
        if (!await this.netAvailable()) {
            hilog.error(0x0000, TAG, 'getNetEaseMusic: 网络不可用');
            return null;
        }

        let music_info = null;
        let api_url = await getContext(this).resourceManager.getStringValue($r("app.string.api_netease_music"));
        api_url += `?id=${id}&quality=${quality}`;

        await this.httpReq.request(api_url).then((data: http.HttpResponse) => {
            let resultObj = JSON.parse(data.result as string);

            if (data.responseCode === 200 && resultObj["code"] === 200) {
                music_info = new MusicInfo();
                music_info.id = resultObj["data"]["id"];
                music_info.name = resultObj["data"]["song"];
                music_info.singer = resultObj["data"]["singer"];
                music_info.duration = resultObj["data"]["interval"];
                music_info.url = resultObj["data"]["url"];
                music_info.pic = resultObj["data"]["cover"];
                music_info.lrc = resultObj["data"]["lrc"]; // TODO
                music_info.pay = false;
                music_info.where = MusicFrom.NetEase;
            } else {
                hilog.error(0x0000, TAG, `getRandMusic: ${data.responseCode} ${resultObj["code"]}`);
            }
        }).catch((err) => {
            hilog.error(0x0000, TAG, `getRandMusic: ${err}`);
        })

        return music_info;
    }

    /**
     * 获取网易云热榜
     */
    async getNetEaseTop(type: NetEasePlayListId): Promise<MusicInfo[]> {
        if (!await this.netAvailable()) {
            hilog.error(0x0000, TAG, 'getNetEaseTop: 网络不可用')
            return null;
        }

        let musics: MusicInfo[] = [];
        let api_url = await getContext(this).resourceManager.getStringValue($r("app.string.api_netease_top"));
        api_url += `?t=${type}`;

        await this.httpReq.request(api_url).then((data: http.HttpResponse) => {
            let resultObj = JSON.parse(data.result as string);

            if (data.responseCode === 200 && resultObj["code"] === 200) {
                const arr = resultObj["data"];
                for (const music of arr) {
                    let music_info = new MusicInfo();
                    music_info.id = music.id;
                    music_info.name = music.song;
                    music_info.singer = music.sing;
                    music_info.duration = ''; // 无
                    music_info.url = music.url;
                    music_info.pic = music.pic;
                    music_info.lrc = ''; // 无
                    music_info.pay = false;
                    music_info.where = MusicFrom.NetEase;
                    musics.push(music_info);
                }
            } else {
                hilog.error(0x0000, TAG, `getNetEaseTop: ${data.responseCode}`);
            }
        }).catch((err) => {
            hilog.error(0x0000, TAG, `getNetEaseTop: ${err}`);
        })

        return musics;
    }
}