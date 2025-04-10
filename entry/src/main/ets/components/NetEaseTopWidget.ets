import { HttpUtils } from '../common/network/HttpUtils';
import { MusicInfo } from '../model/MusicData';
import { MusicItem } from './MusicItem';
import { SongDataSource } from '../viewmodel/SongDataSource'
import { BaseNetEasePlayListViewModel } from '../viewmodel/BaseNetEasePlayListViewModel'
import ConnectionUtil from '../common/network/ConnectionUtils'
import promptAction from '@ohos.promptAction';
import { NetEasePlayListId } from '../common/constants/Netease';

@Preview
@Component
export struct NetEaseTopWidget {
    // @StorageLink('Play')
    @Link vb_top_list: BaseNetEasePlayListViewModel;
    @State isRefreshing: boolean = false
    songDataSource: SongDataSource = new SongDataSource();

    aboutToAppear() {
        console.log(`NetEaseTopWidget aboutToAppear`);
        // for (let i = 0; i <= 20; i++) {
        //     this.songDataSource.pushData(new MusicInfo(String(i)))
        // }

        this.vb_top_list.loadMusic().then(() => {
            console.log(`${this.vb_top_list.title} 加载成功`);
            // this.vb_top_list.debugInfo();
            for (let i = 0; i < this.vb_top_list.batchSize; i++) {
                this.songDataSource.pushData(this.vb_top_list.musicList[i]);
                console.log(`${this.vb_top_list.musicList[i]}`)
            }
        }).catch(() => {
            console.error(`${this.vb_top_list.title} 加载失败`);
        });
    }

    aboutToDisappear(): void {
        this.vb_top_list.destroy();
    }

    build() {
        Column() {
            // Header
            Row({ space: 5 }) {
                Text('播放列表')
                Image($r('app.media.ic_public_play_norm'))
                    .width(24)
                    .height(24)
                    .onClick(() => {
                        promptAction.showToast({
                            message: '播放 '
                        })
                    })
                Blank()
                Row() {
                    Text(this.vb_top_list.brief)
                    Image($r('app.media.refresh'))
                        .width(24)
                        .height(24)
                }
                .gesture(
                    LongPressGesture({ repeat: true })
                        .onAction((event: GestureEvent) => {
                            promptAction.showToast({ message: '点击刷新榜单' })
                        })
                )
                .onClick(() => {
                    ConnectionUtil.isNetworkConnected().then((ok) => {
                        if (ok) {
                            promptAction.showToast({
                                message: '正在刷新'
                            });
                            let http = new HttpUtils();
                            http.getNetEaseTop(NetEasePlayListId.ORIGINAL).then((data) => {
                                promptAction.showToast({
                                    message: '刷新成功'
                                });
                                for (let i = 0; i < data.length; ++i) {
                                    console.log(`${i}-${data[i]}`)
                                }
                                http.destroy();
                            });
                        } else {
                            promptAction.showToast({
                                message: '请检查网络连接'
                            });
                        }

                    });
                })

            }
            .width('100%')

            // 播放列表
            Refresh({ refreshing: $$this.isRefreshing }) {
                List() {
                    LazyForEach(this.songDataSource, (item: MusicInfo, index: number) => {
                        ListItem() {
                            Row() {
                                Text(`${index + 1}`)
                                    .textAlign(TextAlign.Center)// .width('10%')
                                    .width(50)
                                MusicItem({ data: item })// .width('90%')
                                    .layoutWeight(1)
                            }
                            .justifyContent(FlexAlign.Start)
                        }
                        .onAppear(() => {
                            console.log(`onAppear ${item.id}`);
                        })

                    })
                }
                .scrollBar(BarState.Off)
                .edgeEffect(EdgeEffect.Spring)
                .width('100%')
                .cachedCount(10)
                .onReachEnd(() => {
                    console.log(`到底了`);
                })
            }
            .onStateChange((state: RefreshStatus) => {
                switch (state) {
                    case RefreshStatus.Inactive:
                        console.log(`onStateChange Inactive`);
                        break;
                    case RefreshStatus.Drag:
                        console.log(`onStateChange Drag`);
                        break;
                    case RefreshStatus.OverDrag:
                        console.log(`onStateChange OverDrag`);
                        break;
                    case RefreshStatus.Done:
                        console.log(`onStateChange Done`);
                        promptAction.showToast({
                            message: '刷新完成'
                        });
                        break;
                }
            })
            .onRefreshing(() => {
                // Drag -> OverDrag -> Refreshing -> Done
                console.log(`onRefreshing`);
                setTimeout(() => {
                    this.isRefreshing = false;
                }, 2000);
            })
        } // Column
        .height('80%')
    } // build
}