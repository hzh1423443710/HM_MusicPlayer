import { BreakpointType } from '../common/BreakpointSystem';
import { PlayConstants } from '../common/constants/PlayConstants';
import { MusicInfo } from '../model/MusicData';
import { LyricData, LyricLine } from '../common/LyricParseUtil';
import { MediaService } from '../common/MediaService';
import { LyricViewModel, lyricViewModel } from '../viewmodel/LyricViewModel';
import promptAction from '@ohos.promptAction';

const TAG: string = 'LyricsComponent';

@Preview
@Component
export struct LyricsComponent {
    @StorageProp('currentBreakpoint') currentBreakpoint: string = 'sm';
    @Prop @Watch('onMusicChanged') music: MusicInfo;
    // 歌词相关状态
    @State lyricData: LyricData = new LyricData();
    @State currentLyricIndex: number = -1;
    @State isLoading: boolean = false;
    @State error: string = '';
    @StorageProp('progress') @Watch('onProgressChanged') currentProgress: number = 0;
    @State actualScrollViewHeight: number = 0;
    // 歌词滚动相关参数
    private readonly lineHeight: number = 44;
    private readonly visibleLines: number = 7;
    private readonly scroller: Scroller = new Scroller();
    private mediaService: MediaService = MediaService.getInstance();
    private viewModel: LyricViewModel = lyricViewModel;

    // 计算屏幕可显示的总高度
    private get scrollViewHeight(): number {
        return this.lineHeight * this.visibleLines;
    }

    // 计算上下填充空白的高度
    private get paddingHeight(): number {
        return Math.floor(this.visibleLines / 2) * this.lineHeight;
    }

    aboutToAppear() {
        this.loadLyric();
    }

    /**
     * 音乐变更时的处理
     */
    onMusicChanged() {
        // console.info(TAG, '音乐变更，重新加载歌词');
        this.loadLyric();
    }

    /**
     * 加载歌词
     */
    async loadLyric() {
        if (!this.music || !this.music.id) {
            this.error = '无法加载歌词：音乐信息不完整';
            return;
        }

        this.isLoading = true;
        this.error = '';

        try {
            // 使用 ViewModel 加载歌词
            const { lyricData, error } = await this.viewModel.getLyric(this.music.id, this.music.where);

            if (!error) {
                this.lyricData = lyricData;
                this.error = '';
                // 加载成功后立即更新当前行
                this.updateCurrentLine();
            } else {
                this.error = error;
                this.lyricData = new LyricData();
            }
        } catch (err) {
            console.error(TAG, `加载歌词失败: ${err}`);
            this.error = '加载歌词失败';
        } finally {
            this.isLoading = false;
        }
    }

    /**
     * 更新当前歌词行并滚动居中
     */
    updateCurrentLine() {
        if (!this.lyricData || this.lyricData.lines.length === 0) return;

        const newIndex = this.lyricData.getCurrentIndex(this.currentProgress);
        if (newIndex !== this.currentLyricIndex) {
            this.currentLyricIndex = newIndex;

            // 精确计算滚动位置，确保当前行居中
            if (newIndex >= 0) {
                try {
                    // 使用实际测量的高度来计算中心位置
                    let viewHeight: number = 0;

                    if (this.actualScrollViewHeight > 0) {
                        viewHeight = this.actualScrollViewHeight;
                    } else {
                        viewHeight = this.lineHeight * this.visibleLines;
                    }

                    // 计算应该居中的偏移位置
                    const centerOffset = viewHeight / 2 - this.lineHeight / 2;

                    // 目标偏移量 = 当前行索引 * 行高 - 中心位置的偏移
                    const targetOffset = Math.max(0, newIndex * this.lineHeight - centerOffset);

                    // console.info(TAG, `滚动计算: 索引=${newIndex}, 视图高度=${viewHeight}, 居中偏移=${centerOffset}, 目标偏移=${targetOffset}`);

                    // 验证偏移量是有效数字
                    if (!isNaN(targetOffset) && isFinite(targetOffset)) {
                        // 平滑滚动
                        this.scroller.scrollTo({
                            xOffset: 0,
                            yOffset: targetOffset,
                            animation: {
                                duration: 300,
                                curve: Curve.EaseOut
                            }
                        });

                        // console.info(TAG, `滚动到歌词行 ${newIndex}, 时间: ${this.lyricData.lines[newIndex].time}ms, 偏移: ${targetOffset}`);
                    } else {
                        console.error(TAG, `计算滚动偏移量错误: ${targetOffset}, 高度: ${viewHeight}`);
                    }
                } catch (err) {
                    console.error(TAG, `滚动计算出错: ${err}`);
                }
            }
        }
    }

    /**
     * 点击歌词行跳转到对应时间点
     * @param time 目标时间点（毫秒）
     * @param index 歌词行索引
     */
    jumpToTime(time: number, index: number) {
        if (!this.mediaService) return;

        // 如果点击的是当前播放行，不做任何操作
        if (index === this.currentLyricIndex) return;

        try {
            // 跳转到指定时间点
            this.mediaService.seek(time);

            // 更新当前行索引(立即更新，提供即时反馈)
            this.currentLyricIndex = index;

            // 显示提示
            promptAction.showToast({
                message: '跳转到: ' + this.formatTime(time),
                duration: 1000,
                bottom: '70%'
            });

            // console.info(TAG, `跳转到歌词时间点: ${time}ms`);
        } catch (error) {
            console.error(TAG, `跳转失败: ${error}`);
        }
    }

    /**
     * 格式化时间为 mm:ss 格式
     */
    private formatTime(ms: number): string {
        const totalSeconds = Math.floor(ms / 1000);
        const minutes = Math.floor(totalSeconds / 60);
        const seconds = totalSeconds % 60;
        return `${minutes.toString().padStart(2, '0')}:${seconds.toString().padStart(2, '0')}`;
    }

    // 监听播放时间变化的回调
    onProgressChanged() {
        this.updateCurrentLine();
    }

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
                        md: PlayConstants.SPAN_SIX,
                        lg: PlayConstants.SPAN_SIX
                    },
                    offset: {
                        md: PlayConstants.OFFSET_ONE,
                        lg: PlayConstants.OFFSET_SIX
                    }
                }) {
                    Flex({ direction: FlexDirection.Column }) {
                        // 歌名
                        Text(this.music ? this.music.name : "")
                            .fontSize(new BreakpointType({
                                sm: 24,
                                md: 24,
                                lg: 30
                            }).getValue(this.currentBreakpoint))
                            .fontColor('#376668')
                            .textAlign(TextAlign.Start)
                            .width('100%')

                        // 歌手
                        Text(this.music ? this.music.singer : "")
                            .textAlign(TextAlign.Start)
                            .fontSize(new BreakpointType({
                                sm: 14,
                                md: 14,
                                lg: 18
                            }).getValue(this.currentBreakpoint))
                            .fontColor('#99376668')
                            .margin({ top: 6 })
                            .width('100%')

                        // 歌词内容区域 - 外部容器
                        Column() {
                            if (this.isLoading) {
                                // 加载中状态
                                Column() {
                                    LoadingProgress()
                                        .width(40)
                                        .height(40)
                                        .color('#376668')
                                    Text('加载歌词中...')
                                        .fontSize(16)
                                        .fontColor('#376668')
                                        .margin({ top: 16 })
                                }
                                .width('100%')
                                .height('100%')
                                .justifyContent(FlexAlign.Center)
                            } else if (this.error || this.lyricData.lines.length === 0) {
                                // 错误或无歌词状态
                                Column() {
                                    Text(this.error || '暂无歌词')
                                        .fontSize(16)
                                        .fontColor('#376668')
                                        .opacity(0.6)
                                }
                                .width('100%')
                                .height('100%')
                                .justifyContent(FlexAlign.Center)
                            } else {
                                // 显示歌词并滚动
                                Scroll(this.scroller) {
                                    Column() {
                                        // 顶部空白，使第一行能够滚动到中心位置
                                        Blank()
                                            .height(this.paddingHeight)

                                        // 歌词内容
                                        ForEach(this.lyricData.lines, (line: LyricLine, index: number) => {
                                            Column() {
                                                Text(line.text)// 增大当前行与其他行的字体大小差异
                                                    .fontSize(this.currentLyricIndex === index ? 20 : 16)
                                                    .fontWeight(this.currentLyricIndex === index ? FontWeight.Bold : FontWeight.Normal)
                                                    .fontColor(this.currentLyricIndex === index ? '#376668' : 'rgba(55, 102, 104, 0.5)')
                                                    .scale({
                                                        x: this.currentLyricIndex === index ? 1.05 : 1,
                                                        y: this.currentLyricIndex === index ? 1.05 : 1
                                                    })
                                                    .animation({
                                                        duration: 300,
                                                        curve: Curve.EaseOut
                                                    })
                                                    .maxLines(1)
                                                    .textOverflow({ overflow: TextOverflow.Ellipsis })
                                                    .textAlign(TextAlign.Center)
                                            }
                                            .width('100%')
                                            .height(this.lineHeight)
                                            .borderRadius(8)
                                            .justifyContent(FlexAlign.Center)
                                            // 增强当前行的背景对比度
                                            .backgroundColor(this.currentLyricIndex === index ? 'rgba(55, 102, 104, 0.15)' : 'transparent')
                                            .animation({
                                                duration: 200,
                                                curve: Curve.EaseInOut
                                            })
                                            .onClick(() => {
                                                this.jumpToTime(line.time, index);
                                            })
                                            .gesture(
                                                LongPressGesture()
                                                    .onAction(() => {
                                                        promptAction.showToast({
                                                            message: this.formatTime(line.time) + ' - ' + line.text,
                                                            duration: 2000
                                                        });
                                                    })
                                            )
                                        })

                                        // 底部空白，使最后一行能够滚动到中心位置
                                        Blank()
                                            .height(this.paddingHeight)
                                    }
                                    .width('100%')
                                }
                                .scrollBar(BarState.Off) // 隐藏滚动条
                                .scrollable(ScrollDirection.Vertical) // 只允许垂直滚动
                                .width('100%')
                                .height('100%')
                                .onAreaChange((oldArea: Area, newArea: Area) => {
                                    // 获取实际渲染的高度，确保是数字类型
                                    try {
                                        const newHeight = typeof newArea.height === 'string'
                                            ? parseFloat(newArea.height)
                                            : newArea.height as number;

                                        if (newHeight > 0 && this.actualScrollViewHeight !== newHeight) {
                                            // console.info(TAG, `区域高度变化: ${this.actualScrollViewHeight} -> ${newHeight}`);
                                            this.actualScrollViewHeight = newHeight;

                                            // 给组件一点时间完成渲染后再触发滚动更新
                                            setTimeout(() => {
                                                this.updateCurrentLine();
                                            }, 100); // 增加延迟以确保布局完全稳定
                                        }
                                    } catch (err) {
                                        console.error(TAG, `处理区域变化出错: ${err}`);
                                    }
                                })
                            }
                        }
                        .width('100%')
                        .height(this.scrollViewHeight)
                        .backgroundColor('rgba(255, 255, 255, 0.05)')
                        .borderRadius(16)
                    }
                }
            }
        } // Column
        .margin({
            top: new BreakpointType({
                sm: 24,
                md: 24,
                lg: 78
            }).getValue(this.currentBreakpoint),
            left: 24,
            right: 24
        })
        .onAppear(() => {
            // 初始更新当前歌词行
            this.updateCurrentLine();
        })
    } // build
}