import router from '@ohos.router';
import { PlayerWidget } from '../components/PlayerWidget';
import { HeaderWidget } from '../components/HeaderWidget';

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
            // 顶部区域
            Column() {
                HeaderWidget({ title: '' })

                // 搜索栏
                Row({ space: 10 }) {
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
                            // 搜索逻辑
                        })
                }
                .justifyContent(FlexAlign.Start)
                .alignItems(VerticalAlign.Center)
            }

            // 中间内容区域 - 使用layoutWeight占据剩余空间
            Column() {
                Tabs() {
                    // 1.歌曲结果
                    TabContent() {
                        List() {
                            ForEach([1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], (item) => {
                                ListItem() {
                                    Text(`搜索结果 ${item}`)
                                        .height(60)
                                        .padding(10)
                                }
                            })
                        }
                        .width('100%')
                    }
                    .tabBar(this.TabBuilder(0, '歌曲', $r('app.media.song')))
                    .tabIndex(0)

                    // 2.歌手结果
                    TabContent() {
                        Text("歌手搜索结果")
                    }
                    .tabBar(this.TabBuilder(1, '歌手', $r('app.media.singer')))
                    .tabIndex(1)

                    // 可以添加更多TabContent
                }
                .vertical(false)
                .onChange((index: number) => {
                    this.currentIndex = index
                })
            } // Column
            .layoutWeight(1) // 关键点：使用layoutWeight占据剩余空间

            // 底部固定的播放器区域
            PlayerWidget()
        } // Column
        .width('100%')
        .height('100%')
        .backgroundImage($r('app.media.ic_avatar3'))
        .backgroundImageSize(ImageSize.Cover)
        .backgroundBlurStyle(BlurStyle.Regular)
    }
}