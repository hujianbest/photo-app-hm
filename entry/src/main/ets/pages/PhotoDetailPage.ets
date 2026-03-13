import { PhotoDetailViewModel } from '../viewmodels/PhotoDetailViewModel';
import { Photo } from '../models/Photo';
import router from '@ohos.router';
import promptAction from '@ohos.promptAction';

@Entry
@Component
struct PhotoDetailPage {
  @State viewModel: PhotoDetailViewModel = new PhotoDetailViewModel();
  @State photo: Photo | null = null;
  @State currentIndex: number = 0;
  @State totalPhotos: number = 0;
  @State showTagDialog: boolean = false;

  aboutToAppear() {
    const photoId = router.getParams()?.['photoId'] as number;
    if (photoId) {
      this.viewModel.onDataChange(() => {
        this.photo = this.viewModel.getPhoto();
        this.currentIndex = this.viewModel.getCurrentIndex();
        this.totalPhotos = this.viewModel.getTotalPhotos();
      });
      this.viewModel.loadPhoto(photoId);
    }
  }

  build() {
    Stack() {
      Column() {
        // 头部
        Row() {
          Button('<')
            .fontSize(24)
            .backgroundColor(Color.Transparent)
            .fontColor(Color.White)
            .onClick(() => {
              router.back();
            })

          Text(`${this.currentIndex + 1}/${this.totalPhotos}`)
            .fontSize(16)
            .fontColor(Color.White)
            .layoutWeight(1)
            .textAlign(TextAlign.Center)

          Button('⋮')
            .fontSize(20)
            .backgroundColor(Color.Transparent)
            .fontColor(Color.White)
            .onClick(() => {
              this.showPhotoMenu();
            })
        }
        .width('100%')
        .padding(16)
        .backgroundColor('rgba(0, 0, 0, 0.5)')

        // 照片显示
        if (this.photo) {
          Image(this.photo.thumbnailPath || this.photo.originalPath)
            .width('100%')
            .layoutWeight(1)
            .objectFit(ImageFit.Contain)
            .backgroundColor('#000')
            .gesture(
              GestureGroup(GestureMode.Exclusive,
                // 左滑查看下一张
                SwipeGesture({ direction: SwipeDirection.Left })
                  .onAction(() => {
                    if (this.currentIndex < this.totalPhotos - 1) {
                      this.viewModel.nextPhoto();
                    }
                  }),
                // 右滑查看上一张
                SwipeGesture({ direction: SwipeDirection.Right })
                  .onAction(() => {
                    if (this.currentIndex > 0) {
                      this.viewModel.previousPhoto();
                    }
                  })
              )
            )
        }

        // 照片信息
        if (this.photo) {
          Column() {
            // 标签
            if (this.viewModel.getTags().length > 0) {
              Row() {
                ForEach(this.viewModel.getTags(), (tag: string) => {
                  Text(tag)
                    .fontSize(12)
                    .fontColor('#FFF')
                    .backgroundColor('rgba(255, 255, 255, 0.3)')
                    .borderRadius(12)
                    .padding({ left: 12, right: 12, top: 6, bottom: 6 })
                    .margin({ right: 8 })
                })
              }
              .width('100%')
              .margin({ bottom: 12 })
            }

            // 添加标签按钮
            Row() {
              Button('+ 添加标签')
                .fontSize(14)
                .backgroundColor('rgba(255, 255, 255, 0.3)')
                .fontColor(Color.White)
                .borderRadius(20)
                .padding({ left: 16, right: 16, top: 8, bottom: 8 })
                .onClick(() => {
                  this.showTagDialog = true;
                })
            }
            .width('100%')
          }
          .width('100%')
          .padding(16)
          .backgroundColor('rgba(0, 0, 0, 0.7)')
        }
      }
      .width('100%')
      .height('100%')
      .backgroundColor('#000')
    }
    .width('100%')
    .height('100%')
    .bindSheet(this.showTagDialog, this.TagDialog(), {
      height: 200,
      showClose: true
    })
  }

  @Builder
  TagDialog() {
    Column() {
      Text('添加标签')
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .margin({ bottom: 16 })

      Text('标签功能将在后续版本完善')
        .fontSize(14)
        .fontColor('#999')

      Button('关闭')
        .fontSize(16)
        .backgroundColor('#1890FF')
        .fontColor(Color.White)
        .layoutWeight(1)
        .height(44)
        .borderRadius(22)
        .margin({ top: 24 })
        .onClick(() => {
          this.showTagDialog = false;
        })
    }
    .width('100%')
    .padding(24)
  }

  showPhotoMenu(): void {
    promptAction.showDialog({
      title: '照片操作',
      buttons: [
        { text: '取消', color: '#999' },
        { text: '编辑标签', color: '#333' },
        { text: '删除', color: '#F5222D' }
      ]
    }, (err, data) => {
      if (data.index === 1) {
        this.showTagDialog = true;
      } else if (data.index === 2) {
        this.deletePhoto();
      }
    });
  }

  deletePhoto(): void {
    promptAction.showDialog({
      title: '确认删除',
      message: '删除这张照片？',
      buttons: [
        { text: '取消', color: '#999' },
        { text: '删除', color: '#F5222D' }
      ]
    }, async (err, data) => {
      if (data.index === 1) {
        const success = await this.viewModel.deletePhoto();
        if (success) {
          promptAction.showToast({ message: '删除成功' });
          router.back();
        } else {
          promptAction.showToast({ message: '删除失败' });
        }
      }
    });
  }
}
