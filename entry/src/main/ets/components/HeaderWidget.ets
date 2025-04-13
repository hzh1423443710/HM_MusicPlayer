import router from '@ohos.router';
import { RouterUrlConstants } from '../common/constants/RouterUrlConstants';

@Preview
@Component
export struct HeaderWidget {
    title: ResourceStr = 'title';
    setting: boolean = false;
    backButton: boolean = false;
    titleAlign: TextAlign = TextAlign.Start;

    build() {
        Column() {
            Row()
                .height($r('app.float.app_margin'))

            Row() {
                // 返回按钮
                if (this.backButton) {
                    Image($r('app.media.ic_public_back'))
                        .width(32)
                        .height(32)
                        .margin({ left: 10 })
                        .onClick(() => {
                            router.back()
                        })
                }

                // 标题
                Text(this.title)
                    .focusable(true)
                    .fontSize($r('app.float.tab_content_title'))
                    .fontWeight(FontWeight.Bold)
                    .layoutWeight(1)
                    .textAlign(this.titleAlign)

                // 设置按钮
                if (this.setting) {
                    Blank()
                    Image($r('app.media.ic_public_settings'))
                        .fillColor($r('app.color.button_color'))
                        .width(32)
                        .height(32)
                        .margin({ right: 10 })
                        .onClick(() => {
                            router.pushUrl({
                                url: RouterUrlConstants.SETTING
                            });
                        })
                }
            } // Row
            .width('100%')
            .alignItems(VerticalAlign.Top)

        } // Column
        .width('100%')
    }
}