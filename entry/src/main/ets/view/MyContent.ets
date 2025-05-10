import { HeaderWidget } from '../components/HeaderWidget';
import router from '@ohos.router';
import { RouterUrlConstants } from '../common/constants/RouterUrlConstants';
import { SettingCell } from '../components/SettingCell';
import { globalUser, UserViewModel } from '../viewmodel/UserViewModel'

@Preview
@Component
export struct MyContent {
    @State viewModel: UserViewModel = globalUser;

    build() {
        Column() {
            HeaderWidget({ title: '我的', setting: true })
            Row() {
                // 用户信息
                if (this.viewModel.isLogged) {
                    Image("https://api.52vmy.cn/api/avath/qq?qq=1423443710")
                        .width(48)
                        .height(48)
                        .borderRadius(24)
                    Column() {
                        Text(this.viewModel.user.username)
                            .fontSize(28)
                        Text(this.viewModel.user.email)
                            .fontSize(18)
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

            SettingCell({ text: '收藏', image: $r('app.media.love') })
            this.splitter();
            SettingCell({
                pushUrl: RouterUrlConstants.RECENT,
                text: '最近播放',
                image: $r('app.media.recent'),
                imgSize: { width: 30, height: 30 }
            })

            // TODO 用户歌单

            // TODO 网易云歌单 QQ歌单

        } // Column
    } // build

    @Builder
    splitter() {
        Line()
            .width('90%')
            .height(2)
            .borderRadius(1)
            .backgroundColor('rgba(0, 0, 0, 0.25)')
    }
}