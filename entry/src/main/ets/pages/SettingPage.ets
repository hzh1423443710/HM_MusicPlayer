import { HeaderWidget } from '../components/Header'

@Entry
@Component
struct SettingPage {
    build() {
        Column() {
            HeaderWidget({ title: '设置', backButton: true, titleAlign: TextAlign.Center })

        }
        .width('100%')
        .height('100%')
        .padding({ top: $r('app.float.app_margin') })
        .backgroundImage($r('app.media.ic_avatar3'))
        .backgroundImageSize(ImageSize.Cover)
        .backgroundBlurStyle(BlurStyle.Regular)
    }
}