import { HeaderWidget } from '../components/HeaderWidget'
import router from '@ohos.router'
import promptAction from '@ohos.promptAction'
import { HttpUtils } from '../common/network/HttpUtils'

/**
 * 找回密码
 */
@Entry
@Component
struct RetrievePasswdPage {
    username: string = '';
    newPassword: string = '';
    confirmPassword: string = '';
    email: string = '';
    verifyCode: string = '';
    @State isLoading: boolean = false;
    @State countdownSeconds: number = 0;
    @State errors: Record<string, string> = {};
    http: HttpUtils = new HttpUtils();
    private countdownInterval: number = -1;

    aboutToDisappear() {
        if (this.countdownInterval !== -1) clearInterval(this.countdownInterval);
        this.http.destroy();
    }

    // 表单验证
    validateForm(): boolean {
        this.errors = {};
        let isValid = true;

        // 添加用户名验证
        if (!this.username || this.username.trim().length < 3) {
            this.errors.username = '用户名至少3个字符';
            isValid = false;
        }

        if (!this.newPassword || this.newPassword.length < 6) {
            this.errors.newPassword = '密码至少6个字符';
            isValid = false;
        }

        if (this.newPassword !== this.confirmPassword) {
            this.errors.confirmPassword = '两次密码不一致';
            isValid = false;
        }

        const emailRegex = /^[a-zA-Z0-9._-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,6}$/;
        if (!this.email || !emailRegex.test(this.email)) {
            this.errors.email = '请输入有效邮箱';
            isValid = false;
        }

        if (!this.verifyCode || this.verifyCode.length !== 6) {
            this.errors.verifyCode = '请输入6位验证码';
            isValid = false;
        }

        return isValid;
    }

    // 发送验证码
    sendVerifyCode() {
        const emailRegex = /^[a-zA-Z0-9._-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,6}$/;
        if (!this.email || !emailRegex.test(this.email)) {
            this.errors = { ...this.errors, email: '请输入有效邮箱' };
            return;
        }

        this.isLoading = true;
        this.http.getVerifyCode(this.email)
            .then(() => {
                this.countdownSeconds = 60 * 5;
                this.countdownInterval = setInterval(() => {
                    this.countdownSeconds--;
                    if (this.countdownSeconds <= 0) {
                        clearInterval(this.countdownInterval);
                        this.countdownInterval = -1;
                    }
                }, 1000);
                promptAction.showToast({ message: '验证码已发送' });
            })
            .catch(error => promptAction.showToast({ message: `发送失败: ${error.message || '请稍后再试'}` }))
            .finally(() => this.isLoading = false);
    }

    // 提交修改密码
    submitPasswordChange() {
        if (!this.validateForm()) return;

        this.isLoading = true;
        this.http.modifyPasswd(this.username, this.email, this.newPassword, this.verifyCode)
            .then(() => {
                promptAction.showToast({ message: '密码修改成功！' });
                setTimeout(() => router.back(), 1000);
            })
            .catch(error => promptAction.showToast({ message: `修改失败: ${error.message || '请稍后再试'}` }))
            .finally(() => this.isLoading = false);
    }

    // 可重用的表单项构建器
    @Builder
    FormItem(label: string, errKey: string, placeholder: string, value: string, onChange: (val: string) => void, inputType: InputType = InputType.Normal) {
        Column() {
            Text(label).fontSize(16).fontColor('#333').alignSelf(ItemAlign.Start)

            TextInput({ placeholder, text: value })
                .onChange(onChange)
                .type(inputType)
                .placeholderColor('#999')
                .width('100%')
                .height(45)
                .margin({ top: 4 })
                .backgroundColor('rgba(255, 255, 255, 0.2)')
                .borderRadius(8)
                .padding({ left: 12 })

            if (this.errors[errKey]) {
                Text(this.errors[errKey])
                    .fontSize(14)
                    .fontColor('#FF6B6B')
                    .alignSelf(ItemAlign.Start)
                    .margin({ top: 2 })
            }
        }
        .width('100%')
        .margin({ bottom: 12 })
    }

    build() {
        Column() {
            HeaderWidget({ title: '找回密码', titleAlign: TextAlign.Center, backButton: true })

            Scroll() {
                Column() {
                    // 添加用户名输入栏
                    this.FormItem('用户名', 'username', '请输入您的用户名',
                        this.username, (val) => this.username = val)

                    this.FormItem('邮箱', 'email', '请输入您的注册邮箱',
                        this.email, (val) => this.email = val, InputType.Email)

                    // 验证码行
                    Column() {
                        Text('验证码').fontSize(16).fontColor('#333').alignSelf(ItemAlign.Start)

                        Row() {
                            TextInput({ placeholder: '请输入6位验证码', text: this.verifyCode })
                                .type(InputType.Number)
                                .maxLength(6)
                                .onChange((val) => this.verifyCode = val)
                                .placeholderColor('#999')
                                .width('60%')
                                .height(45)
                                .backgroundColor('rgba(255, 255, 255, 0.2)')
                                .borderRadius(8)

                            Button(this.countdownSeconds > 0 ? `${this.countdownSeconds}s` : '获取验证码')
                                .onClick(() => this.countdownSeconds <= 0 && this.sendVerifyCode())
                                .backgroundColor(this.countdownSeconds > 0 ? '#AAA' : '#376668')
                                .fontColor('#FFF')
                                .height(40)
                                .fontSize(14)
                                .borderRadius(6)
                                .margin({ left: 8 })
                                .enabled(this.countdownSeconds <= 0)
                        }
                        .width('100%')
                        .justifyContent(FlexAlign.SpaceBetween)

                        if (this.errors.verifyCode) {
                            Text(this.errors.verifyCode)
                                .fontSize(14)
                                .fontColor('#FF6B6B')
                                .alignSelf(ItemAlign.Start)
                                .margin({ top: 2 })
                        }
                    }
                    .width('100%')
                    .margin({ bottom: 12 })

                    this.FormItem('新密码', 'newPassword', '请输入新密码(6字符以上)',
                        this.newPassword, (val) => this.newPassword = val, InputType.Password)

                    this.FormItem('确认新密码', 'confirmPassword', '请再次输入新密码',
                        this.confirmPassword, (val) => this.confirmPassword = val, InputType.Password)

                    // 提交按钮
                    Button('重置密码')
                        .onClick(() => this.submitPasswordChange())
                        .width('80%')
                        .height(45)
                        .fontSize(16)
                        .fontWeight(FontWeight.Medium)
                        .backgroundColor('#376668')
                        .fontColor('#FFF')
                        .borderRadius(22.5)
                        .margin({ top: 30, bottom: 16 })

                    // 返回登录链接
                    Text('返回登录')
                        .fontSize(14)
                        .fontColor('#376668')
                        .fontWeight(FontWeight.Bold)
                        .onClick(() => router.back())
                }
                .width('90%')
                .padding({ top: 20, bottom: 40 })
                .alignItems(HorizontalAlign.Center)
            }
            .layoutWeight(1)

            // 加载状态
            if (this.isLoading) {
                Row() {
                    LoadingProgress().color('#376668').width(24).height(24)
                    Text('处理中...').fontSize(16).fontColor('#FFF').margin({ left: 8 })
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
        .backgroundImage($r('app.media.ic_avatar10'))
        .backgroundImageSize(ImageSize.Cover)
        .backgroundBlurStyle(BlurStyle.Regular)
    }
}
