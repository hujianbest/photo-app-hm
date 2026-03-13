import router from '@ohos.router';
import promptAction from '@ohos.promptAction';

@Entry
@Component
struct PostCreatePage {
  @State content: string = '';
  @State selectedPhotos: string[] = [];
  @State selectedTopic: string = '';

  build() {
    Column() {
      // 头部
      Row() {
        Button('取消')
          .fontSize(16)
          .backgroundColor(Color.Transparent)
          .fontColor('#333')
          .onClick(() => {
            router.back();
          })

        Text('发布作品')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .layoutWeight(1)

        Button('发布')
          .fontSize(16)
          .backgroundColor('#1890FF')
          .fontColor(Color.White)
          .borderRadius(20)
          .padding({ left: 20, right: 20, top: 8, bottom: 8 })
          .onClick(() => {
            this.publishPost();
          })
      }
      .width('100%')
      .padding(16)
      .backgroundColor(Color.White)
      .border({ width: { bottom: 1 }, color: '#E8E8E8' })
    }

    // 内容输入
    Column() {
      TextArea({ placeholder: '分享你的摄影心得...', text: this.content })
        .width('100%')
        .height(150)
        .backgroundColor(Color.Transparent)
        .margin({ top: 16 })
        .onChange((value: string) => {
          this.content = value;
        })

      Divider()
        .color('#E8E8E8')

      // 选择照片
      Row() {
        Image($r('app.media.ic_add_photo'))
          .width(24)
          .height(24)
          .margin({ right: 8 })

        Text('添加照片')
          .fontSize(15)
          .fontColor('#333')
      }
      .width('100%')
      .height(60)
      .padding(16)
      .backgroundColor('#F5F5F5')
      .borderRadius(8)
      .margin({ top: 16 })
      .onClick(() => {
        promptAction.showToast({ message: 'PhotoPicker即将集成' });
      })

      // 话题选择
      Row() {
        Image($r('app.media.ic_topic'))
          .width(24)
          .height(24)
          .margin({ right: 8 })

        Text(this.selectedTopic || '选择话题')
          .fontSize(15)
          .fontColor(this.selectedTopic ? '#1890FF' : '#333')
      }
      .width('100%')
      .height(60)
      .padding(16)
      .backgroundColor('#F5F5F5')
      .borderRadius(8)
      .onClick(() => {
        // TODO: 跳转到话题选择
        promptAction.showToast({ message: '话题选择即将完善' });
      })
    }
    .width('100%')
    .layoutWeight(1)
    .padding(16)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Color.White)
  }

  publishPost(): void {
    if (!this.content.trim() && this.selectedPhotos.length === 0) {
      promptAction.showToast({ message: '请输入内容或选择照片' });
      return;
    }

    // TODO: 实现发布逻辑
    promptAction.showToast({ message: '发布功能即将完善' });
  }
}
