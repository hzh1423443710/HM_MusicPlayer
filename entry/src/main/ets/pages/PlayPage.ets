import { BreakpointConstants } from '../common/constants/BreakpointConstants';
import { MediaService, PlayerState } from '../common/MediaService';
import { ControlComponent } from '../components/ControlComponent';
import { LyricsComponent } from '../components/LyricsComponent';
import { MusicInfoComponent } from '../components/MusicInfoComponent';
import { MusicInfo } from '../model/MusicData';

@Entry
@Component
struct PlayPage {
    song_id: string = '';
    @State currentTabIndex: number = 0;
    @StorageProp('currentBreakpoint') currentBreakpoint: string = 'sm';
    @State music: MusicInfo = new MusicInfo();
    @StorageProp('playState') @Watch('onPlayStateChanged') playState: PlayerState = PlayerState.IDLE;
    media: MediaService = MediaService.getInstance();

    onPlayStateChanged() {
        const new_song = this.media.getCurrentMusic();
        if (!new_song.equals(this.music))
            this.music = new_song;
    }

    aboutToAppear(): void {
        const new_song = this.media.getCurrentMusic();
        if (new_song)
            this.music = new_song;
    }

    build() {
        Stack({ alignContent: Alignment.TopStart }) {
            // 大屏
            if (this.currentBreakpoint === BreakpointConstants.BREAKPOINT_LG) {
                Stack({ alignContent: Alignment.Top }) {
                    // 歌词组件
                    LyricsComponent({ music: this.music })

                    // 音乐信息+控制组件
                    Flex({ direction: FlexDirection.Column }) {
                        MusicInfoComponent({ music: this.music })
                        ControlComponent()
                    }

                }

            } else {
                // 小/中 屏
                Flex({ direction: FlexDirection.Column }) {
                    Tabs({ barPosition: BarPosition.Start, index: this.currentTabIndex }) {
                        TabContent() {
                            MusicInfoComponent({ music: this.music })
                        }
                        .tabBar(this.TabTitle('歌曲', 0))

                        TabContent() {
                            LyricsComponent({ music: this.music })
                        }
                        .tabBar(this.TabTitle('歌词', 1))
                    }
                    .onChange(index => this.currentTabIndex = index)
                    .vertical(false)
                    .barHeight(56)
                    .barWidth('36%')

                    ControlComponent()
                }

            }
        } // Stack
        .width('100%')
        .height('100%')
        .backgroundImage($r('app.media.ic_avatar3'))
        .backgroundImageSize(ImageSize.Cover)
        .backgroundBlurStyle(BlurStyle.Regular)
    } // build

    @Builder
    TabTitle(title: string | Resource, index: number) {
        Text(title)
            .fontColor(this.currentTabIndex === index ? '#376668' : '#99376668')
            .fontWeight(this.currentTabIndex === index ? 500 : 400)
            .fontSize(20)
            .border({
                width: { bottom: this.currentTabIndex === index ? 2 : 0 },
                color: '#376668'
            })
            .padding({ bottom: 2 })
    }

    // 转场动画
    pageTransition() {
        PageTransitionEnter({ duration: 500, curve: Curve.Smooth }).slide(SlideEffect.Bottom);
        PageTransitionExit({ duration: 500, curve: Curve.Smooth }).slide(SlideEffect.Bottom);
    }
}