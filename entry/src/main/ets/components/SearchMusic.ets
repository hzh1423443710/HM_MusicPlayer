// 搜索音乐

@Preview
@Component
export struct SearchWidget {
    @State placeholder: string = '搜索';

    build() {
        Row() {
            Search({ placeholder: this.placeholder })
                .borderWidth(1)
                .borderColor(Color.Brown)
                .width('85%')
                .backgroundColor(Color.White)
        }
        .width('100%')
        .justifyContent(FlexAlign.Start)
        .focusable(true)
        .focusOnTouch(true)
    }
}