import { HeaderWidget } from '../components/HeaderWidget'
import router from '@ohos.router'
import promptAction from '@ohos.promptAction'
import { RouterUrlConstants } from '../common/constants/RouterUrlConstants'
import { globalUser, UserViewModel } from '../viewmodel/UserViewModel'

// 平台编辑对话框
@CustomDialog
struct PlatformEditDialog {
    controller: CustomDialogController;
    title: string;
    platform: string;
    @State inputValue: string = '';
    onConfirm: (platform: string, value: string) => void;

    build() {
        Column() {
            Text(this.title)
                .fontSize(18)
                .fontWeight(FontWeight.Bold)
                .margin({ top: 20, bottom: 20 })

            TextInput({
                placeholder: `请输入${this.platform === 'qq' ? 'QQ音乐ID' : '网易云音乐ID'}`,
                text: this.inputValue
            })
                .onChange((value) => {
                    this.inputValue = value;
                })
                .width('90%')
                .height(45)
                .backgroundColor('#F5F5F5')
                .padding({ left: 12, right: 12 })
                .borderRadius(8)
                .margin({ bottom: 24 })

            Row() {
                Button('取消')
                    .onClick(() => {
                        this.controller.close();
                    })
                    .width('45%')
                    .height(40)
                    .fontSize(16)
                    .backgroundColor('#F5F5F5')
                    .fontColor('#333333')
                    .borderRadius(20)

                Button('确定')
                    .onClick(() => {
                        this.onConfirm(this.platform, this.inputValue);
                        this.controller.close();
                    })
                    .width('45%')
                    .height(40)
                    .fontSize(16)
                    .backgroundColor('#376668')
                    .fontColor('#FFFFFF')
                    .borderRadius(20)
            }
            .width('90%')
            .justifyContent(FlexAlign.SpaceBetween)
            .margin({ bottom: 20 })
        }
        .width('80%')
        .backgroundColor(Color.White)
        .borderRadius(16)
        .alignItems(HorizontalAlign.Center)
    }
}

/**
 * 个人信息页面
 */
@Entry
@Component
struct UserProfilePage {
    @State viewModel: UserViewModel = globalUser;
    @State isLoading: boolean = false;
    private editDialogController: CustomDialogController = null;

    // 格式化日期显示
    formatDate(dateString: string): string {
        if (!dateString) return '未知';
        try {
            const date = new Date(dateString);
            return `${date.getFullYear()}-${(date.getMonth() + 1).toString().padStart(2, '0')}-${date.getDate()
                .toString()
                .padStart(2, '0')}`;
        } catch (e) {
            return dateString || '未知';
        }
    }

    // 退出登录
    logout() {
        promptAction.showDialog({
            title: '退出登录',
            message: '确定要退出当前账号吗？',
            buttons: [
                { text: '取消', color: '#666666' },
                { text: '确定', color: '#376668' }
            ],
        }).then(result => {
            // 确定
            if (result.index === 1) {
                // 退出登录
                this.viewModel.logout();
                promptAction.showToast({ message: '已退出登录' });
                router.back();
            }
        });
    }

    // 打开编辑对话框
    openEditDialog(platform: string, currentValue: string) {
        let title = platform === 'qq' ? '修改QQ音乐ID' : '修改网易云音乐ID';

        this.editDialogController = new CustomDialogController({
            builder: PlatformEditDialog({
                title: title,
                platform: platform,
                inputValue: currentValue,
                onConfirm: (platform, value) => {
                    this.updatePlatformId(platform, value);
                }
            }),
            alignment: DialogAlignment.Center,
            offset: { dx: 0, dy: -20 },
            customStyle: true
        });

        this.editDialogController.open();
    }

    // 更新平台ID
    async updatePlatformId(platform: string, value: string) {
        if (this.isLoading) return;
        this.isLoading = true;

        try {
            const success = await this.viewModel.bindPlatform(platform, value);

            if (success)
                promptAction.showToast({ message: '更新成功' });
            else
                promptAction.showToast({ message: '更新失败，请稍后再试' });
        } catch (error) {
            console.error('更新平台ID失败:', error);
            promptAction.showToast({ message: '更新失败，网络错误' });
        } finally {
            this.isLoading = false;
        }
    }

    // 构建信息项
    @Builder
    InfoItem(title: string, value: string, icon: Resource, platform: string = '') {
        Row() {
            Row() {
                Image(icon).width(22).height(22).margin({ right: 12 })
                Text(title).fontSize(16).fontColor('#333333')
            }

            Row() {
                Text(value || '未设置').fontSize(16).fontColor('#333333')
            }
        }
        .width('100%')
        .justifyContent(FlexAlign.SpaceBetween)
        .padding({ top: 16, bottom: 16 })
    }

    build() {
        Stack({ alignContent: Alignment.Center }) {
            Column() {
                HeaderWidget({
                    title: '个人信息',
                    titleAlign: TextAlign.Center,
                    backButton: true
                })

                Scroll() {
                    Column() {
                        // 头像区域
                        Column() {
                            Image(this.viewModel.avatar() || $r('app.media.default_singer'))
                                .width(100).height(100).borderRadius(50).margin({ bottom: 16 })
                            Text(this.viewModel.username)
                                .fontSize(22).fontWeight(FontWeight.Bold).margin({ bottom: 8 })
                        }
                        .width('100%').margin({ top: 20, bottom: 30 }).alignItems(HorizontalAlign.Center)

                        // 信息卡片
                        Column() {
                            // 基本信息
                            this.InfoItem('用户名', this.viewModel.username, $r('app.media.icon_user'))
                            this.InfoItem('邮箱', this.viewModel.email, $r('app.media.icon_email'))
                            this.InfoItem('创建时间', this.formatDate(this.viewModel.create_at), $r('app.media.icon_create_at'))

                            Text('关联账号').fontSize(18).fontWeight(FontWeight.Bold).margin({ top: 24, bottom: 8 })

                            // QQ 音乐
                            Row() {
                                Row() {
                                    Image($r('app.media.icon_qqmusic')).width(22).height(22).margin({ right: 12 })
                                    Text('QQ音乐').fontSize(16).fontColor('#333333')
                                }

                                Row() {
                                    Text(this.viewModel.qq_id || '未设置').fontSize(16).fontColor('#333333')
                                    Image($r('app.media.icon_edit')).width(20).height(20).margin({ left: 8 })
                                }
                                .onClick(() => {
                                    this.openEditDialog("qq", this.viewModel.qq_id);
                                })
                            }
                            .width('100%').justifyContent(FlexAlign.SpaceBetween).padding({ top: 16, bottom: 16 })

                            // 网易云音乐
                            Row() {
                                Row() {
                                    Image($r('app.media.icon_netease')).width(22).height(22).margin({ right: 12 })
                                    Text('网易云音乐').fontSize(16).fontColor('#333333')
                                }

                                Row() {
                                    Text(this.viewModel.netease_id || '未设置').fontSize(16).fontColor('#333333')
                                    Image($r('app.media.icon_edit')).width(20).height(20).margin({ left: 8 })
                                }
                                .onClick(() => {
                                    this.openEditDialog("netease", this.viewModel.netease_id);
                                })
                            }
                            .width('100%').justifyContent(FlexAlign.SpaceBetween).padding({ top: 16, bottom: 16 })

                            // 账号操作
                            Column() {
                                Button('修改密码')
                                    .onClick(() => {
                                        router.pushUrl({ url: RouterUrlConstants.RETRIEVE_PASSWD })
                                    })
                                    .width('80%')
                                    .height(45)
                                    .fontSize(16)
                                    .backgroundColor('#376668')
                                    .fontColor('#FFFFFF')
                                    .borderRadius(22.5)
                                    .margin({ top: 30, bottom: 16 })

                                Button('退出登录')
                                    .onClick(() => this.logout())
                                    .width('80%')
                                    .height(45)
                                    .fontSize(16)
                                    .backgroundColor('#FFFFFF')
                                    .fontColor('#FF6B6B')
                                    .borderRadius(22.5)
                                    .borderWidth(1)
                                    .borderColor('#FF6B6B')
                            }
                            .width('100%')
                            .margin({ top: 30 })
                            .alignItems(HorizontalAlign.Center)
                        }
                        .width('90%')
                        .backgroundColor('#FFFFFF')
                        .borderRadius(16)
                        .padding({ top: 16, bottom: 24, left: 16, right: 16 })
                        .shadow({ radius: 6, color: 'rgba(0, 0, 0, 0.1)', offsetX: 0, offsetY: 2 })
                    }
                    .width('100%')
                    .constraintSize({ minHeight: '100%' })
                    .alignItems(HorizontalAlign.Center)
                    .padding({ bottom: 30 })
                }
                .layoutWeight(1)
            }
            .width('100%')
            .height('100%')
            .backgroundColor('#F5F5F5')

            // 加载状态
            if (this.isLoading) {
                Column() {
                    LoadingProgress().width(50).height(50).color('#376668')
                    Text('处理中...').fontSize(16).fontColor('#FFFFFF').margin({ top: 10 })
                }
                .width('100%').height('100%').backgroundColor('rgba(0, 0, 0, 0.5)').justifyContent(FlexAlign.Center)
            }
        } // Stack
    } // build
}