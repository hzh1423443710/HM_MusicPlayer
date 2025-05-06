import { SingerInfo } from '../model/SingerData';

@Preview
@Component
export struct SingerItem {
    index?: number;
    singer: SingerInfo = new SingerInfo();

    build() {
        Row({ space: 10 }) {
            if (this.index) {
                Text(`${this.index}`)
                    .textAlign(TextAlign.Center)
                    .width(50)
                    .fontWeight(FontWeight.Bold)
            }
            Image(this.singer.pic)
                .alt($r("app.media.default_singer"))
                .borderColor(Color.Brown)
                .height($r('app.float.cover_height'))
                .width($r('app.float.cover_width'))
            Column() {
                Text(this.singer.name)
                    .fontColor($r('app.color.song_name'))
                    .fontSize(18)
                    .maxLines(1)
            }
            .alignItems(HorizontalAlign.Start)
            .justifyContent(FlexAlign.Center)
            .padding({ top: 5, bottom: 5 })

        } // Row
        .width('100%')
        .padding({ left: 5, top: 5, bottom: 5, right: 15 })
    } // build
}
