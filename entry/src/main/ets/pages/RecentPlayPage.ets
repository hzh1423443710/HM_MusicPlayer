import { MediaService, PlayerState } from '../common/MediaService';
import { MusicInfo, PlaylistType } from '../model/MusicData';
import { RecentPlayViewModel, recentPlayViewModel } from '../viewmodel/RecentPlayViewModel'
import { MusicItem } from '../components/MusicItem';
import { HeaderWidget } from '../components/HeaderWidget';

@Entry
@Component
struct RecentPlayPage {
    viewModel: RecentPlayViewModel = recentPlayViewModel;
    @State playButtonState: boolean = false;
    @State currentMusic: MusicInfo = new MusicInfo();
    @StorageProp('playState') @Watch('onPlayStateChanged') playState: PlayerState = PlayerState.IDLE;
    @StorageProp('currentPlaylistType') @Watch('onQueuePlaylistChanged') playerPlaylistType: string = PlaylistType.NONE;
    media: MediaService = MediaService.getInstance();

    /**
     * 播放状态发生变化
     */
    onPlayStateChanged() {
        this.playButtonState = (this.playerPlaylistType === this.viewModel.playlistType) && this.playState === PlayerState.PLAY;
        this.currentMusic = this.media.getCurrentMusic();
    }

    onQueuePlaylistChanged() {
        this.playButtonState = (this.playerPlaylistType === this.viewModel.playlistType) && this.playState === PlayerState.PLAY;
    }

    aboutToAppear() {
        this.currentMusic = this.media.getCurrentMusic();
        this.onPlayStateChanged();
        this.viewModel.refreshQueue();
    }

    build() {
        Column() {
            HeaderWidget()
            // 顶部栏
            Row() {
                Image(this.playButtonState ? $r('app.media.ic_public_pause_norm') : $r('app.media.ic_public_play_norm'))
                    .width($r('app.float.control_icon_width'))
                    .height($r('app.float.control_icon_height'))
                    .objectFit(ImageFit.Cover)
                    .margin({ right: 10 })
                    .onClick(() => {
                        if (this.media.playlistType !== this.viewModel.playlistType) {
                            this.media.playAll(this.viewModel.musicList, this.viewModel.playlistType);
                            return;
                        }

                        this.playButtonState ? this.media.pause() : this.media.play();
                    })

                Text(this.viewModel.title)
                    .fontSize(24)
                    .fontWeight(FontWeight.Bold)

                Blank()

                Text(this.viewModel.brief)
                    .fontSize(24)
                    .fontWeight(FontWeight.Bold)

            } // Row 顶部栏
            .width('100%')
            .justifyContent(FlexAlign.SpaceAround)
            .padding(16)

            Line()
                .width('100%')
                .height(1)
                .backgroundColor('rgba(0, 0, 0, 0.25)')

            List() {
                LazyForEach(this.viewModel.songDataSource, (item: MusicInfo, index: number) => {
                    ListItem() {
                        MusicItem({ index: index + 1, showCover: false, song: item })
                            .onClick(() => {
                                this.media.playOneRecent(item);
                            })
                    }
                    .backgroundColor(this.currentMusic.equals(item) ? $r('app.color.selected') : Color.Transparent)
                })
            }
            .width('100%')
            .layoutWeight(1)
            .divider({ strokeWidth: 1, color: 'rgba(255, 255, 255, 0.05)' })
        } // Column
        .width('100%')
        .height('100%')
        .backgroundImage($r('app.media.ic_avatar3'))
        .backgroundImageSize(ImageSize.Cover)
        .backgroundBlurStyle(BlurStyle.Regular)
    } // build
}
