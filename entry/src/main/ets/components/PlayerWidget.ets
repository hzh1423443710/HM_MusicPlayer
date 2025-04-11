import { MusicInfo, PlayListType } from '../model/MusicData'
import { PlayerConstants } from '../common/constants/PlayerConstants'
import { MusicListData } from '../viewmodel/MusicDataViewModel'
import router from '@ohos.router';
import { RouterUrlConstants } from '../common/constants/RouterUrlConstants';
import { StyleConstants } from '../common/constants/StyleConstants';

// 播放控制
@Preview
@Component
export struct PlayerWidget {
    // 正在播放的索引
    @StorageProp('selectIndex') selectIndex: number = 0;
    // 正在播放
    @StorageLink('isPlay') @Watch('animationFunc') isPlay: boolean = false;
    // 播放列表
    songList: MusicInfo[] = MusicListData;
    // 封面图片旋转
    @State imageRotate: number = 0;

    // 封面旋转动画
    animationFunc(): void {
        this.imageRotate = 0;
        this.imageRotate = this.isPlay ? PlayerConstants.ROTATE : 0;
    }

    build() {
        Row() {
            // 封面+歌名+歌手
            Row() {
                // 封面
                Image(this.songList[this.selectIndex].pic)
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
                    .onAppear(() => {
                        this.animationFunc();
                    })

                Column() {
                    // 歌名
                    Text(this.songList[this.selectIndex].name)
                        .fontColor($r('app.color.song_name'))
                        .fontSize(18)
                        .maxLines(1)
                    // 歌手
                    Row() {
                        Image(this.songList[this.selectIndex].pay ? $r('app.media.ic_vip') : $r('app.media.ic_sq'))
                            .height($r('app.float.vip_icon_height'))
                            .width($r('app.float.vip_icon_width'))
                            .margin({ right: $r('app.float.vip_icon_margin') })
                        Text(this.songList[this.selectIndex].singer)
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
                    url: RouterUrlConstants.MUSIC_PLAY
                }, router.RouterMode.Single)
            })

            // 空白
            Blank()
                .onClick(() => {
                    console.log('click blank');
                    router.pushUrl({
                        url: RouterUrlConstants.MUSIC_PLAY
                    }, router.RouterMode.Single)
                })

            // 播放控制
            Row() {
                Image($r('app.media.ic_public_play_last'))
                    .fillColor($r('app.color.control_icon_color'))
                    .width($r('app.float.control_icon_width'))
                    .height($r('app.float.control_icon_height'))
                    .displayPriority(PlayerConstants.DISPLAY_PRIORITY_TWO)
                    .onClick(() => {
                        console.log('上一首');
                    })
                Image(this.isPlay ? $r('app.media.ic_public_pause') : $r('app.media.ic_public_play'))
                    .fillColor($r('app.color.control_icon_color'))
                    .width($r('app.float.control_icon_width'))
                    .height($r('app.float.control_icon_height'))
                    .margin({ left: $r('app.float.control_icon_margin'), right: $r('app.float.control_icon_margin') })
                    .displayPriority(PlayerConstants.DISPLAY_PRIORITY_THREE)
                    .onClick(() => {
                        console.log('播放');
                        if (this.songList.length === 0)
                            AppStorage.SetOrCreate<boolean>('isPlay',!this.isPlay);
                        else {
                            switch (this.songList[0].playList) {
                                case PlayListType.RECENT:
                                    AppStorage.SetOrCreate<boolean>('isPlay',!this.isPlay);
                                    break;
                                case PlayListType.QQ_SEARCH:
                                    AppStorage.SetOrCreate<boolean>('isPlay-SEARCH',!this.isPlay);
                                    break;
                                case PlayListType.NETEASE_LISTEN_HOT:
                                    AppStorage.SetOrCreate<boolean>('isPlay-LISTEN_HOT',!this.isPlay);
                                    break;
                                case PlayListType.NETEASE_NETWORK_HOT:
                                    AppStorage.SetOrCreate<boolean>('isPlay-NETWORK_HOT',!this.isPlay);
                                    break;
                            }
                        }

                    })
                Image($r('app.media.ic_public_play_next'))
                    .fillColor($r('app.color.control_icon_color'))
                    .width($r('app.float.control_icon_width'))
                    .height($r('app.float.control_icon_height'))
                    .margin({ right: $r('app.float.control_icon_margin') })
                    .displayPriority(PlayerConstants.DISPLAY_PRIORITY_TWO)
                    .onClick(() => {
                        console.log('下一首');
                    })
                Image($r('app.media.ic_music_list'))
                    .fillColor($r('app.color.control_icon_color'))
                    .width($r('app.float.control_icon_width'))
                    .height($r('app.float.control_icon_height'))
                    .displayPriority(PlayerConstants.DISPLAY_PRIORITY_ONE)
            } // Row
            .justifyContent(FlexAlign.End)

        } // Row
        .width(StyleConstants.FULL_WIDTH)
        .height($r('app.float.player_area_height'))

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
