import router from '@ohos.router';

@Preview
@Component
export struct HeaderWidget {
    title: ResourceStr = 'title';
    @State setting: boolean = false;
    backButton: boolean = false;
    titleAlign: TextAlign = TextAlign.Start;

    build() {
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
                // 设置
                Image($r('app.media.ic_public_settings'))
                    .fillColor($r('app.color.button_color'))
                    .width(32)
                    .height(32)
                    .onClick(() => {
                        router.pushUrl({
                            url: "pages/SettingPage"
                        })
                    })
            }
        }
        .width('100%')
        .alignItems(VerticalAlign.Top)
    }
}