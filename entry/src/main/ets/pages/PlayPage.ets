import { HeaderWidget } from '../components/HeaderWidget'

@Entry
@Component
struct PlayPage {
    build() {
        Column() {
            HeaderWidget({ title: '播放页面', backButton: true, titleAlign: TextAlign.Center })

        } // Column
        .width('100%')
        .height('100%')
        .backgroundImage($r('app.media.ic_avatar3'))
        .backgroundImageSize(ImageSize.Cover)
        .backgroundBlurStyle(BlurStyle.Regular)

    } // build

    // 转场动画
    pageTransition() {
        PageTransitionEnter({ duration: 500, curve: Curve.Linear }).slide(SlideEffect.Bottom)
        PageTransitionExit({ duration: 500, curve: Curve.Ease }).slide(SlideEffect.Top)
    }
}