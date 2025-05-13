import { MediaService, PlayerState } from '../common/MediaService';
import { HeaderWidget } from '../components/HeaderWidget';
import { MusicInfo, PlaylistType } from '../model/MusicData';
import router from '@ohos.router';
import { PlaylistViewModel, playlistViewModel } from '../viewmodel/PlaylistViewModel'
import { MusicItem } from '../components/MusicItem';
import promptAction from '@ohos.promptAction';

@Entry
@Component
struct PlaylistPage {
    viewModel: PlaylistViewModel = playlistViewModel;
    @State playButtonState: boolean = false;
    @State currentMusic: MusicInfo = new MusicInfo();
    @StorageProp('playState') @Watch('onPlayStateChanged') playState: PlayerState = PlayerState.IDLE;
    @StorageProp('currentPlaylistType') @Watch('onQueuePlaylistChanged') playerPlaylistType: string = PlaylistType.NONE;
    media: MediaService = MediaService.getInstance();

    onPlayStateChanged() {
        this.playButtonState = (this.playerPlaylistType === this.viewModel.playlistType) && this.playState === PlayerState.PLAY;
        this.currentMusic = this.media.getCurrentMusic();
    }

    onQueuePlaylistChanged() {
        this.playButtonState = (this.playerPlaylistType === this.viewModel.playlistType) && this.playState === PlayerState.PLAY;
    }

    aboutToAppear() {
        const params = router.getParams();
        this.viewModel.setPlaylistInfo(params['id'], params['platform'], params['name'], params['count']);

        this.currentMusic = this.media.getCurrentMusic();
        this.onPlayStateChanged();
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
                            this.media.playAll(this.viewModel.songDataSource.items, this.viewModel.playlistType);
                            return;
                        }

                        this.playButtonState ? this.media.pause() : this.media.play();
                    })

                Text(this.viewModel.name).fontSize(24).fontWeight(FontWeight.Bold)

                Blank()

                Text(this.viewModel.brief).fontSize(24).fontWeight(FontWeight.Bold)

                Image($r('app.media.refresh')).width(32).height(32)
                    .onClick(() => {
                        this.viewModel.refreshPlaylist()
                            .then(() => {
                                promptAction.showToast({ message: '刷新完成' });
                            });
                    })

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
                                this.media.playOne(item, this.viewModel.songDataSource.items,
                                    this.viewModel.playlistType);
                            })
                    }
                    .backgroundColor(this.currentMusic && this.currentMusic.equals(item) ? $r('app.color.selected') : Color.Transparent)
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
