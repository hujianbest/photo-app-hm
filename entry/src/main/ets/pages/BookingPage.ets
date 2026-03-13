@Entry
@Component
struct BookingPage {
  build() {
    Column() {
      Text('约拍 - 匹配列表')
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .backgroundColor('#F5F5F5')
  }
}
