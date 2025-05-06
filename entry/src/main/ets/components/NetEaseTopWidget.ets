import { MusicInfo, PlaylistType } from '../model/MusicData';
import { MusicItem } from './MusicItem';
import { BaseNetEaseLongListViewModel } from '../viewmodel/BaseNetEaseLongListViewModel'
import promptAction from '@ohos.promptAction';
import { MediaService, PlayerState } from '../common/MediaService';
import { BreakpointConstants } from '../common/constants/BreakpointConstants';

@Preview
@Component
export struct NetEaseTopWidget {
    @StorageProp('currentBreakpoint') currentBreakpoint: string = 'sm';
    @Link viewModel: BaseNetEaseLongListViewModel;
    @State isRefreshing: boolean = false;
    @StorageProp('playState') @Watch('onPlayStateChanged') playState: PlayerState = PlayerState.IDLE;
    @StorageProp('currentPlaylistType') @Watch('onQueuePlaylistChanged') playerPlaylistType: PlaylistType = PlaylistType.NONE;
    @State playButtonState: boolean = false;
    @State currentMusic: MusicInfo = new MusicInfo();
    media: MediaService = MediaService.getInstance();

    /**
     * 播放器播放队列 类型发生变化
     */
    onQueuePlaylistChanged() {
        this.playButtonState = (this.playerPlaylistType === this.viewModel.playlistType) && this.playState === PlayerState.PLAY;
    }

    /**
     * 播放状态发生变化
     */
    onPlayStateChanged() {
        this.playButtonState = (this.playerPlaylistType === this.viewModel.playlistType) && this.playState === PlayerState.PLAY;
        if (this.playerPlaylistType === this.viewModel.playlistType) {
            this.currentMusic = this.media.getCurrentMusic();
        }
    }

    aboutToAppear() {
        console.log(`NetEaseTopWidget aboutToAppear`);
        this.viewModel.loadMusicFirst()
            .catch((e: Error) => {
                console.error(`${this.viewModel.title}: ${e}`);
                promptAction.showToast({ message: e.message });
            });
    }

    aboutToDisappear(): void {
        this.viewModel.destroy();
    }

    // 刷新按钮点击处理
    refreshButtonClicked() {
        promptAction.showToast({ message: '正在刷新...' });

        this.viewModel.refreshMusic()
            .then((count) => {
                promptAction.showToast({ message: `刷新成功` });
            })
            .catch((e: Error) => {
                promptAction.showToast({ message: e.message });
            });
    }

    build() {
        Column() {
            // Header
            Row({ space: 5 }) {
                Text('播放列表')
                    .fontSize($r('app.float.playlist_title_font_size'))
                    .fontWeight(FontWeight.Bold)

                Image(this.playButtonState ? $r('app.media.ic_public_pause_norm') : $r('app.media.ic_public_play_norm'))
                    .width($r('app.float.control_icon_width'))
                    .height($r('app.float.control_icon_height'))
                    .onClick(() => {
                        if (this.media.getCurrentPlaylistType() !== this.viewModel.playlistType) {
                            this.media.playAll(this.viewModel.musicList, this.viewModel.playlistType);
                            return;
                        }

                        this.playButtonState ? this.media.pause() : this.media.play();
                    })
                Blank()
                Row() {
                    Text(this.viewModel.brief)
                    Image($r('app.media.refresh'))
                        .alt($r('sys.media.ohos_app_icon'))
                        .height(24)
                        .width(24)
                        .fillColor($r('app.color.button_color'))
                }
                .onClick(() => {
                    this.refreshButtonClicked();
                })
            }
            .width('100%')

            // 播放列表
            Refresh({ refreshing: $$this.isRefreshing }) {
                List() {
                    LazyForEach(this.viewModel.songDataSource, (item: MusicInfo, index: number) => {
                        ListItem() {
                            Row() {
                                MusicItem({ index: index + 1, song: item, showCover: !(index >= 3) })// .layoutWeight(1)
                                    .onClick(() => {
                                        this.media.playOne(item, this.viewModel.musicList, this.viewModel.playlistType);
                                    })
                            }
                            .justifyContent(FlexAlign.Start)
                        } // ListItem
                        .backgroundColor(this.playerPlaylistType === this.viewModel.playlistType && this.currentMusic.equals(item)
                            ? $r('app.color.selected')
                            : Color.Transparent)
                    })
                } // List
                .scrollBar(BarState.Off)
                .edgeEffect(EdgeEffect.Spring)
                .width('100%')
                .cachedCount(10)
                .lanes(this.currentBreakpoint === BreakpointConstants.BREAKPOINT_LG ? 2 : 1)
                .onReachEnd(() => {
                    // 触底动态加载
                    let cnt: number = this.viewModel.loadMusicNonFirst();
                    if (cnt > 0) {
                        promptAction.showToast({ message: `${cnt}首加载成功` })
                    } else {
                        promptAction.showToast({ message: "已加载全部" })
                    }
                })

            }
            .onStateChange((state: RefreshStatus) => {
                switch (state) {
                    case RefreshStatus.Inactive:
                        break;
                    case RefreshStatus.Drag:
                        break;
                    case RefreshStatus.OverDrag:
                        break;
                    case RefreshStatus.Done:
                        promptAction.showToast({
                            message: '刷新完成'
                        });
                        break;
                }
            })
            .onRefreshing(async () => {
                this.viewModel.refreshMusic()
                    .catch((e: Error) => {
                        promptAction.showToast({ message: e.message });
                    })
                    .finally(() => {
                        this.isRefreshing = false;
                    });

            })
        } // Column
        .height('80%')
    } // build
}