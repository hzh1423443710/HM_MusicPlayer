import { MusicInfo, PlayListType } from '../model/MusicData'
import { RandPlayViewModel } from '../viewmodel/RandPlayViewModel'
import promptAction from '@ohos.promptAction';
import { MediaService } from '../common/MediaService';
import ConnectionUtil from '../common/network/ConnectionUtils'

// 随机一曲
@Preview
@Component
export struct RandPlayWidget {
    @Link vb_rand_play: RandPlayViewModel;
    @StorageLink('isPlay') isPlay: boolean = false;
    @State music: MusicInfo = new MusicInfo();
    @StorageProp('needAppend') @Watch('onNeedAppend') needAppend: number = 0;
    @StorageProp('updateUITrigger') @Watch('onUpdateUITrigger') updateUI: number = 0;

    onUpdateUITrigger() {
        this.music = MediaService.getInstance().getCurrentMusic();
    }

    onNeedAppend() {
        const media = MediaService.getInstance();
        this.vb_rand_play.getBatchMusic().then((musics: MusicInfo[]) => {
            this.music = media.appendRandomMusics(musics);
        }).catch((e) => {
            console.error(`getBatchMusic: ${e}`);
        });
    }

    aboutToAppear(): void {
        console.log('RandPlayWidget aboutToAppear');
        // 初始化 随机一曲 播放队列
        const media = MediaService.getInstance();
        this.vb_rand_play.getBatchMusic().then((musics: MusicInfo[]) => {
            this.music = media.appendRandomMusics(musics);
        }).catch((e) => {
            console.error(`getBatchMusic: ${e}`);
        });
    }

    aboutToDisappear(): void {
        this.vb_rand_play.destroy()
    }

    async playCurrentSong() {
        if (!await ConnectionUtil.isNetworkConnected()) {
            promptAction.showToast({ message: `网络不可用` })
            return;
        }

        const media = MediaService.getInstance();
        // 当前播放列表未改变
        if (media.getCurrentPlaylistType() === PlayListType.NETEASE_RANDOM_SONG) {
            if (this.isPlay)
                media.pause();
            if (media.isPause())
                media.play();
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
                    Text(this.vb_rand_play.title)
                        .fontSize(18)
                        .fontWeight(FontWeight.Bold)

                    Text(this.vb_rand_play.brief)
                        .fontSize(15)
                        .textOverflow({ overflow: TextOverflow.Ellipsis })
                        .maxLines(2)
                        .margin({ top: 4 })

                    Blank()

                    // Button play
                    Image(this.isPlay ? $r('app.media.ic_public_pause_norm') : $r('app.media.ic_public_play_norm'))
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