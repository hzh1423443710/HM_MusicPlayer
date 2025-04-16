import { MusicInfo } from '../model/MusicData'
import promptAction from '@ohos.promptAction';

// 一首音乐 cover + name + singer + Like
@Preview
@Component
export struct MusicItem {
    // 是否显示封面
    showCover: boolean = true;
    song: MusicInfo = new MusicInfo(0, "2689031892", "谁(Live)", "廖俊涛", "http://music.163.com/song/media/outer/url?id=2689031892");

    build() {
        Row({ space: 10 }) {
            if (this.showCover) {
                Image(this.song.pic)
                    .alt($r("app.media.default_cover_rect"))
                    .borderWidth(1)
                    .borderColor(Color.Brown)
                    .height($r('app.float.cover_height'))
                    .width($r('app.float.cover_width'))
            }
            Column() {
                Text(this.song.name)
                    .fontColor($r('app.color.song_name'))
                    .fontSize(18)
                    .maxLines(1)
                Text(this.song.singer)
                    .fontColor($r('app.color.singer'))
                    .fontSize(14)
                    .textOverflow({ overflow: TextOverflow.Ellipsis })
                    .maxLines(1)
                    .opacity($r('app.float.singer_opacity'))
            }
            .alignItems(HorizontalAlign.Start)
            .padding({ top: 5, bottom: 5 })

            Blank()

            // Love
            Image(this.song.love ? $r('app.media.ic_public_like_filled') : $r('app.media.ic_public_like'))
                .fillColor(this.song.love ? Color.Red : Color.Gray)
                .height(30)
                .width(30)
                .onClick(() => {
                    if (!AppStorage.Get<boolean>('isLogged')) {
                        promptAction.showToast({ message: '请先登录' });
                        return;
                    }

                    this.song.love = !this.song.love;
                })

        } // Row
        .width('100%')
        .padding({ left: 5, top: 5, bottom: 5, right: 15 })
    } // build
}