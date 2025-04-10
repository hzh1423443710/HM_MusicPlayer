import { HeaderWidget } from '../components/Header'

@Entry
@Component
struct SettingPage {
    build() {
        Column() {
            HeaderWidget({ title: '设置' })

        }
        .width('100%')
        .height('100%')
        .margin({ top: $r('app.float.app_margin') })
        .backgroundImage($r('app.media.ic_avatar3'))
        .backgroundImageSize(ImageSize.Cover)
        .backgroundBlurStyle(BlurStyle.Regular)
    }
}