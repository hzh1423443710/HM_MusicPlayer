import { HeaderWidget } from '../components/HeaderWidget'

/**
 * 找回密码
 */
@Entry
@Component
struct RetrievePasswdPage {
    build() {
        Column() {
            HeaderWidget({ title: '找回密码', titleAlign: TextAlign.Center, backButton: true })
        } // Column
        .width('100%')
        .height('100%')
        .backgroundImage($r('app.media.ic_avatar3'))
        .backgroundImageSize(ImageSize.Cover)
        .backgroundBlurStyle(BlurStyle.Regular)
    } // build
}
