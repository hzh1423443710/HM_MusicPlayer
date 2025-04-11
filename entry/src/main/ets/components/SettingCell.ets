import router from '@ohos.router';

@Preview
@Component
export struct SettingCell {
    image?: Resource;
    text: string;
    pushUrl: string;

    build() {
        Row() {
            if (this.image) {
                Image(this.image)
                    .width(24)
                    .height(24)
            }
            Text(this.text)
                .fontSize(20)
                .fontColor(Color.Black)
                .margin({ left: 10 })
            Blank()
            Image($r('app.media.arrow'))
                .width(24)
                .height(24)

        }
        .padding(10)
        .justifyContent(FlexAlign.Start)
        .width('98%')
        .height(60)
        .borderRadius(25)
        .stateStyles({
            normal: {
                .backgroundColor(Color.Transparent)
            },
            pressed: {
                .backgroundColor("#BDBDBD")
            }
        })
        .onClick(() => {
            if (this.pushUrl) {
                router.pushUrl({
                    url: this.pushUrl
                })
            }
        })
    }
}