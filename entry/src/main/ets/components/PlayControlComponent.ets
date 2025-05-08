import { BreakpointType } from '../common/BreakpointSystem';
import { PlayConstants } from '../common/constants/PlayConstants';
import { PlayControlConstants } from '../common/constants/PlayControlConstants';
import { MediaService, MusicPlayMode, PlayerState } from '../common/MediaService';
import { PlayControlModel } from '../model/PlayControlModel'
import promptAction from '@ohos.promptAction';
import router from '@ohos.router';
import { RouterUrlConstants } from '../common/constants/RouterUrlConstants';

/**
 * 播放控制子组件
 */
@Preview
@Component
export struct PlayControlComponent {
    @StorageProp('currentBreakpoint') currentBreakpoint: string = 'sm';
    @StorageProp('playState') @Watch('onPlayStateChanged') playState: PlayerState = PlayerState.IDLE;
    @State playControl: PlayControlModel = null;
    @State index: number = 0;
    media: MediaService = MediaService.getInstance();

    aboutToAppear(): void {
        this.onPlayStateChanged();
    }

    onPlayStateChanged() {
        if (this.index !== PlayConstants.PLAY_INDEX) return;

        if (this.playState === PlayerState.PLAY) {
            this.playControl.icon = $r('app.media.ic_play_big');
            this.playControl.key = PlayControlConstants.PAUSE;
        } else {
            this.playControl.icon = $r('app.media.ic_pause_big');
            this.playControl.key = PlayControlConstants.PLAY;
        }
    }

    build() {
        Image(this.playControl.icon)
            .width(this.index === PlayConstants.PLAY_INDEX ? new BreakpointType({
                sm: 64,
                md: 64,
                lg: 80
            }).getValue(this.currentBreakpoint) : new BreakpointType({
                sm: 24,
                md: 24,
                lg: 30
            }).getValue(this.currentBreakpoint))
            .aspectRatio(1)
            .objectFit(ImageFit.Contain)
            .onClick(() => this.playControlClick(this.playControl.key))
    }

    /**
     * 播放控制点击
     * @param key
     */
    playControlClick(key: PlayControlConstants) {
        switch (key) {
            case PlayControlConstants.PLAY_MODE:
                this.changePlayMode();
                break;

            case PlayControlConstants.PREVIOUS:
                promptAction.showToast({ message: '上一首' });
                this.media.playPrevious();
                break;

            case PlayControlConstants.PLAY:
                this.media.play();
                this.playControl.icon = $r('app.media.ic_play_big');
                this.playControl.key = PlayControlConstants.PAUSE;
                break;

            case PlayControlConstants.PAUSE:
                this.media.pause();
                this.playControl.icon = $r('app.media.ic_pause_big');
                this.playControl.key = PlayControlConstants.PLAY;
                break;

            case PlayControlConstants.NEXT:
                promptAction.showToast({ message: '下一首' });
                this.media.playNextAuto(true);
                break;

            case PlayControlConstants.PLAY_LIST:
                router.pushUrl({
                    url: RouterUrlConstants.PLAY_QUEUE
                });
                break;
            default:
                break;
        }
    }

    /**
     * 修改播放模式
     */
    private changePlayMode(): void {
        const mode = [MusicPlayMode.SINGLE_CYCLE, MusicPlayMode.ORDER, MusicPlayMode.RANDOM];
        const resource = [$r('app.media.ic_public_single_cycle'), $r('app.media.ic_list_cycle'), $r('app.media.ic_public_random')];
        let index = MediaService.getInstance().getPlayMode() + 1;
        if (index > mode.length - 1) {
            index = 0;
        }
        this.playControl.icon = resource[index];
        this.media.setPlayModel(mode[index]);

        switch (mode[index]) {
            case MusicPlayMode.SINGLE_CYCLE:
                promptAction.showToast({ message: '单曲循环' });
                break;
            case MusicPlayMode.ORDER:
                promptAction.showToast({ message: '顺序播放' });
                break;
            case MusicPlayMode.RANDOM:
                promptAction.showToast({ message: '随机播放' });
                break;
            default:
                break;
        }
    }
}