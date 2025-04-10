import { HeaderWidget } from '../components/Header';
import router from '@ohos.router';

@Preview
@Component
export struct MyContent {
    /**
     * 登录状态
     */
    @StorageLink('Logged') Logged: boolean = false;

    build() {
        Column() {
            HeaderWidget({ title: '我的', setting: true })
            Row() {
                if (this.Logged) {
                    Image("https://api.52vmy.cn/api/avath/qq?qq=1423443710")
                        .width(48)
                        .height(48)
                        .borderRadius(24)
                    Column() {
                        Text('去码头整点薯条')
                            .fontSize(20)
                        Text('1423443710@qq.com')
                            .fontSize(12)
                            .margin({ top: 4 })
                    }
                    .alignItems(HorizontalAlign.Start)
                    .margin({ left: 12 })
                } else {
                    Button('立即登录')
                        .type(ButtonType.Capsule)
                        .width(200)
                        .onClick(() => {
                            router.pushUrl({
                                url: 'pages/LoginPage'
                            });
                        })
                }
            } // Row
            .alignItems(VerticalAlign.Center)
            .justifyContent(FlexAlign.Center)
            .width('100%')

        } // Column
    } // build
}