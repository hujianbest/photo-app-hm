@Entry
@Component
struct PhotoPage {
  build() {
    Column() {
      Text('照片 - 我的相册')
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .backgroundColor('#F5F5F5')
  }
}
