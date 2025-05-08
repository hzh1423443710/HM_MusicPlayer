import { MusicInfo, PlaylistType } from '../model/MusicData'
import router from '@ohos.router';
import { RouterUrlConstants } from '../common/constants/RouterUrlConstants';
import { PlayerState, MediaService } from '../common/MediaService';
import promptAction from '@ohos.promptAction';
import pasteboard from '@ohos.pasteboard';
import { BreakpointConstants } from '../common/constants/BreakpointConstants';

@Preview
@Component
export struct PlayerWidget {
    @StorageProp('currentBreakpoint') currentBreakpoint: string = 'sm';
    @State music: MusicInfo = null;
    @StorageProp('playState') @Watch('onPlayStateChanged') playState: PlayerState = PlayerState.IDLE;
    @State imageRotate: number = 0;
    media: MediaService = MediaService.getInstance();

    aboutToAppear(): void {
        const new_song = this.media.getCurrentMusic();
        this.music = (new_song === null) ? new MusicInfo(0, '', '鸿蒙音乐 听我想听') : new_song;
    }

    /**
     * 播放状态发生变化
     */
    onPlayStateChanged() {
        const new_song = this.media.getCurrentMusic();
        if (!new_song.equals(this.music))
            this.music = new_song;

        switch (this.playState) {
            case PlayerState.INITIALIZED:
                promptAction.showToast({ message: '加载中' });
                break;
            case PlayerState.PREPARED:
                promptAction.showToast({ message: '加载完毕' });
                break;
            default:
                break;
        }

        this.rotateCover();
    }

    rotateCover() {
        // 封面旋转动画
        this.imageRotate = 0;
        this.imageRotate = this.playState === PlayerState.PLAY ? 360 : 0;
    }

    build() {
        Row() {
            // 封面+歌名+歌手
            Row() {
                // 封面
                Image(this.music.pic)
                    .alt($r("app.media.default_cover_circle"))
                    .height($r('app.float.cover_height'))
                    .width($r('app.float.cover_width'))
                    .borderRadius($r('app.float.label_border_radius'))
                    .margin({ right: $r('app.float.music_list_cover_margin') })
                    .rotate({ angle: this.imageRotate })
                    .animation({
                        duration: 3000,
                        iterations: -1,
                        curve: Curve.Linear
                    })
                    .onAppear(() => {
                        this.rotateCover()
                    })

                Column() {
                    // 歌名
                    Marquee({ start: this.playState === PlayerState.PLAY, src: this.music.name })
                        .width(150)
                        .fontColor($r('app.color.song_name'))
                        .fontSize(18)// .borderWidth(1)
                        .alignSelf(ItemAlign.Start)
                        .gesture(LongPressGesture().onAction((event: GestureEvent) => {
                            const sysBoard = pasteboard.getSystemPasteboard();
                            const data = pasteboard.createData('text/plain', this.music.name);
                            sysBoard.setData(data).then(() => {
                                promptAction.showToast({ message: '复制成功', bottom: 400 })
                            }).catch((error) => {
                                console.log('copy error: ' + error);
                            });
                        }))
                    // 歌手
                    Row() {
                        Image(this.music.pay ? $r('app.media.ic_vip') : $r('app.media.ic_sq'))
                            .height($r('app.float.vip_icon_height'))
                            .width($r('app.float.vip_icon_width'))
                            .margin({ right: $r('app.float.vip_icon_margin') })
                        Text(this.music.singer)
                            .fontColor($r('app.color.singer'))
                            .fontSize(14)
                            .textOverflow({ overflow: TextOverflow.Ellipsis })
                            .maxLines(1)
                            .opacity($r('app.float.singer_opacity'))
                    }
                }
                .alignItems(HorizontalAlign.Start)

            } // Row
            .layoutWeight(1)
            .onClick(() => {
                router.pushUrl({
                    url: RouterUrlConstants.PLAY
                });
            })

            // 空白
            Blank()
                .onClick(() => {
                    console.log('click blank');
                    router.pushUrl({
                        url: RouterUrlConstants.PLAY
                    });
                })

            // 播放控制
            Row() {
                if (this.currentBreakpoint != BreakpointConstants.BREAKPOINT_SM) {
                    Image($r('app.media.ic_public_play_last'))
                        .fillColor($r('app.color.control_icon_color'))
                        .width($r('app.float.control_icon_width'))
                        .height($r('app.float.control_icon_height'))
                        .onClick(() => {
                            this.media.playPrevious();
                        })
                }

                Image(this.playState === PlayerState.PLAY ? $r('app.media.ic_public_pause') : $r('app.media.ic_public_play'))
                    .fillColor($r('app.color.control_icon_color'))
                    .width($r('app.float.control_icon_width'))
                    .height($r('app.float.control_icon_height'))
                    .margin({ left: $r('app.float.control_icon_margin'), right: $r('app.float.control_icon_margin') })
                    .onClick(() => {
                        if (this.media.playlistType === PlaylistType.NONE) {
                            promptAction.showToast({ message: '播放队列为空' })
                            return;
                        }

                        this.playState === PlayerState.PLAY ? this.media.pause() : this.media.play();
                    })

                if (this.currentBreakpoint != BreakpointConstants.BREAKPOINT_SM) {
                    Image($r('app.media.ic_public_play_next'))
                        .fillColor($r('app.color.control_icon_color'))
                        .width($r('app.float.control_icon_width'))
                        .height($r('app.float.control_icon_height'))
                        .margin({ right: $r('app.float.control_icon_margin') })
                        .onClick(() => {
                            this.media.playNextAuto(true);
                        })
                }

                // 播放队列
                Image($r('app.media.ic_music_list'))
                    .fillColor($r('app.color.control_icon_color'))
                    .width($r('app.float.control_icon_width'))
                    .height($r('app.float.control_icon_height'))
                    .onClick(() => {
                        router.pushUrl({
                            url: RouterUrlConstants.PLAY_QUEUE
                        });
                    })
            } // Row
            .justifyContent(FlexAlign.SpaceBetween)

        } // Row
        .width('100%')
        .height($r('app.float.player_area_height'))
        .justifyContent(FlexAlign.SpaceBetween)

        .backgroundImage($r('app.media.ic_avatar2'))
        .backgroundImageSize(ImageSize.Cover)
        .backgroundBlurStyle(BlurStyle.Regular)
        .shadow({ radius: 10, color: 'rgba(150, 205, 205, 0.8)', offsetY: -2 })

        .padding({
            left: $r('app.float.player_padding'),
            right: $r('app.float.player_padding')
        })

    } // build
}
