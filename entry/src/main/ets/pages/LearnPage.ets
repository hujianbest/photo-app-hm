@Entry
@Component
struct LearnPage {
  build() {
    Column() {
      Text('学习 - 课程列表')
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .backgroundColor('#F5F5F5')
  }
}
