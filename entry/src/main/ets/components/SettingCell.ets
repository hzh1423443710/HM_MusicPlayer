import router from '@ohos.router';
import { Size } from '@ohos/hypium';

@Preview
@Component
export struct SettingCell {
    image?: Resource;
    imgSize?: SizeOptions;
    text: string;
    pushUrl: string;

    build() {
        Row() {
            // 图标
            Row() {
                if (this.image) {
                    Image(this.image)
                        .width(this.imgSize ? this.imgSize.width : 24)
                        .height(this.imgSize ? this.imgSize.height : 24)
                }
            }
            .width(40)
            .justifyContent(FlexAlign.Center)

            // 文本
            Text(this.text)
                .fontSize(20)
                .fontColor(Color.Black)
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