import { BreakpointType } from '../common/BreakpointSystem';
import { PlayConstants } from '../common/constants/PlayConstants';
import { MediaService, PlayerState } from '../common/MediaService';
import { PlayControlModel } from '../model/PlayControlModel';
import { playControl } from '../viewmodel/PlayData'
import { PlayControlComponent } from './PlayControlComponent';


@Preview
@Component
export struct ControlComponent {
    @StorageProp('currentBreakpoint') currentBreakpoint: string = 'sm';
    @StorageLink('currentTime') currentTime: string = '00:00';
    @StorageLink('totalTime') totalTime: string = '00:00';
    @StorageLink('progress') value: number = 0;
    @StorageLink('progressMax') max: number = 0;
    @State controlItems: PlayControlModel[] = playControl;
    media: MediaService = MediaService.getInstance();

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
                        lg: PlayConstants.SPAN_FOUR
                    },
                    offset: {
                        md: PlayConstants.OFFSET_ONE,
                        lg: PlayConstants.OFFSET_ONE
                    }
                }) {
                    Column() {
                        Flex({ justifyContent: FlexAlign.SpaceBetween, alignItems: ItemAlign.Center }) {
                            Text(this.currentTime)
                                .width(58)
                                .textAlign(TextAlign.Center)
                                .fontColor('#99376668')
                                .fontSize(new BreakpointType({
                                    sm: 12,
                                    md: 12,
                                    lg: 15
                                }).getValue(this.currentBreakpoint))
                            Slider({ min: 0, max: this.max, step: PlayConstants.SLIDE_STEP, value: this.value })
                                .blockColor('#376668')
                                .selectedColor('#376668')
                                .trackColor('#33376668')
                                .onChange((value: number, mode: SliderChangeMode) => {
                                    if (mode === SliderChangeMode.End || mode === SliderChangeMode.Begin ||
                                        mode === SliderChangeMode.Click) {
                                        this.media.seek(value);
                                    }
                                })
                            Text(this.totalTime)
                                .width(58)
                                .textAlign(TextAlign.Center)
                                .fontColor('#99376668')
                                .fontSize(new BreakpointType({
                                    sm: 12,
                                    md: 12,
                                    lg: 15
                                }).getValue(this.currentBreakpoint))
                        }
                        .margin({ top: 18, bottom: 18 })

                        // 播放顺序 上一首 下一首 播放列表
                        Flex({ justifyContent: FlexAlign.SpaceBetween, alignItems: ItemAlign.Center }) {
                            ForEach(this.controlItems, (item: PlayControlModel, index: number) => {
                                PlayControlComponent({ playControl: this.controlItems[index], index: index })
                            })
                        } // Flex

                    } // Column
                } // GridCol
            } // GridRow
        } // Column
        .margin({ top: 24, left: 24, right: 24, bottom: 56 })
    }
}