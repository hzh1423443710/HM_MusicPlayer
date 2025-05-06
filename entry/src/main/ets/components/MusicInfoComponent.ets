import { BreakpointType } from '../common/BreakpointSystem';
import { PlayConstants } from '../common/constants/PlayConstants';
import { MusicInfo } from '../model/MusicData';
import promptAction from '@ohos.promptAction';

@Preview
@Component
export struct MusicInfoComponent {
    @StorageProp('currentBreakpoint') currentBreakpoint: string = 'sm';
    @Prop music: MusicInfo;

    build() {
        Column() {
            GridRow({
                columns: {
                    sm: PlayConstants.COLUMN_FOUR,
                    md: PlayConstants.COLUMN_EIGHT,
                    lg: PlayConstants.COLUMN_TWELVE
                },
                gutter: PlayConstants.GRID_COL_GUTTER
            }) {
                GridCol({
                    span: {
                        sm: PlayConstants.SPAN_FOUR,
                        md: PlayConstants.SPAN_FOUR,
                        lg: PlayConstants.SPAN_FOUR
                    },
                    offset: {
                        md: PlayConstants.OFFSET_TWO,
                        lg: PlayConstants.OFFSET_ONE
                    }
                }) {
                    this.BuilderCoverInfo()
                }

                GridCol({
                    span: { sm: PlayConstants.SPAN_FOUR, md: PlayConstants.SPAN_SIX, lg: 0 },
                    offset: { md: PlayConstants.OFFSET_THREE }
                }) {
                    this.BuilderMusicInfo()
                }
            }

            Blank()
            GridRow({
                columns: {
                    sm: PlayConstants.COLUMN_FOUR,
                    md: PlayConstants.COLUMN_EIGHT,
                    lg: PlayConstants.COLUMN_TWELVE
                },
                gutter: PlayConstants.GRID_COL_GUTTER
            }) {
                GridCol({
                    span: {
                        sm: PlayConstants.SPAN_FOUR,
                        md: PlayConstants.SPAN_SIX,
                        lg: PlayConstants.SPAN_FOUR
                    },
                    offset: {
                        md: PlayConstants.OFFSET_ONE,
                        lg: PlayConstants.OFFSET_ONE
                    }
                }) {
                    this.BuilderOperationInfo()
                }
            }
        }
        .margin({ left: 24, right: 24 })
        .height('100%')
    }

    /**
     * 封面
     */
    @Builder
    BuilderCoverInfo() {
        Image(this.music.pic)
            .alt($r('app.media.default_cover_rect'))
            .objectFit(ImageFit.Contain)
            .constraintSize({ maxWidth: new BreakpointType({
                sm: 296,
                md: 296,
                lg: 452
            }).getValue(this.currentBreakpoint) })
            .width('100%')
            .aspectRatio(1)
            .borderRadius(16)
            .margin({
                left: new BreakpointType({
                    sm: 10
                }).getValue(this.currentBreakpoint),
                right: new BreakpointType({
                    sm: 10
                }).getValue(this.currentBreakpoint),
                top: new BreakpointType({
                    sm: 16,
                    md: 16,
                    lg: 78
                }).getValue(this.currentBreakpoint)
            })
    }

    /**
     * 歌名 歌手
     */
    @Builder
    BuilderMusicInfo() {
        Column() {
            Text(this.music.name)
                .fontSize(24)
                .fontColor('#376668')
                .width('100%')

            Text(this.music.singer)
                .fontSize(14)
                .fontColor('#99376668')
                .margin({ top: 6 })
                .width('100%')
        }
        .alignItems(HorizontalAlign.Start)
        .width('100%')
        .margin({ top: 38 })
    }

    /**
     * 操作按钮
     */
    @Builder
    BuilderOperationInfo() {
        Flex({ justifyContent: FlexAlign.SpaceBetween }) {
            // 下载
            Image($r('app.media.ic_download'))
                .aspectRatio(1)
                .width(new BreakpointType({
                    sm: 24,
                    md: 24,
                    lg: 30
                }).getValue(this.currentBreakpoint))
                .objectFit(ImageFit.Contain)
                .onClick(() => {
                    promptAction.showToast({ message: '下载' })
                })

            // 喜欢
            Image($r('app.media.ic_public_like'))
                .aspectRatio(1)
                .width(new BreakpointType({
                    sm: 24,
                    md: 24,
                    lg: 30
                }).getValue(this.currentBreakpoint))
                .objectFit(ImageFit.Contain)
                .onClick(() => {
                    promptAction.showToast({ message: '喜欢' })
                })

            // 更多 - 添加到歌单
            Image($r('app.media.ic_public_more_list'))
                .aspectRatio(1)
                .width(new BreakpointType({
                    sm: 24,
                    md: 24,
                    lg: 30
                }).getValue(this.currentBreakpoint))
                .objectFit(ImageFit.Contain)
                .onClick(() => {
                    promptAction.showToast({ message: '更多' })
                })
        }
    }
}