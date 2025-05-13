import { HeaderWidget } from '../components/HeaderWidget';
import router from '@ohos.router';
import { RouterUrlConstants } from '../common/constants/RouterUrlConstants';
import { SettingCell } from '../components/SettingCell';
import { globalUser, UserViewModel } from '../viewmodel/UserViewModel'
import { PlaylistData } from '../model/PlaylistData';

@Preview
@Component
export struct MyContent {
    @State viewModel: UserViewModel = globalUser;
    @State qqPlaylist: PlaylistData[] = [];
    @State neteasePlaylist: PlaylistData[] = [];
    @StorageProp('isLogged') @Watch('onLogged') isLogged: boolean = false;

    async onLogged() {
        await this.viewModel.loadPlaylist();
        this.qqPlaylist = globalUser.qqPlaylists;
        this.neteasePlaylist = globalUser.neteasePlaylists;
    }

    build() {
        Column() {
            HeaderWidget({ title: '我的' })

            // 用户信息
            Row() {
                if (this.isLogged) {
                    Row() {
                        Image(this.viewModel.avatar())
                            .alt($r('app.media.default_singer')).width(64).height(64).borderRadius(32)
                        Column() {
                            Text(this.viewModel.username).fontSize(28)
                            Text(this.viewModel.email).fontSize(18).margin({ top: 4 })
                        }
                        .alignItems(HorizontalAlign.Start)
                        .margin({ left: 12 })
                    }
                } else {
                    Button('立即登录')
                        .type(ButtonType.Capsule).width(200)
                        .onClick(() => {
                            router.pushUrl({
                                url: RouterUrlConstants.LOGIN
                            });
                        })
                }
            } // Row
            .alignItems(VerticalAlign.Center)
            .justifyContent(FlexAlign.Center)
            .width('100%')

            SettingCell({
                text: '个人资料',
                pushUrl: RouterUrlConstants.PROFILE,
                needLogin: true,
                image: $r('app.media.default_singer')
            })
            this.splitter();
            SettingCell({ pushUrl: RouterUrlConstants.RECENT, text: '最近播放', image: $r('app.media.recent') })

            // 网易云歌单 QQ音乐歌单
            Scroll() {
                Column() {
                    if (this.isLogged) {
                        if (this.viewModel.qq_id) {
                            Text('QQ音乐歌单').fontSize(25)
                            this.splitter()
                            ForEach(this.qqPlaylist, item => {
                                this.PlaylistItem(item, 'qq');
                            });
                        }

                        if (this.viewModel.netease_id) {
                            Text('网易云音乐歌单').fontSize(25)
                            this.splitter()
                            ForEach(this.neteasePlaylist, item => {
                                this.PlaylistItem(item, 'netease');
                            });
                        }
                    }
                }
            }
            .layoutWeight(1)
            .scrollable(ScrollDirection.Vertical)
            .scrollBar(BarState.Off)
            .width('100%')
            .align(Alignment.Top)

            Row().height(50)
        } // Column
        .justifyContent(FlexAlign.Start)
        .width('100%')
    } // build

    @Builder
    splitter() {
        Line()
            .width('90%')
            .height(2)
            .borderRadius(1)
            .backgroundColor('rgba(0, 0, 0, 0.25)')
            .margin({ top: 5, bottom: 5 })
    }

    // 显示歌单项
    @Builder
    PlaylistItem(item: PlaylistData, platform: string) {
        Row() {
            Image(item.cover).alt($r('app.media.default_cover_rect')).width(50).height(50).borderRadius(8)

            Column() {
                Text(item.name).fontSize(16).fontWeight(FontWeight.Medium).margin({ bottom: 4 })

                Row() {
                    Image(platform === 'qq' ? $r('app.media.icon_qqmusic') : $r('app.media.icon_netease'))
                        .width(16).height(16).margin({ right: 4 })

                    Text(`${item.count || 0}首`).fontSize(14).fontColor('#888')
                }
            }
            .margin({ left: 10 })
            .alignItems(HorizontalAlign.Start)
            .layoutWeight(1)
        }
        .width('95%')
        .margin({ left: 10, bottom: 10, right: 10 })
        .borderRadius(20)
        .height(60)
        .padding(10)
        .stateStyles({
            normal: {
                .backgroundColor(Color.Transparent)
            },
            pressed: {
                .backgroundColor("#BDBDBD")
            }
        })
        .onClick(() => {
            router.pushUrl({
                url: RouterUrlConstants.PLAYLIST,
                params: {
                    id: item.id,
                    platform: platform,
                    name: item.name,
                    count: item.count
                }
            });
        })
    }
}