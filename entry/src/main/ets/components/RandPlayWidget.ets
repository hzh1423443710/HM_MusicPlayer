import { MusicInfo } from '../model/MusicData'
import { RandPlayViewModel } from '../viewmodel/RandPlayViewModel'
import promptAction from '@ohos.promptAction';

// 随机一曲
@Preview
@Component
export struct RandPlayWidget {
    @Link vb_rand_play: RandPlayViewModel;
    @StorageLink('isPlay') isPlay: boolean = false;

    // preview
    // vb_rand_play = {
    //     title: '放松吧',
    //     brief: '尝试来点音乐提提神吧',
    //     musicInfo: { pic: '', name: '谁(live)', singer: '廖俊涛' }
    // }

    aboutToAppear(): void {
        console.log('RandPlayWidget aboutToAppear');
        this.vb_rand_play.loadMusic().then(() => {
            console.log(`随机一首 加载成功`)
            this.vb_rand_play.debugInfo();
        }).catch((e) => {
            console.error(`随机一首 加载失败`)
        });
    }

    aboutToDisappear(): void {
        this.vb_rand_play.destroy()
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

                    Image(this.isPlay ? $r('app.media.ic_public_pause_norm') : $r('app.media.ic_public_play_norm'))
                        .width($r("app.float.control_icon_width"))
                        .height($r("app.float.control_icon_height"))
                        .onClick(() => {
                            promptAction.showToast({ message: '播放' })

                        })
                }
                .height('100%')
                .width(80)
                .padding({ top: 15, bottom: 10, left: 5 })

                Image(this.vb_rand_play.musicInfo.pic)// Image($r('app.media.default_cover_rect'))
                    .alt($r('app.media.default_cover_rect'))
                    .width(100)
                    .height(100)
                    .objectFit(ImageFit.Contain)
                    .backdropBlur(20)
                    .onClick(() => {
                        // 更新
                        this.vb_rand_play.loadMusic().then(() => {
                            promptAction.showToast({
                                message: '刷新成功'
                            })
                        });
                    })


            } // Row
            .width('100%')
            .height('85%')
            // .borderWidth(1)
            .borderRadius(20)
            .backgroundImage($r('app.media.ic_avatar1'))
            .backgroundImageSize(ImageSize.Cover)
            .backgroundBlurStyle(BlurStyle.Regular)

            Row() {
                Text(this.vb_rand_play.musicInfo.name + '-' + this.vb_rand_play.musicInfo.singer)// Text('随机一曲' + '-' + '廖峻涛')
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