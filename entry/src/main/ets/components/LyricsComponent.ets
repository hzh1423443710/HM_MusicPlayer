import { BreakpointType } from '../common/BreakpointSystem';
import { PlayConstants } from '../common/constants/PlayConstants';
import { MusicInfo } from '../model/MusicData';

@Preview
@Component
export struct LyricsComponent {
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
                        Text(this.music.name)
                            .fontSize(new BreakpointType({
                                sm: 24,
                                md: 24,
                                lg: 30
                            }).getValue(this.currentBreakpoint))
                            .fontColor('#376668')
                            .textAlign(TextAlign.Start)
                            .width('100%')

                        // 歌手
                        Text(this.music.singer)
                            .textAlign(TextAlign.Start)
                            .fontSize(new BreakpointType({
                                sm: 14,
                                md: 14,
                                lg: 18
                            }).getValue(this.currentBreakpoint))
                            .fontColor('#99376668')
                            .margin({ top: 6 })
                            .width('100%')

                        Text(PlayConstants.LYRICS_CONTENT)
                            .fontSize(new BreakpointType({
                                sm: 20,
                                md: 20,
                                lg: 24
                            }).getValue(this.currentBreakpoint))
                            .fontColor('#99376668')
                            .textAlign(TextAlign.Start)
                            .width('100%')
                            .margin({ top: 24 })
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
    } // build
}