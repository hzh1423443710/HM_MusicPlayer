import { MusicInfo, PlayListType } from '../model/MusicData';
import { BaseNetEasePlayListViewModel } from '../viewmodel/BaseNetEasePlayListViewModel'
import ConnectionUtil from '../common/network/ConnectionUtils'
import promptAction from '@ohos.promptAction';
import { MusicItem } from './MusicItem';
import { MediaService } from '../common/MediaService';

@Preview
@Component
export struct SwiperListWidget {
    @Link viewModel: BaseNetEasePlayListViewModel;
    private itemsPerPage: number = 3;
    @StorageLink('isPlay') @Watch('onPlayChanged') isPlay: boolean = false;
    @StorageProp('currentPlaylistType') @Watch('onQueuePlaylistChanged') playerPlaylistType: PlayListType = PlayListType.NONE;
    @State playButtonState: boolean = false;

    /**
     * 播放器播放队列类型发生变化
     */
    onQueuePlaylistChanged() {
        this.playButtonState = (this.playerPlaylistType === this.viewModel.playlistType) && this.isPlay;
    }

    onPlayChanged() {
        this.playButtonState = (this.playerPlaylistType === this.viewModel.playlistType) && this.isPlay;
    }

    aboutToAppear() {
        this.viewModel.loadMusic().then(() => {
            console.log(`${this.viewModel.title} 加载成功`)
            // this.viewModel.debugInfo();
        }).catch((e) => {
            console.error(`${this.viewModel.title} 加载失败`)
        });
    }

    aboutToDisappear(): void {
        this.viewModel.destroy()
    }

    // 计算总页数
    private getPageCount(): number {
        if (!this.viewModel.musicList || this.viewModel.musicList.length === 0) {
            return 0;
        }
        return Math.ceil(this.viewModel.musicList.length / this.itemsPerPage);
    }

    // 获取指定页的歌曲
    private getMusicItemsForPage(pageIndex: number): MusicInfo[] {
        const startIndex = pageIndex * this.itemsPerPage;
        const endIndex = Math.min(startIndex + this.itemsPerPage, this.viewModel.musicList.length);
        return this.viewModel.musicList.slice(startIndex, endIndex);
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
                        const media = MediaService.getInstance();
                        media.playAll(this.viewModel.musicList, this.viewModel.playlistType);
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
                    // 网络是否连接
                    ConnectionUtil.isNetworkConnected().then((ok) => {
                        if (this.viewModel.isLoading) {
                            promptAction.showToast({
                                message: '已经在加载了',
                            });
                            return;
                        }
                        if (ok) {
                            promptAction.showToast({
                                message: '正在刷新',
                            });

                            this.viewModel.loadMusic().then(() => {
                                promptAction.showToast({
                                    message: `刷新成功`,
                                });
                            });

                        } else {
                            promptAction.showToast({
                                message: '网络未连接',
                            })
                        }

                    });
                })

            } // Row
            .height(40)
            .width('100%')
            .alignItems(VerticalAlign.Center)

            // 播放列表
            Swiper() {
                // 根据总歌曲数量计算页数
                ForEach(new Array(this.getPageCount()).fill(0), (_, pageIndex: number) => {
                    Column() {
                        // 获取当前页的歌曲并显示
                        ForEach(this.getMusicItemsForPage(pageIndex), (item: MusicInfo) => {
                            MusicItem({ data: item })

                        }, (item) => item.id) // 使用ID作为唯一键
                    }
                }, (_, index) => `page_${index}`) // 使用页码作为唯一键
            }
            .cachedCount(3)
            .loop(true)
            .autoPlay(false)
            .indicator(false)
            .height($r('app.float.swiper_list_height'))
        } // Column

    }
}