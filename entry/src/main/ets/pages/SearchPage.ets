import router from '@ohos.router';
import promptAction from '@ohos.promptAction';
import { PlayerWidget } from '../components/PlayerWidget';

@Entry
@Component
struct SearchPage {
    @State inputText: string = '';
    @State currentIndex: number = 0

    aboutToAppear(): void {
        const params = router.getParams();
        if (params && params.hasOwnProperty('inputText')) {
            this.inputText = params["inputText"];
        }
    }

    @Builder
    TabBuilder(index: number, name: string, image: Resource) {
        Column() {
            Row({ space: 5 }) {
                Image(image)
                    .size({ width: 28, height: 28 })
                Text(name)
                    .fontColor(this.currentIndex === index ? $r('app.color.tab_font_selected_color') : $r('app.color.tab_font_color'))
                    .fontSize(22)
                    .fontWeight(this.currentIndex === index ? 500 : 400)
                    .lineHeight(25)
                    .margin({ top: 17, bottom: 7 })
            }
            .alignItems(VerticalAlign.Center)

            Divider()
                .strokeWidth(2)
                .color('#007DFF')
                .opacity(this.currentIndex === index ? 1 : 0)
                .width(100)
        }.width('100%')
    }

    build() {
        Column() {
            // 搜索栏
            Row({ space: 20 }) {
                Image($r('app.media.ic_public_back'))
                    .width(32)
                    .height(32)
                    .margin({ left: 10 })
                    .onClick(() => {
                        router.back();
                    })

                Search({ placeholder: '搜索', value: this.inputText })
                    .borderWidth(1)
                    .borderColor(Color.Brown)
                    .width('85%')
                    .backgroundColor(Color.White)
                    .onSubmit((value: string) => {
                        promptAction.showToast({ message: '搜索', bottom: '600' })
                    })
            } // Row
            .justifyContent(FlexAlign.Start)
            .alignItems(VerticalAlign.Center)

            // 搜索结果
            Tabs() {
                // 1.歌曲结果
                TabContent() {
                    Stack() {

                        PlayerWidget()
                            .zIndex(1)
                    }

                }
                .tabBar(this.TabBuilder(0, '歌曲', $r('app.media.song')))
                .tabIndex(0)

                // 2.歌手结果 -> click -> 歌手歌曲page
                TabContent() {

                    PlayerWidget()
                        .zIndex(1)
                }
                .tabBar(this.TabBuilder(1, '歌手', $r('app.media.singer')))
                .tabIndex(1)

                // 3.网易云歌单

                // 4.QQ歌单

            }
            .vertical(false)
            .onChange((index: number) => {
                this.currentIndex = index
            })

        }
        .width('100%')
        .height('100%')
        .padding({ top: $r('app.float.app_margin') })
        .backgroundImage($r('app.media.ic_avatar3'))
        .backgroundImageSize(ImageSize.Cover)
        .backgroundBlurStyle(BlurStyle.Regular)
        .alignItems(HorizontalAlign.Start)
        .justifyContent(FlexAlign.Start)
    }
}