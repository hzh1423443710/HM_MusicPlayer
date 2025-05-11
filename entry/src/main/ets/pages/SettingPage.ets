import { HeaderWidget } from '../components/HeaderWidget'
import { SettingCell } from '../components/SettingCell'
import router from '@ohos.router'
import { globalUser } from '../viewmodel/UserViewModel'
import { RouterUrlConstants } from '../common/constants/RouterUrlConstants'

@Builder
function smallTitle(text: string) {
    Row() {
        Text(text)
    }
    .width('100%').justifyContent(FlexAlign.Start).alignItems(VerticalAlign.Center).margin({ top: 10, left: 20 })
}

/**
 * 设置
 */
@Entry
@Component
struct SettingPage {
    @Styles
    buttonStyle() {
        .stateStyles({ normal: Color.Orange })
    }

    build() {
        Column() {
            HeaderWidget({ title: '设置', backButton: true, titleAlign: TextAlign.Center })

            // 账号
            smallTitle('账号')
            Column() {
                SettingCell({ text: '个人资料', pushUrl: RouterUrlConstants.PROFILE, needLogin: true })
            }
            .width('100%').backgroundColor(Color.Transparent).opacity(0.80).borderRadius(20)

            Blank()

            // 其他
            smallTitle('其他')
            SettingCell({ text: '关于', pushUrl: 'pages/AboutPage' })

            Button('退出登录')
                .fontSize(20)
                .fontColor(Color.Black)
                .width("60%")
                .margin({ top: 10, bottom: 10 })
                .onClick((event: ClickEvent) => {
                    globalUser.isLogged = false;
                    router.back();
                })

        } // Column
        .width('100%')
        .height('100%')
        .backgroundImage($r('app.media.ic_avatar3'))
        .backgroundImageSize(ImageSize.Cover)
        .backgroundBlurStyle(BlurStyle.Regular)
        .alignItems(HorizontalAlign.Center)
    } // build
}