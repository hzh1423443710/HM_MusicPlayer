import { HeaderWidget } from '../components/Header'

/**
 * 关于
 */
@Entry
@Component
struct AboutPage {
    build() {
        Column() {
            HeaderWidget({ title: '关于', titleAlign: TextAlign.Center, backButton: true })
        } // Column
        .width('100%')
        .height('100%')
        .padding({ top: $r('app.float.app_margin') })
        .backgroundImage($r('app.media.ic_avatar3'))
        .backgroundImageSize(ImageSize.Cover)
        .backgroundBlurStyle(BlurStyle.Regular)

    } // build
}