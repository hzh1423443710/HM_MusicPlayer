import http from '@ohos.net.http';
import { MusicFrom, MusicInfo } from '../../model/MusicData';
import ConnectionUtil from './ConnectionUtils'
import { SingerInfo } from '../../model/SingerData';
import { QQMusicQuality } from '../constants/QQMusicAPI';
import { NetEaseAPI, NetEasePlaylistId, NetEaseQuality } from '../constants/NetEaseAPI';
import { globalUser } from '../../viewmodel/UserViewModel'
import File from '@system.file';

const TAG: string = 'HttpUtils';

export const BACK_END_HOST = "119.3.185.203:5000";

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
        if (!await this.netAvailable()) return null;
        let api_url = NetEaseAPI.RAND_SONG;
        let music_info = new MusicInfo();

        await this.httpReq.request(api_url)
            .then((data: http.HttpResponse) => {
                // 每2秒最多4次 携带Token可无视限制
                let resultObj = JSON.parse(data.result as string);
                if (data.responseCode === 200 && resultObj.code === 200) {
                    music_info.id = resultObj.data.id;
                    music_info.name = resultObj.data.song;
                    music_info.singer = resultObj.data.singer;
                    music_info.url = resultObj.data.Music;
                    music_info.pic = resultObj.data.cover;
                    music_info.pay = false;
                    music_info.where = MusicFrom.NetEase;

                    console.log(TAG, `${this.getRandMusic.name} ${api_url}`);
                } else {
                    console.error(TAG, `${data.responseCode} ${resultObj.code} ${this.getRandMusic.name} ${api_url}`);
                }
            })
            .catch(err => {
                console.error(TAG, this.getRandMusic.name, err.message);
            });

        return music_info;
    }

    /** TODO
     * 获取网易云账号下的自建歌单
     * @param uid 网易云id
     */
    async getNetEasePlaylists(uid: string) {
        if (!await this.netAvailable()) return null;
        let api_url = NetEaseAPI.USER_PLAYLISTS;
        api_url += `?uid=${uid}`;

        let playlist: {
            name: string,
            id: string
        }[] = [];

        await this.httpReq.request(api_url)
            .then((data: http.HttpResponse) => {
                let resultObj = JSON.parse(data.result as string);

                if (data.responseCode == 200 && resultObj.code == 200) {
                    resultObj.playlist.forEach(item => {
                        playlist.push({ name: item.name, id: item.id });
                        console.log(`${item.name} ${item.id}`)
                    });

                    console.log(TAG, `${this.getNetEasePlaylists.name} ${api_url}`);
                } else {
                    console.error(TAG, `${data.responseCode} ${resultObj.code} ${this.getNetEasePlaylists.name} ${api_url}`);
                }
            })
            .catch(err => {
                console.error(TAG, this.getNetEasePlaylists.name, err.message);
            });

        return playlist;
    }

    /**
     * 获取歌单所有歌曲
     * @param id
     * @returns
     */
    async getNetEaseListSongs(id: NetEasePlaylistId | string): Promise<MusicInfo[]> {
        if (!await this.netAvailable()) return null;
        let api_url = NetEaseAPI.PLAYLIST_ALL;
        api_url += `?id=${id}`;

        const songs: MusicInfo[] = [];

        await this.httpReq.request(api_url)
            .then((data: http.HttpResponse) => {
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
                        song.url = null;
                        song.pic = item.al.picUrl;
                        song.pay = false;
                        song.where = MusicFrom.NetEase;
                        songs.push(song);
                    });

                    console.log(TAG, `${this.getNetEaseListSongs.name} ${api_url}`);
                } else {
                    console.error(TAG, `${data.responseCode} ${resultObj.code} ${this.getNetEaseListSongs.name} ${api_url}`);
                }
            })
            .catch(err => {
                console.error(TAG, this.getNetEaseListSongs.name, err.message);
            });

        return songs;
    }

    /**
     * 获取网易云播放链接
     * @returns 失败返回null
     */
    async getNetEaseMusic(id: string, quality: NetEaseQuality = NetEaseQuality.SQ): Promise<MusicInfo> {
        if (!await this.netAvailable()) return null;
        let api_url = NetEaseAPI.SEARCH_OR_PLAY_URL;
        api_url += `?id=${id}&quality=${quality}`;

        let song: MusicInfo = null;

        await this.httpReq.request(api_url)
            .then((data: http.HttpResponse) => {
                let resultObj = JSON.parse(data.result as string);

                if (data.responseCode === 200 && resultObj.code === 200) {
                    song = new MusicInfo();
                    song.id = resultObj.data.id;
                    song.name = resultObj.data.song;
                    song.singer = resultObj.data.singer;
                    song.url = resultObj.data.url;
                    song.pic = resultObj.data.cover;
                    song.pay = false;
                    song.where = MusicFrom.NetEase;

                    console.log(TAG, `${this.getNetEaseMusic.name} ${api_url}`);
                } else {
                    console.error(TAG, `${data.responseCode} ${resultObj.code} ${this.getNetEaseMusic.name} ${api_url}`);
                }
            })
            .catch(err => {
                console.error(TAG, this.getNetEaseMusic.name, err.message);
            });

        return song;
    }

    /**
     * 网易云 歌曲搜素
     * @param keyword 查询信息
     * @param page 每页10首
     * @returns 搜索到的歌曲数组
     */
    public async getSongsByNetEase(keyword: string, page: number = 1): Promise<MusicInfo[]> {
        if (!await this.netAvailable()) return null;
        const limit = 10;
        const offset: number = (page - 1) * limit + 1;

        let api_url = NetEaseAPI.SEARCH_OR_PLAY_URL;
        api_url += `?word=${encodeURIComponent(keyword)}&page=${offset}`;

        let musics: MusicInfo[] = [];

        await this.httpReq.request(api_url)
            .then((data: http.HttpResponse) => {
                let resultObj = JSON.parse(data.result as string);
                if (data.responseCode === 200 && resultObj.code === 200) {
                    resultObj.data.forEach((item) => {
                        let song = new MusicInfo();
                        song.id = item.id;
                        song.name = item.song;
                        song.singer = item.singer;
                        song.pic = item.cover;
                        song.where = MusicFrom.NetEase;
                        song.pay = false;
                        song.url = `http://music.163.com/song/media/outer/url?id=${item.id}`;

                        musics.push(song);
                    });

                    console.log(TAG, `${this.getSongsByNetEase.name} ${api_url}`);
                } else {
                    console.error(TAG, `${resultObj.code} ${this.getSongsByNetEase.name} ${api_url}`);
                }
            })
            .catch(err => {
                console.error(TAG, this.getSongsByNetEase.name, err.message);
            });

        return musics;
    }

    /**
     * 网易云音乐 歌手搜索
     * @param inputText
     * @param page
     * @returns
     */
    public async getSingersByNetEase(keyword: string, page: number = 1): Promise<SingerInfo[]> {
        if (!await this.netAvailable()) return null;
        const limit = 10;
        const offset = (page - 1) * limit;

        let api_url = NetEaseAPI.SEARCH;
        api_url += `?keywords=${encodeURIComponent(keyword)}&type=100&limit=${limit}&offset=${offset}`;

        let singers: SingerInfo[] = [];

        await this.httpReq.request(api_url)
            .then((data: http.HttpResponse) => {
                let resultObj = JSON.parse(data.result as string);
                if (data.responseCode === 200 && resultObj.code === 200) {
                    resultObj.result.artists.forEach((item) => {
                        let singer = new SingerInfo();
                        singer.id = item.id;
                        singer.name = item.name;
                        singer.pic = item.picUrl;
                        singer.songNum = null;

                        singers.push(singer);
                    });

                    console.log(TAG, `${this.getSingersByNetEase.name} ${api_url}`);
                } else {
                    console.error(TAG, `${resultObj.code} ${this.getSingersByNetEase.name} ${api_url}`);
                }
            })
            .catch(err => {
                console.error(TAG, this.getSingersByNetEase.name, err.message);
            });

        return singers;
    }

    /** TODO
     * 获取歌手所有歌曲
     * @param id 歌手id
     */
    public async getSingerSongsByNetEase(id: string, page: number = 1): Promise<MusicInfo[]> {
        if (!await this.netAvailable()) return null;
        const limit = 10;
        const offset = (page - 1) * limit;

        let api_url = NetEaseAPI.SINGER_SONGS;
        api_url += `?id=${id}&order=hot&limit=${limit}&offset=${offset}`;

        let songs: MusicInfo[] = [];

        await this.httpReq.request(api_url)
            .then((data: http.HttpResponse) => {
                let resultObj = JSON.parse(data.result as string);
                if (data.responseCode === 200 && resultObj.code === 200) {
                    resultObj.songs.forEach((item) => {
                        let music = new MusicInfo();
                        music.id = item.id;
                        music.name = item.name;
                        music.pic = null; // 无该字段
                        music.url = `http://music.163.com/song/media/outer/url?id=${item.id}`;

                        songs.push(music);
                    });

                    console.log(TAG, `${this.getSingerSongsByNetEase.name} ${api_url}`);
                } else {
                    console.error(TAG, `${resultObj.code} ${this.getSingerSongsByNetEase.name} ${api_url}`);
                }
            })
            .catch(err => {
                console.error(TAG, this.getSingerSongsByNetEase.name, err.message);
            });

        return songs;
    }

    /**
     * 获取 网易云音乐、QQ音乐 歌词
     * @param id 网易云音乐id
     * @returns 字符串形式的lrc歌词
     */
    public async getMusicLyric(id: string, where: MusicFrom): Promise<string> {
        if (!await this.netAvailable()) return null;

        let api_url = `https://api.vkeys.cn/v2/music/netease/lyric?id=${id}`;
        if (where === MusicFrom.QQ)
            api_url = `https://api.vkeys.cn/v2/music/tencent/lyric?id=${id}`;

        let lrcText: string = null;

        await this.httpReq.request(api_url)
            .then((data: http.HttpResponse) => {
                let resultObj = JSON.parse(data.result as string);
                if (data.responseCode === 200 && resultObj.code === 200 && resultObj.data && resultObj.data.lrc) {
                    lrcText = resultObj.data.lrc;
                    console.log(TAG, `${this.getMusicLyric.name} ${api_url}`);
                }
                else
                    console.log(TAG, `${resultObj.code} ${this.getMusicLyric.name} ${api_url}`);

            })
            .catch(err => {
                console.error(TAG, this.getMusicLyric.name, err.message);
            });

        return lrcText;
    }

    /****************************************** QQ音乐API ******************************************/

    /**
     * QQ 歌曲搜素
     * @param keyword 查询信息
     * @param page 第一页(每页最多10首)
     * @returns 搜索到的歌曲数组
     */
    public async getSongsByQQ(keyword: string, page: number = 1): Promise<MusicInfo[]> {
        if (!await this.netAvailable()) return null;

        let api_url = `https://api.vkeys.cn/v2/music/tencent?word=${encodeURIComponent(keyword)}&page=${page}`;
        let musics: MusicInfo[] = [];

        await this.httpReq.request(api_url)
            .then((data: http.HttpResponse) => {
                let resultObj = JSON.parse(data.result as string);
                if (data.responseCode === 200 && resultObj.code === 200) {
                    resultObj.data.forEach(item => {
                        let music = new MusicInfo();
                        music.id = item.id;
                        music.name = item.song;
                        music.singer = item.singer;
                        music.pic = item.cover;
                        music.where = MusicFrom.QQ;
                        music.pay = (item.quality === "音乐试听");

                        musics.push(music);
                    });

                    console.log(TAG, `${this.getSongsByQQ.name} ${api_url}`);
                } else {
                    console.error(TAG, `${resultObj.code} ${this.getSongsByQQ.name} ${api_url}`);
                }
            })
            .catch(err => {
                console.error(TAG, this.getSongsByQQ.name, err.message);
            });

        return musics;
    }

    /**
     * QQ音乐 歌手搜索
     * @param inputText
     * @param page
     * @returns
     */
    public async getSingersByQQ(keyword: string, page: number = 1): Promise<SingerInfo[]> {
        if (!await this.netAvailable()) return null;

        let api_url = `https://api.vkeys.cn/v2/music/tencent/search/singer?word=${encodeURIComponent(keyword)}&page=${page}`;
        let singers: SingerInfo[] = [];

        await this.httpReq.request(api_url)
            .then((data: http.HttpResponse) => {
                let resultObj = JSON.parse(data.result as string);
                if (data.responseCode === 200 && resultObj.code === 200) {
                    resultObj.data.forEach((item) => {
                        let singer = new SingerInfo();
                        singer.id = item.singerMID;
                        singer.name = item.singerName;
                        singer.pic = item.singerPic;
                        singer.songNum = item.songNum;

                        singers.push(singer);
                    });

                    console.log(TAG, `${this.getSingersByQQ.name} ${api_url}`);
                } else {
                    console.error(TAG, `${resultObj.code} ${this.getSingersByQQ.name} ${api_url}`);
                }
            })
            .catch(err => {
                console.error(TAG, this.getSingersByQQ.name, err.message);
            });

        return singers;
    }

    /**
     * QQ音乐 点歌
     * @returns
     */
    async getQQMusic(id: string, quality: QQMusicQuality = QQMusicQuality.HQ): Promise<MusicInfo> {
        if (!await this.netAvailable()) return null;

        let music_info = new MusicInfo();
        let api_url = `https://api.vkeys.cn/v2/music/tencent?id=${id}&quality=${quality}`;

        await this.httpReq.request(api_url)
            .then((data: http.HttpResponse) => {
                let resultObj = JSON.parse(data.result as string);
                if (data.responseCode === 200 && resultObj.code === 200) {
                    music_info.id = resultObj.data.id;
                    music_info.name = resultObj.data.song;
                    music_info.singer = resultObj.data.singer;
                    music_info.url = resultObj.data.url;
                    music_info.pic = resultObj.data.cover;
                    music_info.pay = resultObj.data.quality === '音乐试听';
                    music_info.where = MusicFrom.QQ;

                    console.log(TAG, `${this.getQQMusic.name} ${api_url}`);
                } else {
                    console.error(TAG, `${data.responseCode} ${resultObj.code} ${this.getQQMusic.name} ${api_url}`);
                }
            })
            .catch(err => {
                console.error(TAG, this.getQQMusic.name, err.message);
            })

        return music_info;
    }

    /**
     * QQ音乐 歌手歌曲搜索
     * @param id 歌手mid
     * @param page
     * @returns
     */
    public async getSingerSongsByQQ(id: string, page: number = 1): Promise<MusicInfo[]> {
        if (!await this.netAvailable()) return null;
        let api_url = `https://api.vkeys.cn/v2/music/tencent/singer/songlist?mid=${id}&page=${page}`;
        let songs: MusicInfo[] = [];

        await this.httpReq.request(api_url)
            .then((data: http.HttpResponse) => {
                let resultObj = JSON.parse(data.result as string);
                if (data.responseCode === 200 && resultObj.code === 200) {
                    resultObj.data.forEach(item => {
                        let music = new MusicInfo();
                        music.id = item.id;
                        music.name = item.song;
                        music.pic = item.cover;
                        music.url = null;
                        music.pay = item.quality === '音乐试听';

                        songs.push(music);
                    });

                    console.log(TAG, `${this.getSingerSongsByQQ.name} ${api_url}`);
                } else {
                    console.error(TAG, `${resultObj.code} ${this.getSingerSongsByQQ.name} ${api_url}`);
                }
            })
            .catch(err => {
                console.error(TAG, this.getSingerSongsByQQ.name, err.message);
            });

        return songs;
    }

    /** TODO
     * 获取QQ账号歌单
     * @param uin
     */
    public async getQQPlaylists(uin: string) {
        if (!await this.netAvailable()) return null;
        let api_url = `https://api.timelessq.com/music/tencent/cdList?uid=${uin}`;
        // `https://api.vkeys.cn/v2/music/tencent/info?uin=1423443710`

        let playlists: {
            name: string,
            id: string,
            cover?: string
        }[] = [];

        await this.httpReq.request(api_url)
            .then((data: http.HttpResponse) => {
                let resultObj = JSON.parse(data.result as string);
                if (data.responseCode === 200) {
                    resultObj.data.lists.forEach(item => {
                        playlists.push({ name: item.name, id: item.tid, cover: item.cover });
                    });
                } else {
                    console.error(TAG, `${resultObj.code} ${this.getQQPlaylists.name} ${api_url}`);
                }
            })
            .catch(err => {
                console.error(TAG, this.getQQPlaylists.name, err.message);
            });

        return playlists;
    }

    /** TODO
     * 获取QQ音乐 歌单所有歌曲
     * @param id
     * @returns
     */
    async getQQListSongs(id: string): Promise<MusicInfo[]> {
        if (!await this.netAvailable()) return null;
        let api_url = `https://api.vkeys.cn/v2/music/tencent/dissinfo?id=${id}`;

        const songs: MusicInfo[] = [];

        await this.httpReq.request(api_url)
            .then((data: http.HttpResponse) => {
                let resultObj = JSON.parse(data.result as string);
                if (data.responseCode == 200 && resultObj.code == 200) {
                    resultObj.data.list.forEach(item => {
                        let song = new MusicInfo();
                        song.id = item.id;
                        song.name = item.song;
                        item.singer_list.forEach((singer, index) => {
                            if (index > 0)
                                song.singer += '/' + singer.name;
                            else
                                song.singer += singer.name;
                        });
                        song.url = null;
                        song.pic = item.cover;
                        song.pay = item.pay === '付费';
                        song.where = MusicFrom.QQ;
                        songs.push(song);
                    });

                    console.log(TAG, `${this.getQQListSongs.name} ${api_url}`);
                } else {
                    console.error(TAG, `${data.responseCode} ${resultObj.code} ${this.getQQListSongs.name} ${api_url}`);
                }
            })
            .catch(err => {
                console.error(TAG, this.getQQListSongs.name, err.message);
            });

        return songs;
    }

    /****************************************** 后端接口 ******************************************/
    // 获取验证码
    public async getVerifyCode(email: string) {
        if (!await this.netAvailable()) return null;
        let api_url = `${BACK_END_HOST}/user/verify_code`;
        let success = false;

        await this.httpReq.request(api_url, {
            header: {
                'Connection': "close"
            },
            method: http.RequestMethod.POST,
            extraData: {
                "email": email
            },
        }).then((data: http.HttpResponse) => {
            let resultObj = JSON.parse(data.result as string);
            if (data.responseCode === 200 && resultObj.code === 200) {
                console.log(TAG, `${this.getVerifyCode.name} ${api_url}`);
                success = true;
            } else {
                console.error(TAG, `${data.responseCode} ${this.getVerifyCode.name} ${api_url}`);
            }
        }).catch(err => {
            console.error(TAG, this.getVerifyCode.name, api_url, err.message);
        })

        return success;
    }

    // 注册
    public async register(username: string, passwd: string, email: string, verify_code: string) {
        if (!await this.netAvailable()) return null;
        let api_url = `${BACK_END_HOST}/user/register`;
        let success = false;

        await this.httpReq.request(api_url, {
            header: {
                'Connection': "close"
            },
            method: http.RequestMethod.POST,
            extraData: {
                "username": username,
                "password": passwd,
                "email": email,
                "verify_code": verify_code
            },
        }).then((data: http.HttpResponse) => {
            let resultObj = JSON.parse(data.result as string);

            if (data.responseCode === 200 && resultObj.code === 200) {
                console.log(TAG, `${this.register.name} ${api_url}`);
                success = true;
            } else {
                console.error(TAG, `${data.responseCode} ${this.register.name} ${api_url}`);
            }
        }).catch(err => {
            console.error(TAG, this.register.name, api_url, err.message);
        });

        return success;
    }

    // 登录
    public async login(username: string, passwd: string) {
        if (!await this.netAvailable()) return null;
        let api_url = `${BACK_END_HOST}/user/login`;
        let success = false;

        await this.httpReq.request(api_url, {
            header: {
                'Connection': "close"
            },
            method: http.RequestMethod.POST,
            extraData: {
                "username": username,
                "password": passwd
            },
        }).then((data: http.HttpResponse) => {
            let resultObj = JSON.parse(data.result as string);
            let header = JSON.parse(JSON.stringify(data.header));

            if (data.responseCode === 200 && resultObj.code === 200) {
                globalUser.id = resultObj.user.id;
                globalUser.username = resultObj.user.username;
                globalUser.qq_id = resultObj.user.qq_id;
                globalUser.netease_id = resultObj.user.netease_id;
                globalUser.email = resultObj.user.email;
                globalUser.create_at = resultObj.user.create_at;
                globalUser.authorization = header.authorization;

                console.log(TAG, `${this.login.name} ${api_url}`);
                success = true;
            } else {
                console.error(TAG, `${data.responseCode} ${this.login.name} ${api_url} ${resultObj.message}`);
            }
        }).catch(err => {
            console.error(TAG, this.login.name, api_url, err.message);
        })

        return success;
    }

    // 修改密码
    public async modifyPasswd(username: string, email: string, newPasswd: string, verify_code: string) {
        if (!await this.netAvailable()) return null;
        let api_url = `${BACK_END_HOST}/user/password`;
        let success = false;

        await this.httpReq.request(api_url, {
            header: {
                'Connection': "close",
            },
            method: http.RequestMethod.POST,
            extraData: {
                "username": username,
                "new_password": newPasswd,
                "email": email,
                "verify_code": verify_code
            },
        }).then((data: http.HttpResponse) => {
            let resultObj = JSON.parse(data.result as string);
            if (data.responseCode === 200 && resultObj.code === 200) {
                console.log(TAG, `${this.modifyPasswd.name} ${api_url}`);
                success = true;
            } else {
                console.error(TAG, `${data.responseCode} ${this.modifyPasswd.name} ${api_url}`);
            }
        }).catch(err => {
            console.error(TAG, this.modifyPasswd.name, api_url, err.message);
        });

        return success;
    }

    // 绑定平台id
    public async bindPlatform(platform: string, platformId: string) {
        if (!await this.netAvailable()) return null;
        let api_url = `${BACK_END_HOST}/user/platform`;
        let success = false;

        await this.httpReq.request(api_url, {
            header: {
                'Connection': "close",
                'Authorization': globalUser.authorization
            },
            method: http.RequestMethod.POST,
            extraData: {
                "platform": platform,
                "platform_id": platformId
            }
        }).then((data: http.HttpResponse) => {
            let resultObj = JSON.parse(data.result as string);
            if (data.responseCode === 200 && resultObj.code === 200) {
                console.log(TAG, `${this.bindPlatform.name} ${api_url}`);
                if (platform === 'qq')
                    globalUser.qq_id = platformId;
                else
                    globalUser.netease_id = platformId;
                success = true;
            } else {
                console.error(TAG, `${data.responseCode} ${this.bindPlatform.name} ${api_url}`);
            }
        }).catch(err => {
            console.error(TAG, this.bindPlatform.name, api_url, err.message);
        });

        return success;
    }

    // 更新头像 TODO
    public async uploadAvatar(file: File) {
        if (!await this.netAvailable()) return null;
        let api_url = `${BACK_END_HOST}/user/avatar`;
        let success = false;

        await this.httpReq.request(api_url, {
            header: {
                'Connection': "close",
                'Authorization': globalUser.authorization
            },
            method: http.RequestMethod.POST,
            extraData: {
                "avatar": file
            }
        }).then((data: http.HttpResponse) => {
            let resultObj = JSON.parse(data.result as string);
            if (data.responseCode === 200 && resultObj.code === 200) {
                console.log(TAG, `${this.uploadAvatar.name} ${api_url}`);
                success = true;
            } else {
                console.error(TAG, `${data.responseCode} ${this.uploadAvatar.name} ${api_url}`);
            }
        }).catch(err => {
            console.error(TAG, this.uploadAvatar.name, api_url, err.message);
        });

        return success;
    }
}