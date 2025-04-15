import http from '@ohos.net.http';
import hilog from '@ohos.hilog';
import { MusicFrom, MusicInfo } from '../../model/MusicData';
import ConnectionUtil from './ConnectionUtils'
import { SingerInfo } from '../../model/SingerData';
import { QQMusicQuality } from '../constants/QQMusic';
import { NetEaseAPI, NetEasePlaylistId, NetEaseQuality } from '../constants/NetEaseAPI';

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

    /****************************************** 网易云音乐API ******************************************/

    /**
     * 随机获取一首网易云音乐
     * @param url
     * @returns
     */
    async getRandMusic(): Promise<MusicInfo> {
        if (!await this.netAvailable()) {
            hilog.error(0x0000, TAG, `${this.getRandMusic.name}: 网络不可用`)
            return null;
        }

        let music_info = new MusicInfo();
        let api_url = NetEaseAPI.RAND_SONG;

        await this.httpReq.request(api_url).then((data: http.HttpResponse) => {
            let resultObj = JSON.parse(data.result as string);

            if (data.responseCode === 200 && resultObj.code === 200) {
                music_info.id = resultObj.data.id;
                music_info.name = resultObj.data.song;
                music_info.singer = resultObj.data.singer;
                music_info.url = resultObj.data.Music;
                music_info.pic = resultObj.data.cover;
                music_info.lrc = resultObj.data.lrc || '';
                music_info.pay = false;
                music_info.where = MusicFrom.NetEase;

            } else {
                hilog.error(0x0000, TAG, `${this.getRandMusic.name}: ${data.responseCode}`);
            }
        }).catch((err) => {
            hilog.error(0x0000, TAG, `${this.getRandMusic.name}: ${err}`);
        })

        return music_info;
    }

    /**
     * 获取歌单所有歌曲
     * @param id
     * @returns
     */
    async getNetEaseListSongs(id: NetEasePlaylistId): Promise<MusicInfo[]> {
        if (!await this.netAvailable()) {
            hilog.error(0x0000, TAG, `${this.getNetEaseListSongs.name}: 网络不可用`)
            return null;
        }

        let api_url = NetEaseAPI.PLAYLIST_ALL;
        api_url += `?id=${id}`;

        const songs: MusicInfo[] = [];

        await this.httpReq.request(api_url).then((data: http.HttpResponse) => {
            let resultObj = JSON.parse(data.result as string);

            if (data.responseCode == 200 && resultObj.code == 200) {
                resultObj.songs.forEach((item) => {
                    let song = new MusicInfo();
                    song.id = item.id;
                    song.name = item.name;
                    item.ar.forEach((singer, index) => {
                        if (index > 0)
                            song.singer += '/' + singer.name;
                        else
                            song.singer += singer.name;
                    });
                    // 某些VIP歌曲不能试听
                    song.url = `http://music.163.com/song/media/outer/url?id=${item.id}`
                    song.pic = item.al.picUrl;
                    song.lrc = '';
                    song.pay = false;
                    song.where = MusicFrom.NetEase;
                    songs.push(song);
                });

            } else {
                hilog.error(0x0000, TAG, `${this.getNetEaseListSongs.name}: ${data.responseCode} ${resultObj.code}`)
            }
        }).catch((e) => {
            hilog.error(0x0000, TAG, `${this.getNetEaseListSongs.name}: ${e}`);
        });

        return songs;
    }

    /**
     * 获取网易云播放链接
     * @returns 失败返回null
     */
    async getNetEaseMusic(id: string, quality: NetEaseQuality = NetEaseQuality.SQ): Promise<MusicInfo> {
        if (!await this.netAvailable()) {
            hilog.error(0x0000, TAG, `${this.getNetEaseMusic.name}: 网络不可用`);
            return null;
        }

        let song = new MusicInfo();
        let api_url = NetEaseAPI.SEARCH_OR_PLAY_URL;
        api_url += `?id=${id}&quality=${quality}`;

        await this.httpReq.request(api_url).then((data: http.HttpResponse) => {
            let resultObj = JSON.parse(data.result as string);

            if (data.responseCode === 200 && resultObj.code === 200) {
                song.id = resultObj.data.id;
                song.name = resultObj.data.song;
                song.singer = resultObj.data.singer;
                song.url = resultObj.data.url;
                song.pic = resultObj.data.cover;
                song.lrc = resultObj.data.lrc || '';
                song.pay = false;
                song.where = MusicFrom.NetEase;

            } else {
                hilog.error(0x0000, TAG, `${this.getNetEaseMusic.name}: ${data.responseCode} ${resultObj["code"]}`);
                song = null;
            }
        }).catch((err) => {
            hilog.error(0x0000, TAG, `${this.getNetEaseMusic.name}: ${err}`);
        })

        return song;
    }

    /**
     * 网易云 歌曲搜素
     * @param keyword 查询信息
     * @param page 第一页(每页最多10首)
     * @returns 搜索到的歌曲数组
     */
    public async getSongsByNetEase(keyword: string, page: number = 1): Promise<MusicInfo[]> {
        if (!await this.netAvailable()) {
            hilog.error(0x0000, TAG, `${this.getSongsByNetEase.name}: 网络不可用`)
            return null;
        }

        let api_url = NetEaseAPI.SEARCH_OR_PLAY_URL;
        api_url += `?word=${encodeURIComponent(keyword)}&page=${page}`;

        let musics: MusicInfo[] = [];

        try {
            await this.httpReq.request(api_url)
                .then((data: http.HttpResponse) => {
                    if (data.responseCode !== 200) {
                        hilog.error(0x0000, TAG, `${this.getSongsByNetEase.name}: HTTP错误 ${data.responseCode}`);
                        return;
                    }

                    // 解析JSON响应
                    let resultObj = JSON.parse(data.result as string);

                    if (resultObj.code === 200 && resultObj.data && Array.isArray(resultObj.data)) {
                        // 遍历搜索结果
                        resultObj.data.forEach((item) => {
                            let music = new MusicInfo();
                            music.id = item.id;
                            music.name = item.song;
                            music.singer = item.singer;
                            music.pic = item.cover;
                            music.where = MusicFrom.NetEase;
                            music.pay = false;
                            music.lrc = '';
                            music.url = `http://music.163.com/song/media/outer/url?id=${item.id}`;

                            musics.push(music);
                        });

                        hilog.info(0x0000, TAG, `${this.getSongsByNetEase.name}: 成功获取搜索结果 ${musics.length} 条`);
                    } else {
                        hilog.error(0x0000, TAG, `${this.getSongsByNetEase.name}: API错误 ${resultObj.code}`);
                    }
                })
                .catch((err) => {
                    hilog.error(0x0000, TAG, `${this.getSongsByNetEase.name}: ${err}`);
                });

            return musics;
        } catch (error) {
            hilog.error(0x0000, TAG, `${this.getSongsByNetEase.name} 异常: ${error}`);
            return null;
        }
    }

    /**
     * 获取 网易云音乐 歌词
     * @param id 网易云音乐id
     * @returns 字符串形式的lrc歌词
     */
    public async getNetEaseLyric(id: string): Promise<string> {
        if (!await this.netAvailable()) {
            hilog.error(0x0000, TAG, `${this.getNetEaseLyric.name}: 网络不可用`)
            return null;
        }

        let api_url = "https://api.vkeys.cn/v2/music/netease/lyric";
        api_url += `?id=${id}`;

        let lrcText = null;

        try {
            await this.httpReq.request(api_url).then((data: http.HttpResponse) => {
                if (data.responseCode !== 200) {
                    hilog.error(0x0000, TAG, `${this.getNetEaseLyric.name}: HTTP错误 ${data.responseCode}`);
                    return;
                }

                // 解析JSON响应
                let resultObj = JSON.parse(data.result as string);

                if (resultObj.code === 200 && resultObj.data && resultObj.data.lrc)
                    lrcText = resultObj.data.lrc;
                else
                    hilog.error(0x0000, TAG, `${this.getNetEaseLyric.name}: API错误 ${resultObj.code}`);

            }).catch((err) => {
                hilog.error(0x0000, TAG, `${this.getNetEaseLyric.name}: ${err}`);
            });

            return lrcText;
        } catch (error) {
            hilog.error(0x0000, TAG, `${this.getNetEaseLyric.name} 异常: ${error}`);
            return null;
        }
    }

    /****************************************** QQ音乐API ******************************************/

    /**
     * QQ 歌曲搜素
     * @param keyword 查询信息
     * @param page 第一页(每页最多10首)
     * @returns 搜索到的歌曲数组
     */
    public async getSongsByQQ(keyword: string, page: number = 1): Promise<MusicInfo[]> {
        if (!await this.netAvailable()) {
            hilog.error(0x0000, TAG, `${this.getSongsByQQ.name}: 网络不可用`)
            return null;
        }

        let api_url = "https://api.vkeys.cn/v2/music/tencent";

        api_url += `?word=${encodeURIComponent(keyword)}&page=${page}`;

        let musics: MusicInfo[] = [];

        try {
            await this.httpReq.request(api_url).then((data: http.HttpResponse) => {
                if (data.responseCode !== 200) {
                    hilog.error(0x0000, TAG, `${this.getSongsByQQ.name}: HTTP错误 ${data.responseCode}`);
                    return;
                }

                // 解析JSON响应
                let resultObj = JSON.parse(data.result as string);

                if (resultObj.code === 200 && resultObj.data && Array.isArray(resultObj.data)) {
                    // 遍历搜索结果
                    resultObj.data.forEach((item, index) => {
                        let music = new MusicInfo();
                        music.id = item.id;
                        music.name = item.song;
                        music.singer = item.singer;
                        music.pic = item.cover;
                        music.where = MusicFrom.QQ;
                        music.pay = (item.pay === "付费");
                        music.lrc = '';

                        musics.push(music);
                    });

                    hilog.info(0x0000, TAG, `${this.getSongsByQQ.name}: 成功获取搜索结果 ${musics.length} 条`);
                } else {
                    hilog.error(0x0000, TAG, `${this.getSongsByQQ.name}: API错误 ${resultObj.code}`);
                }
            }).catch((err) => {
                hilog.error(0x0000, TAG, `${this.getSongsByQQ.name}: ${err}`);
            });

            return musics;
        } catch (error) {
            hilog.error(0x0000, TAG, `${this.getSongsByQQ.name} 异常: ${error}`);
            return null;
        }
    }

    /**
     * QQ音乐 歌手搜索
     * @param inputText
     * @param page
     * @returns
     */
    public async getSingersByQQ(keyword: string, page: number = 1): Promise<SingerInfo[]> {
        if (!await this.netAvailable()) {
            hilog.error(0x0000, TAG, `${this.getSingersByQQ.name}: 网络不可用`)
            return null;
        }

        let api_url = "https://api.vkeys.cn/v2/music/tencent/search/singer";
        api_url += `?word=${encodeURIComponent(keyword)}&page=${page}`;

        let singers: SingerInfo[] = [];

        try {
            await this.httpReq.request(api_url).then((data: http.HttpResponse) => {
                if (data.responseCode !== 200) {
                    hilog.error(0x0000, TAG, `${this.getSingersByQQ.name}: HTTP错误 ${data.responseCode}`);
                    return;
                }

                // 解析JSON响应
                let resultObj = JSON.parse(data.result as string);

                if (resultObj.code === 200 && resultObj.data && Array.isArray(resultObj.data)) {
                    // 遍历搜索结果
                    resultObj.data.forEach((item) => {
                        let singer = new SingerInfo();
                        singer.id = item.singerID;
                        singer.name = item.singerName;
                        singer.pic = item.singerPic;
                        singer.songNum = item.songNum;

                        singers.push(singer);
                    });

                    hilog.info(0x0000, TAG, `${this.getSingersByQQ.name}: 成功获取搜索结果 ${singers.length} 条`);
                } else {
                    hilog.error(0x0000, TAG, `${this.getSingersByQQ.name}: API错误 ${resultObj.code}`);
                }
            }).catch((err) => {
                hilog.error(0x0000, TAG, `${this.getSingersByQQ.name}: ${err}`);
            });

            return singers;
        } catch (error) {
            hilog.error(0x0000, TAG, `${this.getSingersByQQ.name} 异常: ${error}`);
            return null;
        }
    }


    /**
     * QQ音乐 点歌
     * @returns
     */
    async getQQMusic(id: string, quality: QQMusicQuality = QQMusicQuality.HQ): Promise<MusicInfo> {
        if (!await this.netAvailable()) {
            hilog.error(0x0000, TAG, `${this.getQQMusic.name}: 网络不可用`);
            return null;
        }

        let music_info = new MusicInfo();
        let api_url = "https://api.vkeys.cn/v2/music/tencent";
        api_url += `?id=${id}&quality=${quality}`;

        await this.httpReq.request(api_url).then((data: http.HttpResponse) => {
            let resultObj = JSON.parse(data.result as string);

            if (data.responseCode === 200 && resultObj["code"] === 200) {
                resultObj.data.forEach((item) => {
                    music_info.id = item.id;
                    music_info.name = item.song;
                    music_info.singer = item.singer;
                    music_info.url = item.url;
                    music_info.pic = item.cover;
                    music_info.lrc = item.lrc || '';
                    music_info.pay = item.pay === '付费';
                    music_info.where = MusicFrom.QQ;
                });

            } else {
                hilog.error(0x0000, TAG, `${this.getQQMusic.name}: ${data.responseCode} ${resultObj["code"]}`);
            }
        }).catch((err) => {
            hilog.error(0x0000, TAG, `${this.getQQMusic.name}: ${err}`);
        })

        return music_info;
    }
}