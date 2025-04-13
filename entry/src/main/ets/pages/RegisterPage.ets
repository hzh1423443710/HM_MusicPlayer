import { HeaderWidget } from '../components/HeaderWidget'

/**
 * 注册账号
 */
@Entry
@Component
struct RegisterPage {
    build() {
        Column() {
            HeaderWidget({ title: '注册账号', backButton: true, titleAlign: TextAlign.Center })

        } // Column
        .width('100%')
        .height('100%')
        .backgroundImage($r('app.media.ic_avatar3'))
        .backgroundImageSize(ImageSize.Cover)
        .backgroundBlurStyle(BlurStyle.Regular)
    } // build
}