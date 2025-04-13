import { HeaderWidget } from '../components/HeaderWidget'

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
        .backgroundImage($r('app.media.ic_avatar3'))
        .backgroundImageSize(ImageSize.Cover)
        .backgroundBlurStyle(BlurStyle.Regular)
    } // Column
}
