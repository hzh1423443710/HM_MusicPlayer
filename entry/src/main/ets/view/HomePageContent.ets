import { RandPlayWidget } from '../components/RandPlayWidget';
import { randPlayViewModel, RandPlayViewModel } from '../viewmodel/RandPlayViewModel'
import { HeaderWidget } from '../components/Header';
import { SearchWidget } from '../components/SearchMusic';
import { SwiperListWidget } from '../components/SwiperListWidget';
import {
    EveryLikeListViewModel,
    everyLikeListViewModel,
    TreasureMusicViewModel,
    treasureMusicViewModel
} from '../viewmodel/NetEasePlayListViewModel'

@Preview
@Component
export struct HomePageContent {
    @State @Watch('onRandPlayChanged') vb_rand_play: RandPlayViewModel = randPlayViewModel;
    @State @Watch('onEveryLikeListChanged') vb_every_like: EveryLikeListViewModel = everyLikeListViewModel;
    @State @Watch('onTreasureMusicChanged') vb_treasure_music: TreasureMusicViewModel = treasureMusicViewModel;

    onRandPlayChanged() {
        console.log(`onRandPlayChanged:`)
    }

    onEveryLikeListChanged() {
        console.log(`onEveryLikeListChanged:`)
    }

    onTreasureMusicChanged() {
        console.log(`onTreasureMusicChanged:`)
    }

    aboutToAppear() {
        console.log('HomePageContent aboutToAppear')
    }

    aboutToDisappear() {
    }

    build() {
        Column() {
            // 标题
            HeaderWidget({ title: '首页' })
            // 搜索
            SearchWidget()
            // 播放列表
            Scroll() {
                Column({ space: 10 }) {
                    // 随机播放一曲
                    RandPlayWidget({ vb_rand_play: $vb_rand_play })
                    // 大家都爱听（听歌识曲榜 每周四更新）
                    SwiperListWidget({ viewModel: $vb_every_like })
                    // 宝藏歌曲 (网络热歌榜 每周五更新)
                    SwiperListWidget({ viewModel: $vb_treasure_music })
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