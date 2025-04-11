import { HeaderWidget } from '../components/Header'

/**
 * 导入外部歌单
 */
@Entry
@Component
struct ExportPlayListPage {
    build() {
        Column() {
            HeaderWidget({ title: '导入外部歌单', titleAlign: TextAlign.Center, backButton: true })
        } // Column
        .width('100%')
        .height('100%')
        .padding({ top: $r('app.float.app_margin') })
        .backgroundImage($r('app.media.ic_avatar3'))
        .backgroundImageSize(ImageSize.Cover)
        .backgroundBlurStyle(BlurStyle.Regular)
    } // Column
}
