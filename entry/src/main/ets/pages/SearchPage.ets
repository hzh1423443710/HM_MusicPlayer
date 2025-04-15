import router from '@ohos.router';
import { PlayerWidget } from '../components/PlayerWidget';
import { HeaderWidget } from '../components/HeaderWidget';
import { SearchState, SearchType, MusicPlatform, SearchViewModel, searchViewModel } from '../viewmodel/SearchViewModel'
import { MusicInfo, PlaylistType } from '../model/MusicData';
import { MusicItem } from '../components/MusicItem';
import { MediaService } from '../common/MediaService';
import promptAction from '@ohos.promptAction';
import { SingerItem } from '../components/SingerItem';
import { SingerInfo } from '../model/SingerData';

@Entry
@Component
struct SearchPage {
    @State currentTabIndex: number = 0
    @State isRefreshing: boolean = false;
    @State viewModel: SearchViewModel = searchViewModel;

    aboutToAppear(): void {
        console.log(`SearchPage`)
        // 清空上次结果
        this.viewModel.resetAll();
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

                    if (this.viewModel.canSwitchPlatform()) {
                        Toggle({ type: ToggleType.Switch })
                            .onClick(() => {
                                this.viewModel.switchPlatform();
                            })
                    }

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
                Tabs() {
                    // 1.歌曲结果
                    TabContent() {
                        Column() {
                            if (this.viewModel.searchState === SearchState.SEARCHING && this.viewModel.songDataSource.totalCount() === 0) {
                                Text('搜索中')
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
                                                Text(`${index + 1}`)
                                                    .textAlign(TextAlign.Center)
                                                    .width(50)
                                                MusicItem({ song: song, showCover: false })
                                                    .onClick(() => {
                                                        MediaService.getInstance()
                                                            .playOne(song, this.viewModel.songDataSource.items, PlaylistType.SEARCH);
                                                    })
                                            }
                                            .justifyContent(FlexAlign.Start)
                                        } // ListItem
                                    })
                                } // List

                                // TODO 为什么加载一次后就不显示了
                                if (this.viewModel.hasMore)
                                    this.LoadMore()
                            }
                        }
                        .width('100%')
                        .height('100%')

                    }
                    .tabBar(this.TabBuilder(0, '歌曲', $r('app.media.song')))
                    .tabIndex(0)

                    // 2.歌手结果
                    TabContent() {
                        Column() {
                            if (this.viewModel.searchState === SearchState.SEARCHING && this.viewModel.singerDataSource.totalCount() === 0) {
                                Text('搜索中')
                                LoadingProgress()
                                    .width(30)
                                    .height(30)
                            } else if (this.viewModel.searchState === SearchState.EMPTY) {
                                Text(this.viewModel.getStateText())
                            } else if (this.viewModel.singerDataSource.totalCount() > 0) {
                                List() {
                                    LazyForEach(this.viewModel.singerDataSource, (singer: SingerInfo, index: number) => {
                                        ListItem() {
                                            Column() {
                                                Row() {
                                                    Text(`${index + 1}`)
                                                        .textAlign(TextAlign.Center)
                                                        .width(50)
                                                    SingerItem({ singer: singer })
                                                        .onClick(() => {
                                                            // 歌手歌曲页面
                                                        })
                                                }
                                                .justifyContent(FlexAlign.Start)

                                                Divider()
                                                    .strokeWidth(1)
                                                    .width('90%')
                                                    .backgroundColor(Color.Gray)
                                                    .opacity($r('app.float.singer_opacity'))
                                            }
                                        } // ListItem
                                    })
                                } // List

                                // TODO 为什么加载一次后就不显示了
                                if (this.viewModel.hasMore)
                                    this.LoadMore()
                            }
                        }
                        .width('100%')
                        .height('100%')
                    }
                    .tabBar(this.TabBuilder(1, '歌手', $r('app.media.singer')))
                    .tabIndex(1)

                } // Tabs
                .vertical(false)
                .onChange((index: number) => {
                    this.currentTabIndex = index
                    const old_platform = this.viewModel.platform;
                    this.viewModel.setSearchType(index as SearchType);

                    if (this.viewModel.searchType === SearchType.SONG) {
                        // TODO small bug
                        if (this.viewModel.songDataSource.totalCount() === 0)
                            this.viewModel.search(true);
                    }
                    else {
                        if (this.viewModel.singerDataSource.totalCount() === 0)
                            this.viewModel.search(true);
                    }
                })
            } // Column
            .layoutWeight(1)

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
    LoadMore() {
        Row() {
            Line()
                .width(100)
                .height(1)
                .backgroundColor(Color.Gray)

            Text('载入更多')
                .fontColor('#007DFF')
                .fontSize('14fp')
                .fontWeight(FontWeight.Medium)
                .margin({ left: 10, right: 10 })
                .onClick(() => {
                    promptAction.showToast({ message: '正在加载' });
                    this.viewModel.loadMore().then((ok) => {
                        promptAction.showToast({ message: ok ? '加载成功' : this.viewModel.getStateText() });
                        promptAction.showToast({ message: this.viewModel.hasMore ? '还有更多' : '已加载全部' });
                    });
                })

            Line()
                .width(100)
                .height(1)
                .backgroundColor(Color.Gray)

        }
        .justifyContent(FlexAlign.SpaceBetween)
    }

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