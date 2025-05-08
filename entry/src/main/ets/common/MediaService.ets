import media from '@ohos.multimedia.media'
import common from '@ohos.app.ability.common';
import { enumToString, MusicFrom, MusicInfo, PlaylistType } from '../model/MusicData';
import { MediaTools } from '../common/MediaTools'
import { BackgroundUtil } from '../common/BackgroundUtil'
import { HttpUtils } from './network/HttpUtils';
import promptAction from '@ohos.promptAction';

const TAG = 'MediaService';

/**
 * 播放模式
 */
export enum MusicPlayMode {
    // 单曲循环
    SINGLE_CYCLE = 0,
    // 顺序播放
    ORDER = 1,
    // 随机播放
    RANDOM = 2
}

/**
 * AVPlayer状态
 */
export enum PlayerState {
    IDLE,
    INITIALIZED,
    LOAD,
    PREPARED,
    PLAY,
    PAUSE,
    STOP,
    ERROR,
    COMPLETED,
    RELEASED,
    PROGRESS_SPEED,
    TIME_UPDATE,
    VOLUME_CHANGE,
    UNKNOWN
}

/**
 * 网易云有id 就有外链; QQ有id，得不到外链
 * 网易云/QQ 音乐 统一 播放时再根据id获取其外链
 */
export class MediaService {
    private context: common.UIAbilityContext | undefined = AppStorage.Get('context');
    public avPlayer: media.AVPlayer | null = null;
    private http: HttpUtils = new HttpUtils();
    /**
     * 播放顺序
     */
    private playMode: MusicPlayMode = MusicPlayMode.ORDER;
    /**
     * 是否为prepared状态
     */
    private isPrepared: boolean = false;
    /**
     * 当前音乐-在当前列表索引
     */
    private currentMusicIndex: number = 0;
    /**
     * 当前播放队列
     */
    private currentPlayQueue: MusicInfo[] = [];
    /**
     * 当前播放-列表类型
     */
    private currentPlaylistType = PlaylistType.NONE;
    /**
     * 播放历史 上限
     */
    static readonly PLAY_HISTORY_LIMIT = 500;
    /**
     * 播放列表
     */
    private playlistMap: Map<PlaylistType, MusicInfo[]> = new Map();
    /**
     * seek & timeUpdate 播放进度控制
     */
    private isCurrent: boolean = true;

    constructor() {
        this.initAudioPlayer();
        // 最近播放
        this.playlistMap.set(PlaylistType.RECENT, []);
        // 随机一曲
        this.playlistMap.set(PlaylistType.NETEASE_RANDOM_SONG, []);
    }


    get playQueue(): MusicInfo[] {
        return this.currentPlayQueue;
    }

    get playlistType(): PlaylistType {
        return this.currentPlaylistType;
    }

    getPlaylist(playlistType: PlaylistType) {
        return this.playlistMap.get(playlistType);
    }

    // ================================== 播放状态管理 ==================================
    public setPlayState(state: PlayerState) {
        AppStorage.SetOrCreate('playState', state);
    }

    private getPlayState(): PlayerState {
        return AppStorage.Get<PlayerState>('playState');
    }

    public static getInstance(): MediaService {
        let mediaService: MediaService | undefined = AppStorage.Get('mediaService');
        if (!mediaService) {
            mediaService = new MediaService();
            AppStorage.SetOrCreate('mediaService', mediaService);
        }
        return mediaService;
    }

    /**
     * 通知更新 随机一曲 组件
     */
    private notifyUpdateRandWidget() {
        if (this.playlistType === PlaylistType.NETEASE_RANDOM_SONG) {
            // 更新一组 随机一曲
            if (this.currentMusicIndex === this.currentPlayQueue.length - 2) {
                AppStorage.SetOrCreate('needAppend', Date.now());
            }
        }
    }

    // ================================== debug =================================
    public debugPlayQueue() {
        this.currentPlayQueue.forEach((item, index) => {
            console.log(`播放队列[${index}] ${item}`);
        })
    }

    public debugPlaylist(type: PlaylistType) {
        const playlist = this.playlistMap.get(type);
        if (playlist) {
            playlist.forEach((item, index) => {
                console.log(`播放列表${enumToString(PlaylistType, type)}:[${index}] ${item}`);
            });
        }
    }

    public debugState() {
        console.log(TAG, `播放列表: ${enumToString(PlaylistType, this.playlistType)}, 播放状态:${enumToString(PlayerState, this.getPlayState())}, index[${this.currentMusicIndex}] Music:${this.currentPlayQueue[this.currentMusicIndex]}`);
    }

    // ================================== 播放队列管理 =================================
    /**
     * 获取当前正在播放的音乐信息
     * @returns
     */
    public getCurrentMusic(): MusicInfo {
        if (this.currentPlayQueue.length > 0 && this.currentMusicIndex >= 0 &&
            this.currentMusicIndex < this.currentPlayQueue.length) {
            return this.currentPlayQueue[this.currentMusicIndex];
        }
        return null;
    }

    /**
     * 追加 一组 随机一曲 音乐
     * @param musics
     */
    public appendRandomMusics(musics: MusicInfo[]): MusicInfo {
        const playlist = this.playlistMap.get(PlaylistType.NETEASE_RANDOM_SONG);
        const curSong = this.getCurrentMusic();

        if (playlist) {
            // 首次追加
            musics.forEach(song => {
                // 已存在
                const index = playlist.findIndex(item => item.id === song.id);
                if (index >= 0)
                    playlist.splice(index, 1);

                playlist.push(song);
            });

            playlist.forEach((item, index) => {
                item.index = index;
            });

            // 正在播放
            if (this.playlistType === PlaylistType.NETEASE_RANDOM_SONG) {
                // 更新播放队列
                this.setPlayQueue(playlist, PlaylistType.NETEASE_RANDOM_SONG);
                this.currentMusicIndex = this.currentPlayQueue.findIndex(item => item.id === curSong.id);

                return this.currentPlayQueue[this.currentMusicIndex];
            }

            return playlist[0];
        }

        return null;
    }

    /**
     * 添加当前音乐到播放历史
     */
    private addToHistory() {
        // 最近播放列表 不参与
        if (this.playlistType === PlaylistType.RECENT) return;

        const curSong = this.getCurrentMusic();
        let playlistRecent = this.playlistMap.get(PlaylistType.RECENT);
        const existingIndex = playlistRecent.findIndex(item => item.id === curSong.id && item.where === curSong.where);

        // 已存在
        if (existingIndex >= 0) {
            playlistRecent.splice(existingIndex, 1);
        }

        // 头插并更新索引
        playlistRecent.splice(0, 0, curSong);

        if (playlistRecent.length > MediaService.PLAY_HISTORY_LIMIT) {
            playlistRecent = playlistRecent.slice(0, MediaService.PLAY_HISTORY_LIMIT);
        }

        this.currentPlayQueue.forEach((item, index) => {
            item.index = index;
        })
    }

    /**
     * 随机一曲列表 播放
     * @param song
     */
    public playRandomSong() {
        // 切换播放队列
        const playlist = this.playlistMap.get(PlaylistType.NETEASE_RANDOM_SONG);
        if (playlist.length === 0)
            return false;

        this.setPlayQueue(playlist, PlaylistType.NETEASE_RANDOM_SONG);
        this.loadAssent(0);

        return true;
    }

    /**
     * 播放列表 -> 单曲播放
     * @param song
     * @param songs
     * @param type
     */
    public playOne(song: MusicInfo, songs: MusicInfo[], type: PlaylistType) {
        // 非搜索结果 直接更新播放队列
        if (type !== PlaylistType.SEARCH) {
            this.playlistMap.set(type, songs);
            this.setPlayQueue(this.playlistMap.get(type), type);

            this.loadAssent(this.currentPlayQueue.findIndex(item => item.id === song.id && item.where === song.where));
        } else {
            // 搜索结果 && 当前播放队列为空
            if (this.playlistType === PlaylistType.NONE) {
                this.playlistMap.set(type, songs);
                this.setPlayQueue(this.playlistMap.get(type), type);
                const index = this.currentPlayQueue.findIndex(item => item.id === song.id && item.where === song.where);

                this.loadAssent(index);
            } else {
                // 当前队列不为NONE, 插入到当前播放队列
                this.currentPlayQueue.splice(this.currentMusicIndex + 1, 0, song);
                this.currentPlayQueue.forEach((item, index) => {
                    item.index = index;
                });

                this.loadAssent(this.currentMusicIndex + 1);
            }
        }
    }

    /**
     * 插入到当前 播放队列 并播放
     * @param song 必须是最近音乐列表中的音乐
     */
    playOneRecent(song: MusicInfo) {
        const type = PlaylistType.RECENT;
        const recentPlaylist = this.playlistMap.get(type);

        const songIndex = recentPlaylist ? recentPlaylist.findIndex(item => item.id === song.id
            && item.where === song.where) : -1;

        if (songIndex === -1) {
            console.error(TAG, `不在最近播放列表 ${song}`);
            return;
        }

        // 无播放队列, 使用最近播放播放列表作为播放队列
        if (this.playlistType === PlaylistType.NONE) {
            this.setPlayQueue(recentPlaylist, type);

            this.loadAssent(songIndex);
        } else if (this.playlistType !== type) {
            // 插入到当前播放队列 并播放
            const insertIndex = this.currentMusicIndex + 1;
            const existIndex = this.currentPlayQueue.findIndex(item => item.id === song.id
                && item.where === song.where);

            // 已存在, 直接播放
            if (existIndex !== -1)  {
                this.loadAssent(existIndex);
                return;
            }

            // 不存在, 插入并重新索引 并播放
            this.currentPlayQueue.splice(insertIndex, 0, song);
            this.currentPlayQueue.forEach((item, index) => {
                item.index = index;
            });

            this.loadAssent(insertIndex);
        } else {
            // 直接播放
            const playIndex = this.currentPlayQueue.findIndex(item => item.id === song.id
                && item.where === song.where);

            this.loadAssent(playIndex);
        }
    }

    /**
     * 播放全部
     * @param songs
     * @param type
     */
    public playAll(songs: MusicInfo[], type: PlaylistType) {
        this.playlistMap.set(type, songs);
        this.setPlayQueue(this.playlistMap.get(type), type);
        this.loadAssent(0);
    }

    /**
     * 设置播放队列 并 更新索引
     * @param songs
     * @param type
     */
    private setPlayQueue(songs: MusicInfo[], type: PlaylistType) {
        this.currentPlayQueue = songs;
        // this.currentPlayQueue = [...songs];
        this.updateQueuePlaylistType(type);
        this.currentPlayQueue.forEach((item, index) => {
            item.index = index;
        });
    }

    // ================================== 播放控制管理 =================================
    /**
     * 初始化音频播放器
     */
    private initAudioPlayer() {
        media.createAVPlayer().then(async (avPlayer: media.AVPlayer) => {
            if (avPlayer !== null) {
                this.avPlayer = avPlayer;
                this.setAVPlayerCallback();
            }
        }).catch((error: Error) => {
            console.error(TAG, 'this avPlayer: ',
                `catch error happened, Error cause : ${JSON.stringify(error)}`)
        });
    }

    /**
     * 设置播放链接 url
     * @param musicIndex
     */
    private async setUrl(musicIndex: number = this.currentMusicIndex) {
        let music: MusicInfo = null;
        const song = this.currentPlayQueue[musicIndex];

        let try_cnt = 5;

        while (try_cnt--) {
            if (song.where === MusicFrom.NetEase)
                music = await this.http.getNetEaseMusic(song.id)
            else
                music = await this.http.getQQMusic(song.id)

            if (music) break;
            setTimeout('', 500);
        }

        if (music.pay) {
            promptAction.showToast({ message: '付费音乐，无法播放' });
            return;
        }

        this.avPlayer.url = music.url;
        // 更新当前播放索引
        this.updateCurrentMusicIndex(musicIndex);
        this.debugState();
    }

    /**
     * 监听播放状态
     */
    private setAVPlayerCallback() {
        if (!this.avPlayer || this.avPlayer === null) {
            console.error(TAG, `Invoke avPlayer failed`);
            return;
        }

        this.avPlayer.on('seekDone', (seekDoneTime: number) => {
            this.isCurrent = true;
            console.info(TAG, `AVPlayer onSeekDone: seek time is ${seekDoneTime}`);
        });

        this.avPlayer.on('error', (err) => {
            console.error(TAG, `AVPlayer onError: code is ${err.code}, message is ${err.message}`);
            if (this.avPlayer) {
                this.avPlayer.reset();
                this.currentPlayQueue[this.currentMusicIndex].pay = true;
            }
        });

        this.avPlayer.on('timeUpdate', (updateTime: number) => {
            if (this.isCurrent) {
                AppStorage.SetOrCreate('currentTime', MediaTools.msToCountdownTime(updateTime));
                AppStorage.SetOrCreate<number>('progress', updateTime);
            }
        });

        this.avPlayer.on('stateChange', async (state: media.AVPlayerState) => {
            let stateString = state.toString();
            console.log(TAG, `AVPlayer state ${stateString}`);

            switch (stateString) {
                case 'idle':
                // url:只允许在idle状态下设置 -> initialized 状态
                    this.setPlayState(PlayerState.IDLE);
                    this.setUrl();
                    break;

                case 'initialized':
                    this.setPlayState(PlayerState.INITIALIZED);
                    if (this.avPlayer) {
                        this.avPlayer.prepare().catch((err: Error) => {
                            console.error(TAG, `AVPlayer prepare failed,${err.name} ${err.message}`);
                        });
                    }
                    break;

                case 'prepared':
                    this.setPlayState(PlayerState.PREPARED);
                    this.isPrepared = true;
                    AppStorage.SetOrCreate('totalTime', MediaTools.msToCountdownTime(this.getDuration()));
                    AppStorage.SetOrCreate('progressMax', this.getDuration());
                    if (this.avPlayer) this.avPlayer.play();
                    break;

                case 'playing':
                    this.setPlayState(PlayerState.PLAY);
                    this.addToHistory();
                    break;

                case 'paused':
                    this.setPlayState(PlayerState.PAUSE);
                    break;

                case 'completed':
                    this.setPlayState(PlayerState.COMPLETED);
                    this.playNextAuto(false);
                    break;

                case 'stopped':
                    this.setPlayState(PlayerState.STOP);
                    if (this.avPlayer) this.avPlayer.reset();
                    break;

                case 'released':
                    this.setPlayState(PlayerState.RELEASED);
                    break;

                default:
                    this.setPlayState(PlayerState.UNKNOWN);
                    break;
            }
        })
    }

    /**
     * 更新音乐索引 并加载
     * @param musicIndex
     */
    async loadAssent(musicIndex: number) {
        if (musicIndex >= this.currentPlayQueue.length) {
            console.error(TAG, `current musicIndex ${musicIndex}`);
            return;
        }

        // TODO bug
        BackgroundUtil.startContinuousTask(this.context);
        this.setUrl(musicIndex);
    }

    /**
     * 获取播放模式
     * @returns
     */
    public getPlayMode() {
        return this.playMode;
    }

    /**
     * 设置播放模式
     * @param playMode
     */
    public setPlayModel(playMode: MusicPlayMode) {
        this.playMode = playMode;
        console.info(TAG, 'setPlayModel mode: ' + enumToString(MusicPlayMode, this.playMode));
    }

    /**
     * 更新当前播放队列 类型
     * @param type
     */
    private updateQueuePlaylistType(type: PlaylistType) {
        this.currentPlaylistType = type;
        AppStorage.SetOrCreate('currentPlaylistType', type);
    }

    /**
     * 跳转到指定播放位置 (prepared/playing/paused/complete状态下)
     * @param ms
     */
    public seek(ms: number) {
        if (this.isPrepared && this.getPlayState() != PlayerState.ERROR) {
            // 快进方向
            let seekMode = this.getCurrentTime() < ms ? media.SeekMode.SEEK_NEXT_SYNC : media.SeekMode.SEEK_PREV_SYNC;
            // 跳转位置
            let realTime = (ms <= 0 ? 0 : (ms >= this.getDuration() ? this.getDuration() : ms));
            this.isCurrent = false;
            if (this.avPlayer) this.avPlayer.seek(realTime, seekMode);
        }
    }

    /**
     * 获取当前位置(ms) prepared/playing/paused/completed状态下有效
     * @returns
     */
    private getCurrentTime() {
        if (this.isPrepared && this.avPlayer) {
            return this.avPlayer.currentTime;
        }
        return 0;
    }

    /**
     * 获取播放时长(ms) prepared/playing/paused/completed状态下有效
     * @returns
     */
    public getDuration() {
        if (this.isPrepared && this.avPlayer) {
            return this.avPlayer.duration;
        }
        return 0;
    }

    /**
     * 自动播放下一首
     * @param isFromControl
     */
    public playNextAuto(isFromControl: boolean) {
        console.info(TAG, 'playNextAuto mode:' + enumToString(MusicPlayMode, this.playMode));

        switch (this.playMode) {
            case MusicPlayMode.SINGLE_CYCLE:
                if (isFromControl) {
                    this.playNext();
                } else {
                    if (this.avPlayer) this.avPlayer.play();
                }
                break;
            case MusicPlayMode.ORDER:
                this.playNext();
                break;
            case MusicPlayMode.RANDOM:
                this.playRandom();
                break;
            default:
                break;
        }
    }

    /**
     * 手动-播放下一首
     */
    private playNext() {
        console.info(TAG, 'playNext Index:' + this.currentMusicIndex + ', length-1:' + (this.currentPlayQueue.length - 1));

        switch (this.playMode) {
            case MusicPlayMode.RANDOM:
                this.playRandom();
                break;
            case MusicPlayMode.ORDER:
            case MusicPlayMode.SINGLE_CYCLE:
                if (this.currentMusicIndex === this.currentPlayQueue.length - 1) {
                    this.loadAssent(0);
                } else {
                    this.loadAssent(this.currentMusicIndex + 1);
                }
                break;
            default:
                break;
        }

        // 随机一曲 只能 顺序或单曲循环
        this.notifyUpdateRandWidget();
    }

    /**
     * 手动-播放上一首
     */
    public playPrevious() {
        switch (this.playMode) {
            case MusicPlayMode.RANDOM:
                this.playRandom();
                break;
            case MusicPlayMode.ORDER:
            case MusicPlayMode.SINGLE_CYCLE:
                if (this.currentMusicIndex === 0) {
                    this.updateCurrentMusicIndex(this.currentPlayQueue.length - 1);
                } else {
                    this.updateCurrentMusicIndex(this.currentMusicIndex - 1);
                }
                console.info(TAG, 'setLastIndex:' + this.currentMusicIndex);
                this.loadAssent(this.currentMusicIndex);
                break;
            default:
                break;
        }

        this.notifyUpdateRandWidget();
    }

    /**
     * 随机播放 队列中的一首
     */
    private playRandom() {
        let index = Math.round(Math.random() * (this.currentPlayQueue.length - 1));
        if (this.currentMusicIndex === index) {
            this.playRandom();
        } else {
            this.updateCurrentMusicIndex(index);
            this.loadAssent(index);
        }
        console.info(TAG, 'play Random:' + this.currentMusicIndex);
    }

    /**
     * Play music.
     */
    public async play() {
        BackgroundUtil.startContinuousTask(this.context);

        if (this.isPrepared && this.avPlayer) {
            this.avPlayer.play().then(() => {
                this.seek(this.getCurrentTime());
                this.setPlayState(PlayerState.PLAY);
            });
        }
    }

    /**
     * 暂停播放 -> pause
     */
    public pause() {
        if (this.isPrepared && this.getPlayState() === PlayerState.PLAY && this.avPlayer) {
            this.avPlayer.pause().then(() => {
                this.setPlayState(PlayerState.PAUSE);
            });
        }
    }

    /**
     * 停止播放
     */
    public async stop() {
        if (this.isPrepared && this.avPlayer)
            await this.avPlayer.stop();
    }

    /**
     * 重置资源 -> idle
     */
    private async reset() {
        if (this.avPlayer)
            await this.avPlayer.reset();

        this.isPrepared = false;
    }

    /**
     * 销毁实例 -> released
     */
    public release() {
        this.stop();
        this.reset();
        if (this.avPlayer)
            this.avPlayer.release();

        this.setPlayState(PlayerState.IDLE);

        if (this.context)
            BackgroundUtil.stopContinuousTask(this.context);

        this.http.destroy();
    }

    /**
     * 更新当前 音乐索引
     * @param musicIndex
     */
    private updateCurrentMusicIndex(musicIndex: number) {
        if (this.currentMusicIndex != musicIndex)
            this.currentMusicIndex = musicIndex;
    }
}
