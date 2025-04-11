import { MusicInfo } from '../model/MusicData';
import { MusicItem } from './MusicItem';
import { BaseNetEaseLongListViewModel } from '../viewmodel/BaseNetEaseLongListViewModel'
import ConnectionUtil from '../common/network/ConnectionUtils'
import promptAction from '@ohos.promptAction';
import { NetEasePlayListId } from '../common/constants/Netease';

@Preview
@Component
export struct NetEaseTopWidget {
    // @StorageLink('Play')
    @Link vb_top_list: BaseNetEaseLongListViewModel;
    @State isRefreshing: boolean = false

    aboutToAppear() {
        console.log(`NetEaseTopWidget aboutToAppear`);
        // 首次加载
        this.vb_top_list.loadMusicFirst();
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
                }

            }
            .width('100%')

            // 播放列表
            Refresh({ refreshing: $$this.isRefreshing }) {
                List() {
                    LazyForEach(this.vb_top_list.songDataSource, (item: MusicInfo, index: number) => {
                        ListItem() {
                            Row() {
                                Text(`${index + 1}`)
                                    .textAlign(TextAlign.Center)// .width('10%')
                                    .width(50)
                                MusicItem({ data: item, showCover: !(index >= 3) })// .width('90%')
                                    // MusicItem({ data: item })// .width('90%')
                                    .layoutWeight(1)
                            }
                            .justifyContent(FlexAlign.Start)
                        }

                        // .onAppear(() => {
                        // })
                    })
                }
                .scrollBar(BarState.Off)
                .edgeEffect(EdgeEffect.Spring)
                .width('100%')
                .cachedCount(10)
                .onReachEnd(() => {
                    // 触底动态加载
                    let cnt: number = this.vb_top_list.loadMusicNonFirst();
                    if (cnt > 0) {
                        promptAction.showToast({ message: `${cnt}首加载成功` })
                    } else {
                        promptAction.showToast({ message: "已加载全部" })
                    }
                })

            }
            .onStateChange((state: RefreshStatus) => {
                switch (state) {
                    case RefreshStatus.Inactive:
                        break;
                    case RefreshStatus.Drag:
                        break;
                    case RefreshStatus.OverDrag:
                        break;
                    case RefreshStatus.Done:
                        promptAction.showToast({
                            message: '刷新完成'
                        });
                        break;
                }
            })
            .onRefreshing(async () => {
                // Drag -> OverDrag -> Refreshing -> Done
                this.vb_top_list.refreshMusic();
                this.isRefreshing = false;
            })
        } // Column
        .height('80%')
    } // build
}