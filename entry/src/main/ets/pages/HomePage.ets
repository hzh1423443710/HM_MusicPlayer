import ConnectionUtils from '../common/network/ConnectionUtils'
import { HomePageContent } from '../view/HomePageContent'
import { PlayerWidget } from '../components/PlayerWidget'
import { StyleConstants } from '../common/constants/StyleConstants'
import { NetEaseTopContent } from '../view/NetEaseTopContent'
import { MyContent } from '../view/MyContent'
import display from '@ohos.display';

@Entry
@Component
struct Index {
    @State currentIndex: number = 0;

    async aboutToAppear() {
        console.log('HomePage aboutToAppear');
        // 开启监听能力
        ConnectionUtils.openRegister();
        // 监听具体事件
        ConnectionUtils.registerEvents();
    }

    aboutToDisappear(): void {
        console.log('HomePage aboutToDisappear');
        // 关闭监听能力
        ConnectionUtils.closeRegister();
    }

    @Builder
    tabBarBuilder(selfIndex: number, title: string, selectedImg: Resource, normalImg: Resource) {
        Column() {
            Image(this.currentIndex === selfIndex ? selectedImg : normalImg)
                .fillColor(this.currentIndex === selfIndex ? '#1698CE' : '#6B6B6B')
                .size({ width: 25, height: 25 })
            Text(title)
                .fontColor(this.currentIndex === selfIndex ? '#1698CE' : '#6B6B6B')
        }
    }

    build() {
        Tabs() {
            // 1.首页
            TabContent() {
                Stack() {
                    HomePageContent()
                    // 播放控制
                    PlayerWidget()
                }
                .alignContent(Alignment.Top)
                .align(Alignment.Top)
                .width(StyleConstants.FULL_WIDTH)
                .padding({ top: $r('app.float.app_margin') })
            }
            .tabBar(this.tabBarBuilder(0, '首页', $r("app.media.home_filled"), $r("app.media.home")))
            .align(Alignment.Top)

            // 2.榜单
            TabContent() {
                Stack() {
                    NetEaseTopContent()
                    PlayerWidget()
                }
                .alignContent(Alignment.Top)
                .width(StyleConstants.FULL_WIDTH)
                .padding({ top: $r('app.float.app_margin') })
            }
            .tabBar(this.tabBarBuilder(1, '榜单', $r('app.media.rank_filled'), $r("app.media.rank")))
            .align(Alignment.Top)

            // 3.我的
            TabContent() {
                Stack() {
                    MyContent()
                    PlayerWidget()
                }
                .alignContent(Alignment.Top)
                .width(StyleConstants.FULL_WIDTH)
                .padding({ top: $r('app.float.app_margin') })
            }
            .tabBar(this.tabBarBuilder(2, '我的', $r("app.media.my_filled"), $r("app.media.my")))
            .align(Alignment.Top)

        } // Tabs
        .barPosition(BarPosition.End)
        .scrollable(false)
        .backgroundImage($r('app.media.ic_avatar3'))
        .backgroundImageSize(ImageSize.Cover)
        .backgroundBlurStyle(BlurStyle.Regular)
        .padding(10)
        .onChange((index: number) => {
            this.currentIndex = index;
        })

    } // build
}