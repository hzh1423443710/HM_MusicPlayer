import ConnectionUtils from '../common/network/ConnectionUtils'
import { HomePageContent } from '../view/HomePageContent'
import { PlayerWidget } from '../components/PlayerWidget'
import { NetEaseTopContent } from '../view/NetEaseTopContent'
import { MyContent } from '../view/MyContent'
import { BreakpointSystem } from '../common/BreakpointSystem'
import { MediaService } from '../common/MediaService'

@Entry
@Component
struct HomePage {
    @State currentIndex: number = 0;
    private breakpointSystem: BreakpointSystem = new BreakpointSystem();

    async aboutToAppear() {
        console.log('HomePage aboutToAppear');
        // 开启监听能力
        ConnectionUtils.openRegister();
        // 监听具体事件
        ConnectionUtils.registerEvents();

        this.breakpointSystem.register();
    }

    aboutToDisappear(): void {
        console.log('HomePage aboutToDisappear');
        // 关闭监听能力
        ConnectionUtils.closeRegister();

        this.breakpointSystem.unregister();
        MediaService.getInstance().release();
    }

    build() {
        Column() {
            // 内容区域
            Stack({ alignContent: Alignment.BottomEnd }) {
                Column() {
                    Swiper() {
                        // 1.首页内容
                        HomePageContent()

                        // 2.榜单内容
                        NetEaseTopContent()

                        // 3.我的内容
                        MyContent()
                    }
                    .index(this.currentIndex)
                    .indicator(false)
                    .loop(false)
                    .onChange((index: number) => {
                        this.currentIndex = index;
                    })
                }
                .padding({ left: 10, right: 10 })
                .layoutWeight(1)
                .width('100%')

                // 播放控制器 最上层
                PlayerWidget()
                    .zIndex(100)
            } // Stack
            .layoutWeight(1)
            .width('100%')

            // 底部导航栏
            Row() {
                ForEach([
                    {
                        index: 0,
                        title: '首页',
                        selectedImg: $r("app.media.home_filled"),
                        normalImg: $r("app.media.home")
                    },
                    {
                        index: 1,
                        title: '榜单',
                        selectedImg: $r('app.media.rank_filled'),
                        normalImg: $r("app.media.rank")
                    },
                    {
                        index: 2,
                        title: '我的',
                        selectedImg: $r("app.media.my_filled"),
                        normalImg: $r("app.media.my")
                    }], (item) => {
                    Column() {
                        Image(this.currentIndex === item.index ? item.selectedImg : item.normalImg)
                            .fillColor(this.currentIndex === item.index ? '#1698CE' : '#6B6B6B')
                            .size({ width: 25, height: 25 })
                        Text(item.title)
                            .fontColor(this.currentIndex === item.index ? '#1698CE' : '#6B6B6B')
                    }
                    .onClick(() => {
                        this.currentIndex = item.index;
                    })
                    .layoutWeight(1)
                    .justifyContent(FlexAlign.Center)
                })

            } // Row
            .width('100%')
            .padding({ top: 5, bottom: 5 })
            .height(56)
            .backgroundColor('#FFFFFF')
            .border({ width: { top: 0.5 }, color: { top: '#E4E4E4' } })

        } // Column
        .width('100%')
        .height('100%')
        .backgroundImage($r('app.media.ic_avatar3'))
        .backgroundImageSize(ImageSize.Cover)
        .backgroundBlurStyle(BlurStyle.Regular)

    } // build

    pageTransition() {
        PageTransitionEnter({ duration: 500, curve: Curve.Smooth, type: RouteType.Pop })
        PageTransitionExit({ duration: 500, curve: Curve.Smooth, type: RouteType.Push })
    }
}