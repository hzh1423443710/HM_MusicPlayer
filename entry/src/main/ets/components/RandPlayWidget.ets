import { MusicInfo, PlayListType } from '../model/MusicData'
import { RandPlayViewModel } from '../viewmodel/RandPlayViewModel'
import promptAction from '@ohos.promptAction';
import { MediaService } from '../common/MediaService';
import ConnectionUtil from '../common/network/ConnectionUtils'

// 随机一曲
@Preview
@Component
export struct RandPlayWidget {
    @Link viewModel: RandPlayViewModel;
    @StorageLink('isPlay') @Watch('onPlayChanged') isPlay: boolean = false;
    @State music: MusicInfo = new MusicInfo();
    @StorageProp('needAppend') @Watch('onNeedAppend') needAppend: number = 0;
    @StorageProp('updateUITrigger') @Watch('onUpdateUITrigger') updateUI: number = 0;
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

    /**
     * 更新UI显示
     */
    onUpdateUITrigger() {
        this.music = MediaService.getInstance().getCurrentMusic();
    }

    /**
     * 追加一组 随机一曲音乐 到播放器
     */
    onNeedAppend() {
        const media = MediaService.getInstance();
        this.viewModel.getBatchMusic().then((musics: MusicInfo[]) => {
            this.music = media.appendRandomMusics(musics);
        }).catch((e) => {
            console.error(`getBatchMusic: ${e}`);
        });
    }

    aboutToAppear(): void {
        console.log('RandPlayWidget aboutToAppear');
        // 初始化 随机一曲 播放队列
        this.loadMusic();
        // this.music = media.appendRandomMusics([
        // // 可以试听的VIP歌曲
        //     new MusicInfo(0, "2114626833", "Once Upon A Time (House Mix)", "Max Oazo", "http://music.163.com/song/media/outer/url?id=2114626833", "http://p2.music.126.net/tyMdxKFIdPdc59zPGTuXuA==/109951169237097692.jpg"),
        //     // 不能试听的VIP歌曲
        //     new MusicInfo(1, "2690339159", "Redline", "乐正绫", "http://music.163.com/song/media/outer/url?id=2690339159", "http://p1.music.126.net/x08erxs8P8tGxKeCqrVzlg==/109951170678036936.jpg")
        //
        // ]);
    }

    loadMusic() {
        const media = MediaService.getInstance();
        this.viewModel.getBatchMusic().then((musics: MusicInfo[]) => {
            this.music = media.appendRandomMusics(musics);
        }).catch((e) => {
            console.error(`getBatchMusic: ${e}`);
        });
    }

    aboutToDisappear(): void {
        this.viewModel.destroy()
        console.log('RandPlayWidget aboutToDisappear');
    }

    async playCurrentSong() {
        if (!await ConnectionUtil.isNetworkConnected()) {
            promptAction.showToast({ message: `网络不可用` })
            return;
        }

        const media = MediaService.getInstance();
        media.debugState();

        // 当前播放列表未改变
        if (media.getCurrentPlaylistType() === this.viewModel.playlistType) {
            if (media.isPlaying())
                media.pause();

            if (media.isPause())
                media.play();

            // 遇到不能试听的VIP歌曲 -> idle
            if (media.idle()) {
                if (!media.rePlay()) {
                    promptAction.showToast({ message: 'VIP歌曲无法播放', bottom: 400 });
                    return;
                }
            }
        } else {
            if (!media.playRandomSong()) {
                promptAction.showToast({ message: `${this.music.name}播放失败` })
            }
        }

        promptAction.showToast({
            message: `${this.music.name}` })
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
            // .borderWidth(1)
            .borderRadius(20)
            .backgroundImage($r('app.media.ic_avatar1'))
            .backgroundImageSize(ImageSize.Cover)
            .backgroundBlurStyle(BlurStyle.Regular)

            // Name + Singer
            Row() {
                Text(this.music.name + '-' + this.music.singer)
                    .width('100%')
                    .maxLines(1)
                // .borderWidth(1)
            }
            .height('15%')

        } // Column
        .width(200)
        .height(140)
    } // build
}