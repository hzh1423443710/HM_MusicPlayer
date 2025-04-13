import { HeaderWidget } from '../components/HeaderWidget';
import router from '@ohos.router';
import { RouterUrlConstants } from '../common/constants/RouterUrlConstants';
import { SettingCell } from '../components/SettingCell';

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
                // 用户信息
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
                                url: RouterUrlConstants.LOGIN
                            });
                        })
                }

            } // Row
            .alignItems(VerticalAlign.Center)
            .justifyContent(FlexAlign.Center)
            .width('100%')

            // TODO pushURL
            SettingCell({ text: '收藏(0)', image: $r('app.media.love') })
            SettingCell({ text: '本地(0)', image: $r('app.media.local') })
            SettingCell({ text: '最近播放(0)', image: $r('app.media.recent'), imgSize: { width: 30, height: 30 } })

        } // Column
    } // build
}