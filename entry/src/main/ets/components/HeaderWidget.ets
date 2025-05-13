import router from '@ohos.router';

@Preview
@Component
export struct HeaderWidget {
    title?: ResourceStr;
    backButton: boolean = false;
    titleAlign: TextAlign = TextAlign.Start;

    build() {
        Column() {
            Row().height($r('app.float.app_margin'))

            Row() {
                if (this.backButton) {
                    Image($r('app.media.ic_public_back')).width(32).height(32).margin({ left: 10 })
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

            } // Row
            .width('100%')
            .alignItems(VerticalAlign.Top)

        } // Column
        .width('100%')
    }
}