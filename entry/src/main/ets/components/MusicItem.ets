import { MusicInfo, MusicFrom, PlayListType } from '../model/MusicData'
import promptAction from '@ohos.promptAction';

// 一首音乐 cover + name + singer + Like
@Preview
@Component
export struct MusicItem {
    // 是否显示封面
    showCover: boolean = true;
    data: MusicInfo = new MusicInfo(0, "2689031892", "谁(Live)", "廖俊涛", "http://music.163.com/song/media/outer/url?id=2689031892");

    build() {
        Row({ space: 10 }) {
            if (this.showCover) {
                Image(this.data.pic)
                    .alt($r("app.media.default_cover_rect"))
                    .borderWidth(1)
                    .borderColor(Color.Brown)
                    .height($r('app.float.cover_height'))
                    .width($r('app.float.cover_width'))
            }
            Column() {
                Text(this.data.name)
                    .fontColor($r('app.color.song_name'))
                    .fontSize(18)
                    .maxLines(1)
                Text(this.data.singer)
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
            Image(this.data.love ? $r('app.media.ic_public_like_filled') : $r('app.media.ic_public_like'))
                .fillColor(this.data.love ? Color.Red : Color.Gray)
                .height(30)
                .width(30)
                .onClick(() => {
                    if (!AppStorage.Get<boolean>('isLogged')) {
                        promptAction.showToast({ message: '请先登录' });
                        return;
                    }

                    this.data.love = !this.data.love;
                })

        } // Row
        .width('100%')
        .padding({ left: 5, top: 5, bottom: 5, right: 15 })
    } // build
}