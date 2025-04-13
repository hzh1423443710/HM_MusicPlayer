import { HeaderWidget } from '../components/HeaderWidget'
import { SettingCell } from '../components/SettingCell'
import promptAction from '@ohos.promptAction'
import router from '@ohos.router'
import { RouterUrlConstants } from '../common/constants/RouterUrlConstants'

@Builder
function smallTitle(text: string) {
    Row() {
        Text(text)
    }
    .width('100%')
    .justifyContent(FlexAlign.Start)
    .alignItems(VerticalAlign.Center)
    .margin({ top: 10, left: 20 })
}

/**
 * 设置
 */
@Entry
@Component
struct SettingPage {
    @Styles
    buttonStyle() {
        .stateStyles({
            normal: Color.Orange
        })
    }

    build() {
        Column() {
            HeaderWidget({ title: '设置', backButton: true, titleAlign: TextAlign.Center })

            // 账号
            smallTitle('账号')
            Column() {
                SettingCell({ text: '个人资料', pushUrl: 'pages/ProfilePage' })
                Divider()
                    .strokeWidth(2)
                    .width('90%')
                SettingCell({ text: '导入外部歌单', pushUrl: 'pages/ExportPlayListPage' })
            }
            .width('100%')
            .backgroundColor(Color.Transparent)
            .opacity(0.80)
            .borderRadius(20)


            // 播放与下载
            smallTitle('播放与下载')

            Blank()

            // 其他
            smallTitle('其他')
            SettingCell({ text: '关于', pushUrl: 'pages/AboutPage' })

            Button('退出登录')
                .onClick((event: ClickEvent) => {
                    AppStorage.SetOrCreate<boolean>('Logged', false);
                    router.replaceUrl({ url: RouterUrlConstants.HOME }).then(() => {
                        promptAction.showToast({ message: '退出成功' });
                    })
                })
                .fontSize(20)
                .fontColor(Color.Black)
                .width("80%")
                .margin({ top: 10, bottom: 10 })
        } // Column
        .width('100%')
        .height('100%')
        .backgroundImage($r('app.media.ic_avatar3'))
        .backgroundImageSize(ImageSize.Cover)
        .backgroundBlurStyle(BlurStyle.Regular)
        .alignItems(HorizontalAlign.Center)
    } // build
}