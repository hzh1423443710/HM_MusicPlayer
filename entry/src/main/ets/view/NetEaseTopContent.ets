import { NetEaseTopWidget } from '../components/NetEaseTopWidget';
import {
    topSurgeViewModel,
    topNewViewModel,
    topOriginalViewModel,
    topHotViewModel,
    NetEaseTopSurgeViewModel,
    NetEaseTopNewViewModel,
    NetEaseTopOriginalViewModel,
    NetEaseTopHotViewModel
} from '../viewmodel/NetEasePlayListViewModel'
import { BaseNetEasePlayListViewModel } from '../viewmodel/BaseNetEasePlayListViewModel'


@Preview
@Component
export struct NetEaseTopContent {
    @State currentIndex: number = 0;
    // 原创榜
    @State vb_original: NetEaseTopOriginalViewModel = topOriginalViewModel;
    // 热歌榜
    @State vb_hot: NetEaseTopHotViewModel = topHotViewModel;
    // 飙升榜
    @State vb_surge: NetEaseTopSurgeViewModel = topSurgeViewModel;
    // 新歌榜
    @State vb_new: NetEaseTopNewViewModel = topNewViewModel;

    aboutToAppear(): void {
    }

    build() {
        Column() {
            Row() {
                Text('榜单')
                    .focusable(true)
                    .fontSize($r('app.float.tab_content_title'))
                    .fontWeight(FontWeight.Bold)
            }
            .width('100%')
            .alignItems(VerticalAlign.Top)

            Tabs() {
                // 1.原创榜
                TabContent() {
                    NetEaseTopWidget({ vb_top_list:$vb_original })
                }
                .tabBar(this.vb_original.title)
                .tabIndex(0)
                .align(Alignment.Top)

                // 2.热歌榜
                TabContent() {
                }
                .tabBar(this.vb_original.title)
                .tabIndex(1)
                .align(Alignment.Top)

                // 3.飙升榜
                TabContent() {
                }
                .tabBar(this.vb_original.title)
                .tabIndex(2)
                .align(Alignment.Top)

                // 4.新歌榜
                TabContent() {
                }
                .tabBar(this.vb_original.title)
                .tabIndex(3)
                .align(Alignment.Top)

            } // Tabs
            .barPosition(BarPosition.Start)
            .scrollable(true)
            .backgroundImage($r('app.media.ic_avatar3'))
            .backgroundImageSize(ImageSize.Cover)
            .backgroundBlurStyle(BlurStyle.Regular)
            .onChange((index: number) => {
                this.currentIndex = index;
            })

        } // Column

    }
}