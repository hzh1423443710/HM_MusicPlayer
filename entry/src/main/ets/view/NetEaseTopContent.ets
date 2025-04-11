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
} from '../viewmodel/NetEaseLongListViewModel'


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

    @Builder
    TabBuilder(index: number, name: string) {
        Column() {
            Row({ space: 5 }) {
                Text(name)
                    .fontColor(this.currentIndex === index ? $r('app.color.tab_font_selected_color') : $r('app.color.tab_font_color'))
                    .fontSize(20)
                    .fontWeight(this.currentIndex === index ? 500 : 400)
                    .lineHeight(25)
                    .margin({ top: 17, bottom: 7 })
            }
            .alignItems(VerticalAlign.Center)

            Divider()
                .strokeWidth(2)
                .color('#007DFF')
                .opacity(this.currentIndex === index ? 1 : 0)
                .width(80)
        }.width('100%')
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
                    NetEaseTopWidget({ vb_top_list: $vb_original })
                }
                .tabBar(this.TabBuilder(0, this.vb_original.title))
                .tabIndex(0)
                .align(Alignment.Top)

                // 2.热歌榜
                TabContent() {
                    NetEaseTopWidget({ vb_top_list: $vb_hot })
                }
                .tabBar(this.TabBuilder(1, this.vb_hot.title))
                .tabIndex(1)
                .align(Alignment.Top)

                // 3.飙升榜
                TabContent() {
                    NetEaseTopWidget({ vb_top_list: $vb_surge })
                }
                .tabBar(this.TabBuilder(2, this.vb_surge.title))
                .tabIndex(2)
                .align(Alignment.Top)

                // 4.新歌榜
                TabContent() {
                    NetEaseTopWidget({ vb_top_list: $vb_new })
                }
                .tabBar(this.TabBuilder(3, this.vb_new.title))
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