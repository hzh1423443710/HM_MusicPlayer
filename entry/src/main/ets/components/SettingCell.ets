import router from '@ohos.router';
import { globalUser } from '../viewmodel/UserViewModel'
import promptAction from '@ohos.promptAction';

@Preview
@Component
export struct SettingCell {
    image?: Resource;
    text: string;
    pushUrl: string;
    needLogin: boolean = false;

    build() {
        Row() {
            Row() {
                if (this.image) {
                    Image(this.image).width(30).height(30)
                }
            }.width(40).justifyContent(FlexAlign.Center)

            Text(this.text).fontSize(20).fontColor(Color.Black)
            Blank()
            Image($r('app.media.arrow')).width(24).height(24)
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
            if (this.needLogin && !globalUser.isLogged) {
                promptAction.showToast({ message: '请先登录', duration: 2000 })
                return;
            }

            if (this.pushUrl) router.pushUrl({ url: this.pushUrl });
        })
    }
}