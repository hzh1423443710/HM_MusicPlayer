import router from '@ohos.router';
import { PlayerWidget } from '../components/PlayerWidget';
import { HeaderWidget } from '../components/HeaderWidget';
import { SearchState, MusicPlatform, SearchViewModel, searchViewModel } from '../viewmodel/SearchViewModel'
import { MusicInfo, PlaylistType } from '../model/MusicData';
import { MusicItem } from '../components/MusicItem';
import { MediaService, PlayerState } from '../common/MediaService';
import promptAction from '@ohos.promptAction';

@Entry
@Component
struct SearchPage {
    @State currentTabIndex: number = 0
    @State isRefreshing: boolean = false;
    @State viewModel: SearchViewModel = searchViewModel;
    @StorageProp('playState') @Watch('onPlayStateChanged') playState: PlayerState = PlayerState.IDLE;
    @State currentMusic: MusicInfo = new MusicInfo();
    media: MediaService = MediaService.getInstance();

    aboutToAppear(): void {
        console.log(`SearchPage appear`)
        // 清空上次结果
        this.viewModel.resetAll();
    }

    onPlayStateChanged() {
        this.currentMusic = this.media.getCurrentMusic();
    }

    aboutToDisappear(): void {
        console.log(`SearchPage Disappear`)
    }

    build() {
        Column() {
            // 顶部区域
            Column() {
                HeaderWidget({ title: '' })

                // 搜索栏
                Row({ space: 10 }) {
                    Image($r('app.media.ic_public_back'))
                        .width(32)
                        .height(32)
                        .onClick(() => {
                            router.back();
                        })

                    Search({ placeholder: '搜索' })
                        .borderWidth(1)
                        .borderColor(Color.Brown)
                        .layoutWeight(1)
                        .backgroundColor(Color.White)
                        .onSubmit((value: string) => {
                            this.viewModel.setKeyword(value);
                            this.viewModel.search();
                        })


                    Image(this.viewModel.platform === MusicPlatform.NETEASE ? $r('app.media.icon_netease') : $r('app.media.icon_qqmusic'))
                        .width(24)
                        .height(24)

                    Toggle({ type: ToggleType.Switch })
                        .onClick(() => {
                            this.viewModel.switchPlatform();
                        })

                    Image($r('app.media.refresh'))
                        .width(28)
                        .height(28)
                        .margin({ right: 10 })
                        .onClick(() => {
                            this.viewModel.refresh()
                                .then((ok) => {
                                    if (!ok)
                                        promptAction.showToast({ message: this.viewModel.getStateText() });
                                });
                        })
                }
                .justifyContent(FlexAlign.Start)
                .alignItems(VerticalAlign.Center)
            }

            // 中间内容区域 - 使用layoutWeight占据剩余空间
            Column() {
                if (this.viewModel.searchState === SearchState.SEARCHING && this.viewModel.songDataSource.totalCount() === 0) {
                    Text(this.viewModel.getStateText())
                    LoadingProgress()
                        .width(30)
                        .height(30)
                } else if (this.viewModel.searchState === SearchState.EMPTY) {
                    Text(this.viewModel.getStateText())
                } else if (this.viewModel.songDataSource.totalCount() > 0) {
                    List() {
                        LazyForEach(this.viewModel.songDataSource, (song: MusicInfo, index: number) => {
                            ListItem() {
                                Row() {
                                    MusicItem({ index: index + 1, song: song, showCover: false })
                                        .onClick(() => {
                                            this.media.playOne(song, this.viewModel.songDataSource.items, PlaylistType.SEARCH);
                                        })
                                }
                                .justifyContent(FlexAlign.Start)
                            } // ListItem
                            .backgroundColor(this.currentMusic.equals(song) ? $r('app.color.selected') : Color.Transparent)
                        })
                    } // List
                    .onReachEnd(() => {
                        promptAction.showToast({ message: '正在加载' });
                        this.viewModel.loadMore().then((ok) => {
                            promptAction.showToast({
                                message: ok ? '加载成功' : this.viewModel.getStateText()
                            });
                        });
                    })

                }
            }
            .width('100%')
            .height('100%')

            // 底部固定的播放器区域
            PlayerWidget()
        } // Column
        .width('100%')
        .height('100%')
        .backgroundImage($r('app.media.ic_avatar3'))
        .backgroundImageSize(ImageSize.Cover)
        .backgroundBlurStyle(BlurStyle.Regular)
    } // build

    @Builder
    TabBuilder(index: number, name: string, image: Resource) {
        Column() {
            Row({ space: 5 }) {
                Image(image)
                    .size({ width: 28, height: 28 })
                Text(name)
                    .fontColor(this.currentTabIndex === index ? $r('app.color.tab_font_selected_color') : $r('app.color.tab_font_color'))
                    .fontSize(22)
                    .fontWeight(this.currentTabIndex === index ? 500 : 400)
                    .lineHeight(25)
                    .margin({ top: 17, bottom: 7 })
            }
            .alignItems(VerticalAlign.Center)

            Divider()
                .strokeWidth(2)
                .color('#007DFF')
                .opacity(this.currentTabIndex === index ? 1 : 0)
                .width(100)
        }.width('100%')
    }
}