import { RandPlayWidget } from '../components/RandPlayWidget';
import { randPlayViewModel, RandPlayViewModel } from '../viewmodel/RandPlayViewModel'
import { HeaderWidget } from '../components/Header';
import { SwiperListWidget } from '../components/SwiperListWidget';
import {
    EveryLikeListViewModel,
    everyLikeListViewModel,
    TreasureMusicViewModel,
    treasureMusicViewModel
} from '../viewmodel/NetEasePlayListViewModel'
import router from '@ohos.router';
import promptAction from '@ohos.promptAction';

@Preview
@Component
export struct HomePageContent {
    @State @Watch('onRandPlayChanged') vb_rand_play: RandPlayViewModel = randPlayViewModel;
    @State @Watch('onEveryLikeListChanged') vb_every_like: EveryLikeListViewModel = everyLikeListViewModel;
    @State @Watch('onTreasureMusicChanged') vb_treasure_music: TreasureMusicViewModel = treasureMusicViewModel;
    @State isRefreshing: boolean = false

    onRandPlayChanged() {
        // console.log(`onRandPlayChanged:`)
    }

    onEveryLikeListChanged() {
        // console.log(`onEveryLikeListChanged:`)
    }

    onTreasureMusicChanged() {
        // console.log(`onTreasureMusicChanged:`)
    }

    aboutToAppear() {
        console.log('HomePageContent aboutToAppear')
    }

    aboutToDisappear() {
    }

    build() {
        Column() {
            // 1.标题
            HeaderWidget({ title: '首页' })

            // 2.搜索
            Search({ placeholder: '搜索' })
                .borderWidth(1)
                .borderColor(Color.Brown)
                .width('85%')
                .backgroundColor(Color.White)
                .onSubmit((value: string) => {
                    router.pushUrl({
                        url: "pages/SearchPage",
                        params: {
                            inputText: value
                        }
                    })
                })

            // 3.播放列表
            Refresh({ refreshing: $$this.isRefreshing }) {
                Scroll() {
                    Column() {
                        // 随机播放一曲
                        RandPlayWidget({ vb_rand_play: $vb_rand_play })
                        // 大家都爱听（听歌识曲榜 每周四更新）
                        SwiperListWidget({ viewModel: $vb_every_like })
                        // 宝藏歌曲 (网络热歌榜 每周五更新)
                        SwiperListWidget({ viewModel: $vb_treasure_music })

                        // 防止下面看不见
                        Row()
                            .backgroundColor(Color.Transparent)
                            .width('100%')
                            .height(150)
                    }
                    .alignItems(HorizontalAlign.Start)
                    .justifyContent(FlexAlign.Start)
                }
                .scrollBar(BarState.Off)
                .edgeEffect(EdgeEffect.Spring)
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
            .onRefreshing(() => {
                // 更新
                this.vb_rand_play.loadMusic().then(() => {
                    this.isRefreshing = false;
                });
            })

        } // Column
        .alignItems(HorizontalAlign.Start)
        .justifyContent(FlexAlign.Start)
    } // build
}