import media from '@ohos.multimedia.media'
import common from '@ohos.app.ability.common';
import { MusicFrom, MusicInfo } from '../model/MusicData';
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
enum AudioPlayerState {
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
    private songItem: MusicInfo = new MusicInfo();
    private playMode: MusicPlayMode = MusicPlayMode.ORDER;
    private state: AudioPlayerState = AudioPlayerState.IDLE;
    private isFirst: boolean = true;
    private isPrepared: boolean = false;
    private musicIndex: number = 0;
    // 当前播放列表
    private songList: MusicInfo[] = [];
    private isCurrent: boolean = true;

    constructor() {
        this.initAudioPlayer();
    }

    public static getInstance(): MediaService {
        let mediaService: MediaService | undefined = AppStorage.Get('mediaService');
        if (!mediaService) {
            mediaService = new MediaService();
            AppStorage.SetOrCreate('mediaService', mediaService);
        }
        return mediaService;
    }

    private initAudioPlayer() {
        media.createAVPlayer().then(async (avPlayer: media.AVPlayer) => {
            if (avPlayer !== null) {
                this.avPlayer = avPlayer;
                this.setAVPlayerCallback();
            }
        })
            .catch((error: Error) => console.error(TAG, 'this avPlayer: ',
                `catch error happened, Error cause : ${JSON.stringify(error)}`));
    }


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
            if (this.avPlayer) this.avPlayer.reset();
        });

        this.avPlayer.on('timeUpdate', (updateTime: number) => {
            if (this.isCurrent) {
                AppStorage.SetOrCreate('currentTime', MediaTools.msToCountdownTime(updateTime));
                AppStorage.SetOrCreate<number>('progress', updateTime);
            }
        });

        this.avPlayer.on('stateChange', async (state: media.AVPlayerState) => {
            let stateString = state.toString();
            switch (stateString) {
                case 'idle':
                    console.info(TAG, 'AVPlayer state idle called.');
                    this.state = AudioPlayerState.IDLE;
                    this.avPlayer.url = this.songList[this.musicIndex].url;
                    break;
                case 'initialized':
                    console.info(TAG, 'AVPlayer state initialized called.');
                    this.state = AudioPlayerState.INITIALIZED;
                    if (this.avPlayer) {
                        this.avPlayer.prepare().then(() => {
                            console.info(TAG, 'AVPlayer prepare succeeded.');
                        }, (err: Error) => {
                            console.error(TAG, `Invoke prepare failed, Error cause : ${JSON.stringify(err)}`);
                        });
                    }
                    break;
                case 'prepared':
                    console.info(TAG, 'AVPlayer state prepared called.');
                    this.state = AudioPlayerState.PREPARED;
                    this.isPrepared = true;
                    AppStorage.SetOrCreate('totalTime', MediaTools.msToCountdownTime(this.getDuration()));
                    AppStorage.SetOrCreate('progressMax', this.getDuration());
                    if (this.avPlayer) this.avPlayer.play();
                    console.info(TAG, 'AVPlayer prepared succeeded.');
                    break;
                case 'playing':
                    console.info(TAG, 'AVPlayer state playing called.');
                    this.state = AudioPlayerState.PLAY;
                    break;
                case 'paused':
                    console.info(TAG, 'AVPlayer state paused called.');
                    this.state = AudioPlayerState.PAUSE;
                    break;
                case 'completed':
                    console.info(TAG, 'AVPlayer state completed called.');
                    this.state = AudioPlayerState.COMPLETED;
                    this.playNextAuto(false);
                    break;
                case 'stopped':
                    console.info(TAG, 'AVPlayer state stopped called.');
                    this.state = AudioPlayerState.STOP;
                    if (this.avPlayer) this.avPlayer.reset();
                    break;
                case 'released':
                    console.info(TAG, 'AVPlayer state released called.');
                    this.state = AudioPlayerState.RELEASED;
                    break;
                default:
                    console.info(TAG, 'AVPlayer state unknown called.');
                    this.state = AudioPlayerState.UNKNOWN;
                    break;
            }
            this.updateIsPlay(this.state === AudioPlayerState.PLAY);
        })
    }

    /**
     * 通过索引 播放音乐列表中的音乐
     * @param musicIndex
     */
    async loadAssent(musicIndex: number) {
        if (musicIndex >= this.songList.length) {
            console.error(TAG, `current musicIndex ${musicIndex}`);
            return;
        }
        BackgroundUtil.startContinuousTask(this.context);
        this.updateMusicIndex(musicIndex);
        if (this.isFirst) {
            this.isFirst = false;
            this.avPlayer.url = this.songList[this.musicIndex].url;
        } else {
            await this.stop();
        }
    }

    /**
     * 是否从第一首播放
     * @returns
     */
    public getFirst() {
        return this.isFirst;
    }

    public getPlayMode() {
        return this.playMode;
    }

    /**
     * 更新是否正在播放
     * @param playMode
     */
    public setPlayModel(playMode: MusicPlayMode) {
        this.playMode = playMode;
        console.info(TAG, 'setPlayModel mode: ' + this.playMode);
    }

    private updateIsPlay(isPlay: boolean) {
        AppStorage.SetOrCreate<boolean>('isPlay', isPlay);
    }

    public seek(ms: number) {
        if (this.isPrepared && this.state != AudioPlayerState.ERROR) {
            let seekMode = this.getCurrentTime() < ms ? 0 : 1;
            let realTime = (ms <= 0 ? 0 : (ms >= this.getDuration() ? this.getDuration() : ms));
            this.isCurrent = false;
            if (this.avPlayer) this.avPlayer.seek(realTime, seekMode);
        }
    }

    private getCurrentTime() {
        if (this.isPrepared && this.avPlayer) {
            return this.avPlayer.currentTime;
        }
        return 0;
    }

    /**
     * 获取播放时长
     * @returns
     */
    private getDuration() {
        if (this.isPrepared && this.avPlayer) {
            return this.avPlayer.duration;
        }
        return 0;
    }

    /**
     * 播放下一首
     * @param isFromControl
     */
    public playNextAuto(isFromControl: boolean) {
        console.info(TAG, 'playNextAuto mode:' + this.playMode);
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

    private playNext() {
        console.info(TAG, 'playNext Index:' + this.musicIndex + ', length-1:' + (this.songList.length - 1));
        if (this.musicIndex === this.songList.length - 1) {
            this.loadAssent(0);
        } else {
            this.loadAssent(this.musicIndex + 1);
        }
    }


    public playPrevious() {
        switch (this.playMode) {
            case MusicPlayMode.RANDOM:
                this.playRandom();
                break;
            case MusicPlayMode.ORDER:
            case MusicPlayMode.SINGLE_CYCLE:
                if (this.musicIndex === 0) {
                    this.updateMusicIndex(this.songList.length - 1);
                } else {
                    this.updateMusicIndex(this.musicIndex - 1);
                }
                console.info(TAG, 'setLastIndex:' + this.musicIndex);
                this.loadAssent(this.musicIndex);
                break;
            default:
                break;
        }
    }

    private playRandom() {
        let num = Math.round(Math.random() * (this.songList.length - 1));
        if (this.musicIndex === num) {
            this.playRandom();
        } else {
            this.updateMusicIndex(num);
            this.loadAssent(num);
        }
        console.info(TAG, 'play Random:' + this.musicIndex);
    }

    public async stop() {
        if (this.isPrepared && this.avPlayer) {
            console.info(TAG, 'stop()');
            await this.avPlayer.stop();
            this.updateIsPlay(false);
            this.state = AudioPlayerState.PAUSE;
        }
    }

    private async reset() {
        console.info(TAG, 'reset()');
        if (this.avPlayer) {
            await this.avPlayer.reset();
        }
        this.isPrepared = false;
    }

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

    private updateMusicIndex(musicIndex: number) {
        console.info(TAG, 'updateMusicIndex ===> ' + musicIndex);
        AppStorage.SetOrCreate('selectIndex', musicIndex);
        if (this.musicIndex != musicIndex) {
            this.musicIndex = musicIndex;
        }
    }
}
