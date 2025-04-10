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
    @Builder
    imageButton(src: Resource) {
        Button({ type: ButtonType.Circle, stateEffect: true }) {
            Image(src)
        }
        .height('48vp')
        .width('48vp')
        .backgroundColor('#F1F3F5')
    }

    build() {
        Column() {
            Image($r('app.media.favicon'))
                .width('78vp')
                .height('78vp')
                .margin({ top: '150vp', bottom: '8vp' })
            Text($r('app.string.EntryAbility_label'))
                .fontSize('24fp')
                .fontWeight(FontWeight.Medium)
                .fontColor('#182431')
            Text('登录账号以使用更多服务')
                .fontSize('16fp')
                .fontColor('#99182431')
                .margin({ bottom: '30vp', top: '8vp' })
            TextInput({ placeholder: '账号' })
                .type(InputType.Number)
                .maxLength(11)
                .inputStyle()
            TextInput({ placeholder: '密码' })
                .type(InputType.Password)
                .maxLength(8)
                .inputStyle()
            Row() {
                Text('邮箱登录')
                    .blueTextStyle()
                Text('忘记密码')
                    .blueTextStyle()
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
            Text('注册账号')
                .fontColor('#007DFF')
                .fontSize('16fp')
                .fontWeight(FontWeight.Medium)
        } // Column
        .width('100%')
        .height('100%')
        // .backgroundColor('#F1F3F5')
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