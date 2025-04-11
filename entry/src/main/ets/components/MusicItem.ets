import { MusicInfo, MusicFrom, PlayListType } from '../model/MusicData'

// 一首音乐 cover + name + singer + Like
@Preview
@Component
export struct MusicItem {
    // 是否显示封面
    showCover: boolean = true;
    data: MusicInfo =
        {
            id: "2689031892",
            name: "谁(Live)",
            singer: "廖俊涛",
            url: "http://music.163.com/song/media/outer/url?id=2689031892",
            // pic: "https://p1.music.126.net/0bYf5pMHIEukf30qtLct2w==/109951170661034443.jpg",
            pic: "",
            lrc: '',
            duration: "02:21",
            pay: false,
            where: MusicFrom.NetEase,
            index: 0,
            playList: PlayListType.RECENT
        };

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
            Image($r('app.media.ic_public_like'))
                .height(30)
                .width(30)

        } // Row
        .width('100%')
        .padding({ left: 5, top: 5, bottom: 5, right: 15 })
    } // build
}