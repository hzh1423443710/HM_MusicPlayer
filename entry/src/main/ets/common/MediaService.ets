import media from '@ohos.multimedia.media'
import common from '@ohos.app.ability.common';
import { enumToString, MusicInfo, PlaylistType } from '../model/MusicData';
import { MediaTools } from '../common/MediaTools'
import { BackgroundUtil } from '../common/BackgroundUtil'

const TAG = 'MediaService';

/**
 * 播放模式
 */
enum MusicPlayMode {
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
export enum AudioPlayerState {
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

export class MediaService {
    private context: common.UIAbilityContext | undefined = AppStorage.Get('context');
    public avPlayer: media.AVPlayer | null = null;
    /**
     * 播放顺序
     */
    private playMode: MusicPlayMode = MusicPlayMode.ORDER;
    /**
     * AVPlayer状态
     */
    private state: AudioPlayerState = AudioPlayerState.IDLE;
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
    /**
     * 是否第一次播放
     */
    private isFirst: boolean = true;

    constructor() {
        this.initAudioPlayer();
        // 最近播放
        this.playlistMap.set(PlaylistType.RECENT, []);
        // 随机一曲
        this.playlistMap.set(PlaylistType.NETEASE_RANDOM_SONG, []);

        this.updateIsPlay(false);
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
        if (this.getCurrentPlaylistType() === PlaylistType.NETEASE_RANDOM_SONG) {
            // 使用时间戳
            AppStorage.SetOrCreate('updateUITrigger', Date.now());

            // 更新一组 随机一曲
            if (this.currentMusicIndex === this.currentPlayQueue.length - 2) {
                AppStorage.SetOrCreate('needAppend', Date.now());
            }
        }
    }

    /*******************************             debug                  ***************************/
    public debugPlayQueue() {
        this.currentPlayQueue.forEach((item, index) => {
            console.log(`播放队列[${index}] ${item}`);
        })
    }

    public debugPlaylist(type: PlaylistType) {
        const playlist = this.playlistMap.get(type);
        playlist.forEach((item, index) => {
            console.log(`播放列表${enumToString(PlaylistType, type)}:[${index}] ${item}`);
        });
    }

    public debugState() {
        console.log(`播放器:${this.isPlaying()}-${enumToString(PlaylistType, this.getCurrentPlaylistType())}-${enumToString(AudioPlayerState, this.getPlayState())}`);
    }

    /*******************************            播放队列管理              ***************************/
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
            if (this.getCurrentPlaylistType() === PlaylistType.NETEASE_RANDOM_SONG) {
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
        if (type !== PlaylistType.QQ_SEARCH) {
            this.playlistMap.set(type, songs);
            this.setPlayQueue(this.playlistMap.get(type), type);

            this.loadAssent(this.currentPlayQueue.findIndex(item => item.id === song.id && item.where === song.where));
        } else {
            // 搜索结果 && 当前播放队列为空
            if (this.getCurrentPlaylistType() === PlaylistType.NONE) {
                this.playlistMap.set(type, songs);
                this.setPlayQueue(this.playlistMap.get(type), type);

                this.loadAssent(0);
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
        this.currentPlayQueue = [...songs];
        this.updateQueuePlaylistType(type);
        this.currentPlayQueue.forEach((item, index) => {
            item.index = index;
        });
    }

    public getCurrentPlaylistType(): PlaylistType {
        return this.currentPlaylistType;
    }

    /*******************************            播放控制管理              ***************************/
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
     * 监听播放状态
     */
    private setAVPlayerCallback() {
        if (!this.avPlayer || this.avPlayer === null) {
            console.error(TAG, `Invoke avPlayer failed`);
            return;
        }

        this.avPlayer.on('seekDone', (seekDoneTime: number) => {
            this.isCurrent = true;
            console.info(TAG, `AVPlayer seek succeeded, seek time is ${seekDoneTime}`);
        });

        this.avPlayer.on('error', (err) => {
            console.error(TAG, `Invoke avPlayer failed, code is ${err.code}, message is ${err.message}`);
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
                    this.state = AudioPlayerState.IDLE;
                    if (!this.currentPlayQueue[this.currentMusicIndex].pay)
                        this.avPlayer.url = this.currentPlayQueue[this.currentMusicIndex].url;
                    break;

                case 'initialized':
                    this.state = AudioPlayerState.INITIALIZED;
                    if (this.avPlayer) {
                        this.avPlayer.prepare().catch((err) => {
                            console.error(TAG, `Invoke prepare failed, Error cause : ${JSON.stringify(err)}`);
                        });
                    }
                    break;

                case 'prepared':
                    this.state = AudioPlayerState.PREPARED;
                    this.isPrepared = true;
                    AppStorage.SetOrCreate('totalTime', MediaTools.msToCountdownTime(this.getDuration()));
                    AppStorage.SetOrCreate('progressMax', this.getDuration());
                    if (this.avPlayer) this.avPlayer.play();
                    break;

                case 'playing':
                    this.state = AudioPlayerState.PLAY;
                    this.addToHistory();
                    break;

                case 'paused':
                    this.state = AudioPlayerState.PAUSE;
                    break;

                case 'completed':
                    this.state = AudioPlayerState.COMPLETED;
                    this.playNextAuto(false);
                    break;

                case 'stopped':
                    this.state = AudioPlayerState.STOP;
                    if (this.avPlayer) this.avPlayer.reset();
                    break;

                case 'released':
                    this.state = AudioPlayerState.RELEASED;
                    break;

                default:
                    this.state = AudioPlayerState.UNKNOWN;
                    break;
            }
            // 每次状态变化后, 检测是否更新播放
            this.updateIsPlay(this.state === AudioPlayerState.PLAY);
        })
    }

    public isPlaying(): boolean {
        return AppStorage.Get<boolean>('isPlay');
    }

    public isPause(): boolean {
        return this.state === AudioPlayerState.PAUSE;
    }

    /**
     * 重新播放
     * @returns 付费=播放失败
     */
    async rePlay() {
        if (this.currentPlayQueue[this.currentMusicIndex].pay)
            return false;

        this.avPlayer.url = this.currentPlayQueue[this.currentMusicIndex].url;
        return true;
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

        this.updateCurrentMusicIndex(musicIndex);
        console.log(`loadAssent[${this.currentMusicIndex}] ${this.currentPlayQueue[this.currentMusicIndex]}`);

        // 第一次播放 手动更新状态
        if (this.isFirst) {
            this.isFirst = false;
            this.avPlayer.url = this.currentPlayQueue[this.currentMusicIndex].url;
        } else {
            await this.avPlayer.stop();
        }
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
     * 修改全局播放状态
     * @param isPlay
     */
    private updateIsPlay(isPlay: boolean) {
        AppStorage.SetOrCreate<boolean>('isPlay', isPlay);
    }

    /**
     * 更新当前播放队列 类型
     * @param type
     */
    private updateQueuePlaylistType(type: PlaylistType) {
        this.currentPlaylistType = type;
        AppStorage.SetOrCreate('currentPlaylistType', type);
        console.log(`播放队列类型 -> ${enumToString(PlaylistType, type)}`);
    }

    /**
     * 跳转到指定播放位置 (prepared/playing/paused/complete状态下)
     * @param ms
     */
    public seek(ms: number) {
        if (this.isPrepared && this.state != AudioPlayerState.ERROR) {
            // 快进方向
            let seekMode = this.getCurrentTime() < ms ? media.SeekMode.SEEK_NEXT_SYNC : media.SeekMode.SEEK_PREV_SYNC;
            // 跳转位置
            let realTime = (ms <= 0 ? 0 : (ms >= this.getDuration() ? this.getDuration() : ms));
            this.isCurrent = false;
            if (this.avPlayer) this.avPlayer.seek(realTime, seekMode);
        }
    }

    /**
     * 获取当前播放状态
     * @returns
     */
    public getPlayState(): AudioPlayerState {
        return this.state;
    }

    /**
     * 当前是否处于空闲状态
     * @returns
     */
    public idle(): boolean {
        return this.state == AudioPlayerState.IDLE;
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
                this.updateIsPlay(true);
                this.state = AudioPlayerState.PLAY;
            })
        }
    }

    /**
     * 暂停播放 -> pause
     */
    public pause() {
        if (this.isPrepared && this.state == AudioPlayerState.PLAY && this.avPlayer) {
            this.avPlayer.pause().then(() => {
                this.state = AudioPlayerState.PAUSE;
                this.updateIsPlay(false);
            });
        }
    }

    /**
     * 停止播放
     */
    public async stop() {
        if (this.isPrepared && this.avPlayer) {
            console.info(TAG, 'stop()');
            await this.avPlayer.stop();
            this.updateIsPlay(false);
            this.state = AudioPlayerState.PAUSE;
        }
    }

    /**
     * 重置资源 -> idle
     */
    private async reset() {
        console.info(TAG, 'reset()');
        if (this.avPlayer) {
            await this.avPlayer.reset();
        }
        this.isPrepared = false;
    }

    /**
     * 销毁实例 -> released
     */
    public release() {
        this.updateIsPlay(false);
        this.stop();
        this.reset();
        if (this.avPlayer) this.avPlayer.release();
        this.state = AudioPlayerState.IDLE;
        if (this.context) {
            BackgroundUtil.stopContinuousTask(this.context);
        }
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
