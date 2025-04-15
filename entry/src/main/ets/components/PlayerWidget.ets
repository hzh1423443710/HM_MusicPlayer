import { MusicInfo, PlaylistType } from '../model/MusicData'
import { PlayerConstants } from '../common/constants/PlayerConstants'
import router from '@ohos.router';
import { RouterUrlConstants } from '../common/constants/RouterUrlConstants';
import { MediaService } from '../common/MediaService';
import promptAction from '@ohos.promptAction';
import pasteboard from '@ohos.pasteboard';

/**
 * 与MediaService 组成 MVVM 状态显示
 */
// 播放控制
@Preview
@Component
export struct PlayerWidget {
    @State music: MusicInfo = new MusicInfo(0, '', '鸿蒙音乐 听我想听');
    @StorageLink('isPlay') @Watch('onPlay') isPlay: boolean = false;
    @StorageProp('updateUITrigger') @Watch('onUpdateUITrigger') updateUI: number = 0;
    // 封面图片旋转
    @State imageRotate: number = 0;

    aboutToAppear(): void {
        MediaService.getInstance();
    }

    onUpdateUITrigger() {
        this.music = MediaService.getInstance().getCurrentMusic();
    }

    onPlay(): void {
        // 封面旋转动画
        this.imageRotate = 0;
        this.imageRotate = this.isPlay ? PlayerConstants.ROTATE : 0;

        // 更新UI显示
        const music = MediaService.getInstance().getCurrentMusic();
        if (music && music != this.music) {
            this.music = music;
        }
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
                        duration: PlayerConstants.ANIMATION_DURATION,
                        iterations: PlayerConstants.ITERATIONS,
                        curve: Curve.Linear
                    })

                Column() {
                    // 歌名
                    Marquee({ start: this.isPlay, src: this.music.name })
                        .width(150)
                        .fontColor($r('app.color.song_name'))
                        .fontSize(18)
                        .borderWidth(1)
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
            .layoutWeight(PlayerConstants.LAYOUT_WEIGHT_PLAYER_CONTROL)
            .onClick(() => {
                // 歌词page
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
                Image($r('app.media.ic_public_play_last'))
                    .fillColor($r('app.color.control_icon_color'))
                    .width($r('app.float.control_icon_width'))
                    .height($r('app.float.control_icon_height'))
                    .displayPriority(PlayerConstants.DISPLAY_PRIORITY_TWO)
                    .onClick(() => {
                        MediaService.getInstance().playPrevious();
                    })
                Image(this.isPlay ? $r('app.media.ic_public_pause') : $r('app.media.ic_public_play'))
                    .fillColor($r('app.color.control_icon_color'))
                    .width($r('app.float.control_icon_width'))
                    .height($r('app.float.control_icon_height'))
                    .margin({ left: $r('app.float.control_icon_margin'), right: $r('app.float.control_icon_margin') })
                    .displayPriority(PlayerConstants.DISPLAY_PRIORITY_THREE)
                    .onClick(() => {
                        const media = MediaService.getInstance();
                        media.debugState();

                        if (media.getCurrentPlaylistType() === PlaylistType.NONE) {
                            promptAction.showToast({ message: '播放队列为空' })
                            return;
                        }

                        if (media.getCurrentMusic().pay) {
                            promptAction.showToast({ message: 'VIP歌曲无法播放' });
                            return;
                        }

                        // 遇到不能试听的VIP歌曲 -> idle
                        if (media.idle()) {
                            media.rePlay();
                            return;
                        }

                        this.isPlay ? media.pause() : media.play();
                    })
                Image($r('app.media.ic_public_play_next'))
                    .fillColor($r('app.color.control_icon_color'))
                    .width($r('app.float.control_icon_width'))
                    .height($r('app.float.control_icon_height'))
                    .margin({ right: $r('app.float.control_icon_margin') })
                    .displayPriority(PlayerConstants.DISPLAY_PRIORITY_TWO)
                    .onClick(() => {
                        MediaService.getInstance().playNextAuto(true);
                    })

                // 播放队列
                Image($r('app.media.ic_music_list'))
                    .fillColor($r('app.color.control_icon_color'))
                    .width($r('app.float.control_icon_width'))
                    .height($r('app.float.control_icon_height'))
                    .displayPriority(PlayerConstants.DISPLAY_PRIORITY_ONE)
                    .onClick(() => {
                        // debug
                        const media = MediaService.getInstance();
                        media.debugPlayQueue();
                        media.debugPlaylist(media.getCurrentPlaylistType());

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
