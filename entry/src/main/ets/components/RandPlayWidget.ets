import { MusicInfo, PlaylistType } from '../model/MusicData'
import { RandPlayViewModel } from '../viewmodel/RandPlayViewModel'
import promptAction from '@ohos.promptAction';
import { PlayerState, MediaService } from '../common/MediaService';

// 随机一曲
@Preview
@Component
export struct RandPlayWidget {
    @Link viewModel: RandPlayViewModel;
    @State music: MusicInfo = new MusicInfo();
    @StorageProp('playState') @Watch('onPlayStateChanged') playState: PlayerState = PlayerState.IDLE;
    @StorageProp('needAppend') @Watch('onNeedAppend') needAppend: number = 0;
    @StorageProp('currentPlaylistType') @Watch('onQueuePlaylistChanged') playerPlaylistType: PlaylistType = PlaylistType.NONE;
    @State playButtonState: boolean = false;
    media: MediaService = MediaService.getInstance();

    /**
     * 播放器播放队列类型发生变化
     */
    onQueuePlaylistChanged() {
        this.playButtonState = (this.playerPlaylistType === this.viewModel.playlistType) && this.playState === PlayerState.PLAY;
    }

    /**
     * 播放状态发生变化
     */
    onPlayStateChanged() {
        this.playButtonState = (this.playerPlaylistType === this.viewModel.playlistType) && this.playState === PlayerState.PLAY;
        if (this.playerPlaylistType === PlaylistType.NETEASE_RANDOM_SONG) {
            const new_song = this.media.getCurrentMusic();
            if (!this.music.equals(new_song))
                this.music = new_song;
        }
    }

    /**
     * 追加一组 随机一曲音乐 到播放器
     */
    onNeedAppend() {
        this.viewModel.getBatchMusic().then((musics: MusicInfo[]) => {
            this.music = this.media.appendRandomMusics(musics);
        }).catch((e) => {
            console.error(`${this.viewModel.name}: ${e}`);
        });
    }

    aboutToAppear(): void {
        console.log('RandPlayWidget aboutToAppear');
        this.loadFirst();
    }

    loadFirst() {
        // 初始化 随机一曲 播放队列
        this.viewModel.getBatchMusic()
            .then((musics: MusicInfo[]) => {
                this.music = this.media.appendRandomMusics(musics);
            })
            .catch((e: Error) => {
                console.error(`${this.viewModel.name}: ${e}`);
                promptAction.showToast({ message: e.message });
            });

        // this.music = this.media.appendRandomMusics([
        // // 可以试听的VIP歌曲
        //     new MusicInfo(0, "2114626833", "Once Upon A Time (House Mix)", "Max Oazo", "http://music.163.com/song/media/outer/url?id=2114626833", "http://p2.music.126.net/tyMdxKFIdPdc59zPGTuXuA==/109951169237097692.jpg"),
        //     // 不能试听的VIP歌曲
        //     new MusicInfo(1, "2690339159", "Redline", "乐正绫", "http://music.163.com/song/media/outer/url?id=2690339159", "http://p1.music.126.net/x08erxs8P8tGxKeCqrVzlg==/109951170678036936.jpg")
        //
        // ]);
    }

    aboutToDisappear(): void {
        this.viewModel.destroy()
        console.log('RandPlayWidget aboutToDisappear');
    }

    async playCurrentSong() {
        // 未加载成功
        if (this.music.equals(new MusicInfo())) {
            promptAction.showToast({ message: '正在加载' });
            this.loadFirst();
            return;
        }

        // 当前播放列表未改变
        if (this.playerPlaylistType === this.viewModel.playlistType) {
            if (this.playState === PlayerState.PLAY)
                this.media.pause();
            if (this.playState === PlayerState.PAUSE)
                this.media.play();
        } else {
            this.media.playRandomSong();
        }
    }

    build() {
        Column() {
            Row({ space: 10 }) {
                Column() {
                    Text(this.viewModel.title)
                        .fontSize($r('app.float.playlist_title_font_size'))
                        .fontWeight(FontWeight.Bold)

                    Text(this.viewModel.brief)
                        .fontSize($r('app.float.playlist_brief_font_size'))
                        .textOverflow({ overflow: TextOverflow.Ellipsis })
                        .maxLines(2)
                        .margin({ top: 4 })

                    Blank()

                    // Button Play
                    Image(this.playButtonState ? $r('app.media.ic_public_pause_norm') : $r('app.media.ic_public_play_norm'))
                        .width($r("app.float.control_icon_width"))
                        .height($r("app.float.control_icon_height"))
                        .onClick(() => {
                            this.playCurrentSong();
                        })
                }
                .height('100%')
                .width(80)
                .padding({ top: 15, bottom: 10, left: 5 })

                // Cover
                Image(this.music.pic)
                    .alt($r('app.media.default_cover_rect'))
                    .width(100)
                    .height(100)
                    .objectFit(ImageFit.Contain)
                    .backdropBlur(20)
                    .onClick(() => {
                        this.playCurrentSong();
                    })
            } // Row
            .width('100%')
            .height('85%')
            .borderRadius(20)
            .backgroundImage($r('app.media.ic_avatar1'))
            .backgroundImageSize(ImageSize.Cover)
            .backgroundBlurStyle(BlurStyle.Regular)

            // Name + Singer
            Row() {
                Text(this.music.name + '-' + this.music.singer)
                    .width('100%')
                    .maxLines(1)
            }
            .height('15%')

        } // Column
        .width(200)
        .height(140)
    } // build
}