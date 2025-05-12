import { RandPlayWidget } from '../components/RandPlayWidget';
import { randPlayViewModel, RandPlayViewModel } from '../viewmodel/RandPlayViewModel'
import { HeaderWidget } from '../components/HeaderWidget';
import { SwiperListWidget } from '../components/SwiperListWidget';
import {
    EveryLikeListViewModel,
    everyLikeListViewModel,
    TreasureMusicViewModel,
    treasureMusicViewModel
} from '../viewmodel/NetEaseSwiperListViewModel'
import router from '@ohos.router';
import promptAction from '@ohos.promptAction';
import { RouterUrlConstants } from '../common/constants/RouterUrlConstants';
import { MediaService } from '../common/MediaService';
import { PlaylistType } from '../model/MusicData';

@Preview
@Component
export struct HomePageContent {
    @State vb_rand_play: RandPlayViewModel = randPlayViewModel;
    @State vb_every_like: EveryLikeListViewModel = everyLikeListViewModel;
    @State vb_treasure_music: TreasureMusicViewModel = treasureMusicViewModel;

    build() {
        Column({ space: 5 }) {
            // 1.标题
            HeaderWidget({ title: '首页' })

            // 2.模拟搜索栏
            Row() {
                Image($r('app.media.search'))
                    .width(20)
                    .height(20)
                    .margin({ left: 10, right: 10 })

                Text('搜索')
                    .fontSize(16)
                    .height(20)
                    .opacity(0.6)
                Blank()
            }
            .borderWidth(1)
            .borderRadius(20)
            .height(40)
            .width('85%')
            .borderColor(Color.Brown)
            .backgroundColor(Color.White)
            .onClick(() => {
                router.pushUrl({
                    url: RouterUrlConstants.SEARCH,
                });
            })

            // 3.播放列表
            Scroll() {
                Column() {
                    // 随机播放一曲
                    RandPlayWidget({ viewModel: $vb_rand_play })
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

        } // Column
        .alignItems(HorizontalAlign.Start)
        .justifyContent(FlexAlign.Start)
    } // build
}