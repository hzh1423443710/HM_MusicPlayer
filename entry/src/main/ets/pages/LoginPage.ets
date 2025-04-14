import router from '@ohos.router'
import promptAction from '@ohos.promptAction'
import { RouterUrlConstants } from '../common/constants/RouterUrlConstants'

@Extend(TextInput)
function inputStyle() {
    .placeholderColor('#99182431')
    .height('45vp')
    .fontSize('18fp')
    .backgroundColor('#F1F3F5')
    .width('100%')
    .margin({ top: 12 })
}

@Extend(Text)
function blueTextStyle() {
    .fontColor('#007DFF')
    .fontSize('14fp')
    .fontWeight(FontWeight.Medium)
}

@Entry
@Component
struct LoginPage {
    @State emailLogin: boolean = false;

    build() {
        Column() {
            Image($r('app.media.favicon'))
                .width('78vp')
                .height('78vp')
                .margin({ top: '150vp', bottom: '8vp' })

            Text($r('app.string.AppFullName'))
                .fontSize('24fp')
                .fontWeight(FontWeight.Medium)
                .fontColor('#182431')

            Text('登录账号以使用更多服务')
                .fontSize('16fp')
                .fontColor('#99182431')
                .margin({ bottom: '30vp', top: '8vp' })

            TextInput({ placeholder: this.emailLogin ? '邮箱' : '账号' })
                .type(InputType.Number)
                .maxLength(11)
                .inputStyle()

            TextInput({ placeholder: '密码' })
                .type(InputType.Password)
                .maxLength(8)
                .inputStyle()

            Row() {
                Text(this.emailLogin ? '账号登录' : '邮箱登录')
                    .blueTextStyle()
                    .onClick(() => {
                        this.emailLogin = !this.emailLogin;
                    })
                Text('忘记密码')
                    .blueTextStyle()
                    .onClick(() => {
                        router.pushUrl({ url: RouterUrlConstants.RETRIEVE_PASSWD })
                    })
            }
            .width('100%')
            .justifyContent(FlexAlign.SpaceBetween)
            .margin({ top: '8vp' })

            Button('登录')
                .width('90%')
                .height('40vp')
                .fontSize('16fp')
                .fontWeight(FontWeight.Medium)
                .backgroundColor('#007DFF')
                .margin({ top: '48vp', bottom: '12vp' })
                .onClick(() => {
                    AppStorage.SetOrCreate<boolean>('isLogged', true);
                    router.back();
                })

            Text('注册账号')
                .fontColor('#007DFF')
                .fontSize('16fp')
                .fontWeight(FontWeight.Medium)
                .onClick(() => {
                    router.pushUrl({ url: RouterUrlConstants.REGISTER });
                })

        } // Column
        .width('100%')
        .height('100%')
        .backgroundImage($r('app.media.ic_avatar3'))
        .backgroundImageSize(ImageSize.Cover)
        .backgroundBlurStyle(BlurStyle.Regular)
        .padding({
            left: '12vp',
            right: '12vp',
            bottom: '24vp'
        })
    } // build
}