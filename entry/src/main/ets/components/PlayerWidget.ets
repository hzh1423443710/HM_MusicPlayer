import { MusicFrom, MusicInfo, PlayListType } from '../model/MusicData'
import { PlayerConstants } from '../common/constants/PlayerConstants'
import { MusicListData } from '../viewmodel/MusicDataViewModel'
import router from '@ohos.router';
import { RouterUrlConstants } from '../common/constants/RouterUrlConstants';
import { StyleConstants } from '../common/constants/StyleConstants';
import { MediaService } from '../common/MediaService';
import promptAction from '@ohos.promptAction';

// 播放控制
@Preview
@Component
export struct PlayerWidget {
    // 正在播放的索引
    @StorageProp('selectIndex') selectIndex: number = 0;
    // 正在播放
    @StorageLink('isPlay') @Watch('onPlay') isPlay: boolean = false;
    @State music: MusicInfo = new MusicInfo();
    // 封面图片旋转
    @State imageRotate: number = 0;

    aboutToAppear(): void {
        MediaService.getInstance();
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
                // router.pushUrl({
                //     url: RouterUrlConstants.PLAY
                // });

                // debug
                const media = MediaService.getInstance();
                media.debugPlayQueue();
                media.debugPlaylist(PlayListType.NETEASE_RANDOM_SONG);
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
                        console.log('播放');
                        if (MediaService.getInstance().getCurrentPlaylistType() === PlayListType.NONE) {
                            promptAction.showToast({ message: '播放队列为空', bottom: 600 })
                        } else {
                            this.isPlay ? MediaService.getInstance().pause() : MediaService.getInstance().play();
                        }
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
                Image($r('app.media.ic_music_list'))
                    .fillColor($r('app.color.control_icon_color'))
                    .width($r('app.float.control_icon_width'))
                    .height($r('app.float.control_icon_height'))
                    .displayPriority(PlayerConstants.DISPLAY_PRIORITY_ONE)
            } // Row
            .justifyContent(FlexAlign.SpaceBetween)

        } // Row
        .width(StyleConstants.FULL_WIDTH)
        .height($r('app.float.player_area_height'))
        .justifyContent(FlexAlign.SpaceBetween)

        .borderRadius(5)
        .backgroundImage($r('app.media.ic_avatar2'))
        .backgroundImageSize(ImageSize.Cover)
        .backgroundBlurStyle(BlurStyle.Regular)

        .padding({
            left: $r('app.float.player_padding'),
            right: $r('app.float.player_padding')
        })
        .position({
            x: 0,
            y: StyleConstants.FULL_HEIGHT
        })
        .translate({
            x: 0,
            y: StyleConstants.TRANSLATE_PLAYER_Y
        })

    } // build
}
