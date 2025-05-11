import router from '@ohos.router'
import promptAction from '@ohos.promptAction'
import { RouterUrlConstants } from '../common/constants/RouterUrlConstants'
import { globalUser } from '../viewmodel/UserViewModel'

/**
 * 登录页面
 */
@Entry
@Component
struct LoginPage {
    username: string = '';
    password: string = '';
    @State isLoading: boolean = false;
    @State errors: Record<string, string> = {};

    // 表单验证
    validateForm(): boolean {
        this.errors = {};
        let isValid = true;

        if (!this.username || this.username.trim() === '') {
            this.errors.username = '请输入用户名';
            isValid = false;
        }

        if (!this.password || this.password === '') {
            this.errors.password = '请输入密码';
            isValid = false;
        }

        return isValid;
    }

    // 执行登录
    async doLogin() {
        if (!this.validateForm()) return;

        this.isLoading = true;
        try {
            globalUser.login(this.username, this.password)
                .then(ok => {
                    if (ok) {
                        promptAction.showToast({ message: '登录成功' });
                        router.back();
                    } else {
                        this.errors.common = '账号或密码错误';
                    }
                });
        } catch (error) {
            this.errors.common = `登录失败: ${error.message || '请稍后再试'}`;
            promptAction.showToast({ message: this.errors.common });
        } finally {
            this.isLoading = false;
        }
    }

    // 可重用的输入框构建器
    @Builder
    InputField(label: string, placeholder: string, errorKey: string, value: string, onChange: (value: string) => void, inputType: InputType = InputType.Normal) {
        Column() {
            Text(label).fontSize(16).fontColor(Color.Black).alignSelf(ItemAlign.Start)

            TextInput({ placeholder: placeholder, text: value })
                .type(inputType)
                .onChange(onChange)
                .placeholderColor('#999999')
                .width('100%')
                .height(45)
                .margin({ top: 4 })
                .backgroundColor('rgba(255, 255, 255, 0.2)')
                .borderRadius(8)
                .padding({ left: 12 })
                .fontColor(Color.Black)

            if (this.errors[errorKey]) {
                Text(this.errors[errorKey])
                    .fontSize(14)
                    .fontColor('#FF6B6B')
                    .alignSelf(ItemAlign.Start)
                    .margin({ top: 2 })
            }
        }
        .width('100%')
        .margin({ bottom: 16 })
    }

    build() {
        Column() {
            // 顶部图标和标题
            Row() {
                Image($r('app.media.favicon')).width(80).height(80).objectFit(ImageFit.Contain)
            }
            .margin({ top: 80, bottom: 20 })

            // 标题
            Text($r('app.string.AppFullName'))
                .fontSize(28)
                .fontWeight(FontWeight.Bold)
                .margin({ bottom: 10 })
                .fontColor(Color.Black)

            Text('登录账号以使用更多服务').fontSize(16).fontColor(Color.Black).margin({ bottom: 40 })

            // 表单区域
            Column() {
                // 使用可重用构建器创建用户名和密码输入框
                this.InputField('用户名', '请输入用户名', 'username', this.username, (value) => this.username = value)

                this.InputField('密码', '请输入密码', 'password', this.password, (value) => this.password = value, InputType.Password)

                // 通用错误信息
                if (this.errors.common) {
                    Text(this.errors.common)
                        .fontSize(14)
                        .fontColor('#FF6B6B')
                        .width('100%')
                        .textAlign(TextAlign.Center)
                        .margin({ bottom: 16 })
                }

                // 登录按钮
                Button('登录')
                    .onClick(() => this.doLogin())
                    .width('80%')
                    .height(45)
                    .fontSize(16)
                    .fontWeight(FontWeight.Medium)
                    .backgroundColor('#376668')
                    .fontColor('#FFFFFF')
                    .borderRadius(22.5)
                    .margin({ top: 20, bottom: 16 })

                // 底部链接
                Row() {
                    Text('没有账号？').fontSize(14).fontColor('rgba(0, 0, 255, 0.7)')

                    Text('立即注册').fontSize(14).fontColor('#376668').fontWeight(FontWeight.Bold)
                        .onClick(() => {
                            router.pushUrl({ url: RouterUrlConstants.REGISTER });
                        })
                }
                .margin({ bottom: 20 })

                Text('忘记密码').fontSize(14).fontColor('#376668').fontWeight(FontWeight.Bold)
                    .onClick(() => {
                        router.pushUrl({ url: RouterUrlConstants.RETRIEVE_PASSWD })
                    })
            }
            .width('80%')
            .padding(16)
            .borderRadius(16)
            .alignItems(HorizontalAlign.Center)

            // 加载状态
            if (this.isLoading) {
                Row() {
                    LoadingProgress().color('#376668').width(24).height(24)
                    Text('登录中...').fontSize(16).fontColor('#FFFFFF').margin({ left: 8 })
                }
                .width('100%')
                .height('100%')
                .position({ x: 0, y: 0 })
                .backgroundColor('rgba(0, 0, 0, 0.5)')
                .justifyContent(FlexAlign.Center)
            }
        }
        .width('100%')
        .height('100%')
        .justifyContent(FlexAlign.Start)
        .backgroundImage($r('app.media.ic_avatar10'))
        .backgroundImageSize(ImageSize.Cover)
        .backgroundBlurStyle(BlurStyle.Regular)
    }
}