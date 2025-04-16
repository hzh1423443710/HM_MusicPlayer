import { MusicInfo, PlaylistType } from '../model/MusicData';
import { BaseNetEasePlayListViewModel } from '../viewmodel/BaseNetEaseSwiperListViewModel'
import promptAction from '@ohos.promptAction';
import { MusicItem } from './MusicItem';
import { PlayerState, MediaService } from '../common/MediaService';

@Preview
@Component
export struct SwiperListWidget {
    @Link viewModel: BaseNetEasePlayListViewModel;
    @StorageProp('playState') @Watch('onPlayStateChanged') playState: PlayerState = PlayerState.IDLE;
    @StorageProp('currentPlaylistType') @Watch('onQueuePlaylistChanged') playerPlaylistType: PlaylistType = PlaylistType.NONE;
    @State playButtonState: boolean = false;
    media: MediaService = MediaService.getInstance();

    /**
     * 播放器播放队列类型发生变化
     */
    onQueuePlaylistChanged() {
        this.playButtonState = (this.playerPlaylistType === this.viewModel.playlistType) && this.playState === PlayerState.PLAY;
    }

    onPlayStateChanged() {
        this.playButtonState = (this.playerPlaylistType === this.viewModel.playlistType) && this.playState === PlayerState.PLAY;
    }

    aboutToAppear() {
        this.viewModel.loadMusic()
            .catch((e: Error) => {
                console.error(`${this.viewModel.title} 加载失败: ${e.message}`);
                promptAction.showToast({ message: e.message });
            });
    }

    aboutToDisappear(): void {
        this.viewModel.destroy()
    }

    refreshSwiper() {
        // 显示正在刷新的提示
        promptAction.showToast({ message: '正在刷新' });

        this.viewModel.loadMusic()
            .then(() => {
                promptAction.showToast({ message: '刷新成功' });
            })
            .catch((e) => {
                promptAction.showToast({ message: e.message || '未知错误' });
            });
    }

    build() {
        Column() {
            Row({ space: 5 }) {
                Text(this.viewModel.title)
                    .fontSize(20)
                    .fontWeight(500)

                // Button Play
                Image(this.playButtonState ? $r('app.media.ic_public_pause_norm') : $r('app.media.ic_public_play_norm'))
                    .width($r("app.float.control_icon_width"))
                    .height($r("app.float.control_icon_height"))
                    .onClick(() => {
                        if (this.media.getCurrentPlaylistType() !== this.viewModel.playlistType) {
                            this.media.playAll(this.viewModel.musicList, this.viewModel.playlistType);
                            return;
                        }

                        this.playButtonState ? this.media.pause() : this.media.play();
                    });

                Blank()
                Row() {
                    Text(this.viewModel.brief)
                        .fontSize($r('app.float.playlist_brief_font_size'))
                        .opacity(0.5)
                    Image($r('app.media.refresh'))
                        .alt($r('sys.media.ohos_app_icon'))
                        .height(24)
                        .width(24)
                        .fillColor($r('app.color.button_color'))
                }
                .onClick(() => {
                    this.refreshSwiper();
                })

            } // Row
            .height(40)
            .width('100%')
            .alignItems(VerticalAlign.Center)

            // 播放列表
            Swiper() {
                ForEach(new Array(this.viewModel.getPageCount()).fill(0), (_, pageIndex: number) => {
                    Column() {
                        // 获取当前页的歌曲并显示
                        ForEach(this.viewModel.getMusicItemsForPage(pageIndex), (item: MusicInfo) => {
                            MusicItem({ song: item })
                                .onClick(() => {
                                    this.media.playOne(item, this.viewModel.musicList, this.viewModel.playlistType);
                                })

                        })
                    }
                }, (_, index) => `page_${index}`) // 使用页码作为唯一键
            }
            .cachedCount(3)
            .loop(true)
            .autoPlay(false)
            .indicator(false)
            .height($r('app.float.swiper_list_height'))

        } // Column
    } // build
}
