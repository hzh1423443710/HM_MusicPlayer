import { NetEaseTopWidget } from '../components/NetEaseTopWidget';
import {
    NetEaseTopListViewModel,
    originalTopListViewModel,
    newEaseTopListViewModel,
    surgeEaseTopListViewModel,
    hotEaseTopListViewModel
} from '../viewmodel/NetEaseTopListViewModel'

@Preview
@Component
export struct NetEaseTopContent {
    @State currentIndex: number = 0;
    // 原创榜
    @State vb_original: NetEaseTopListViewModel = originalTopListViewModel;

    // 热歌榜
    // @State vb_hot: NetEaseTopListViewModel = hotEaseTopListViewModel;
    // // 飙升榜
    // @State vb_surge: NetEaseTopListViewModel = newEaseTopListViewModel;
    // // 新歌榜
    // @State vb_new: NetEaseTopListViewModel = newEaseTopListViewModel;

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
                // 1
                TabContent() {
                    NetEaseTopWidget({ vb_top_list: $vb_original })
                }
                .tabBar(this.vb_original.topName)
                .tabIndex(0)
                .align(Alignment.Top)

                // 2
                TabContent() {
                    // NetEaseTopWidget({ vb_top_list: $vb_new })
                }
                .tabBar(this.vb_original.topName)
                .tabIndex(1)
                .align(Alignment.Top)

                // 3
                TabContent() {
                    // NetEaseTopWidget({ vb_top_list: $vb_surge })
                }
                .tabBar(this.vb_original.topName)
                .tabIndex(2)
                .align(Alignment.Top)

                // 4
                TabContent() {
                    // NetEaseTopWidget({ vb_top_list: $vb_hot })
                }
                .tabBar(this.vb_original.topName)
                .tabIndex(3)
                .align(Alignment.Top)

            }
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