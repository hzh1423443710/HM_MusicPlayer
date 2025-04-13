import { HeaderWidget } from '../components/HeaderWidget'

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
        .backgroundImage($r('app.media.ic_avatar3'))
        .backgroundImageSize(ImageSize.Cover)
        .backgroundBlurStyle(BlurStyle.Regular)

    } // build
}