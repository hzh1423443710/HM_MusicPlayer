import { MusicInfo } from '../model/MusicData'

// 一首音乐 cover + name + singer + Like
@Preview
@Component
export struct MusicItem {
    index?: number;
    showCover: boolean = true;
    song: MusicInfo = new MusicInfo(0, "2689031892", "谁(Live)", "廖俊涛", "http://music.163.com/song/media/outer/url?id=2689031892");

    build() {
        Row({ space: 10 }) {
            if (this.index) {
                Text(`${this.index}`)
                    .textAlign(TextAlign.Center)
                    .width(50)
                    .fontWeight(FontWeight.Bold)
            }

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
                    .width(200)
                    .textOverflow({ overflow: TextOverflow.Ellipsis })
                Text(this.song.singer)
                    .fontColor($r('app.color.singer'))
                    .fontSize(14)
                    .width(200)
                    .textOverflow({ overflow: TextOverflow.Ellipsis })
                    .maxLines(1)
                    .opacity($r('app.float.singer_opacity'))
            }
            .alignItems(HorizontalAlign.Start)
            .padding({ top: 5, bottom: 5 })

            Blank()
        } // Row
        .width('100%')
        .justifyContent(FlexAlign.SpaceEvenly)
        .margin({ top: 5, bottom: 5 })
    } // build
}