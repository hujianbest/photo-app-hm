import { AlbumDetailViewModel } from '../viewmodels/AlbumDetailViewModel';
import { Album } from '../models/Album';
import { Photo } from '../models/Photo';
import { AlbumService } from '../services/AlbumService';
import router from '@ohos.router';
import promptAction from '@ohos.promptAction';

@Entry
@Component
struct AlbumDetailPage {
  @State viewModel: AlbumDetailViewModel = new AlbumDetailViewModel();
  @State album: Album | null = null;
  @State photos: Photo[] = [];
  @State isLoading: boolean = false;
  @State isMultiSelectMode: boolean = false;
  @State selectedPhotos: Set<number> = new Set();
  @State showAlbumNameDialog: boolean = false;
  @State albumName: string = '';
  @State albumDescription: string = '';

  aboutToAppear() {
    const albumId = router.getParams()?.['albumId'] as number;
    if (albumId) {
      this.viewModel.onDataChange(() => {
        this.album = this.viewModel.getAlbum();
        this.photos = this.viewModel.getPhotos();
        this.isLoading = this.viewModel.isLoading();
        this.isMultiSelectMode = this.viewModel.isMultiSelectModeEnabled();
        this.selectedPhotos = new Set(this.viewModel.getSelectedPhotos());
      });
      this.viewModel.loadAlbum(albumId);
    }
  }

  build() {
    Column() {
      // 头部
      Row() {
        Button('<')
          .fontSize(24)
          .backgroundColor(Color.Transparent)
          .fontColor('#333')
          .onClick(() => {
            router.back();
          })

        Text(this.album?.name || '相册')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .layoutWeight(1)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .onClick(() => {
            if (this.album) {
              this.showAlbumNameDialog = true;
              this.albumName = this.album.name;
              this.albumDescription = this.album.description;
            }
          })

        Button(this.isMultiSelectMode ? '✓' : '⋮')
          .fontSize(18)
          .backgroundColor(Color.Transparent)
          .fontColor('#333')
          .onClick(() => {
            this.viewModel.toggleMultiSelectMode();
          })
      }
      .width('100%')
      .padding(16)
      .backgroundColor(Color.White)

      // 相册信息
      if (this.album) {
        Row() {
          Text(`${this.album.photoCount} 张照片`)
            .fontSize(14)
            .fontColor('#666')

          Text(this.album.description || '暂无描述')
            .fontSize(14)
            .fontColor('#999')
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .layoutWeight(1)
            .margin({ left: 16 })
        }
        .width('100%')
        .padding({ left: 16, right: 16, bottom: 12 })
        .backgroundColor(Color.White)
      }

      Divider()
        .color('#E8E8E8')

      // 内容区域
      if (this.isLoading) {
        Column() {
          LoadingProgress()
            .width(40)
            .height(40)
          Text('加载中...')
            .fontSize(14)
            .fontColor('#999')
            .margin({ top: 8 })
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
      } else if (this.photos.length === 0) {
        Column() {
          Text('📷')
            .fontSize(64)
            .margin({ bottom: 16 })
          Text('相册是空的')
            .fontSize(16)
            .fontColor('#666')
          Text('点击右下角添加照片')
            .fontSize(14)
            .fontColor('#999')
            .margin({ top: 8 })
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
      } else {
        this.PhotoGrid()
      }

      // 多选操作栏
      if (this.isMultiSelectMode && this.selectedPhotos.size > 0) {
        Row() {
          Text(`已选择 ${this.selectedPhotos.size} 张`)
            .fontSize(14)
            .fontColor('#666')
            .layoutWeight(1)

          Button('删除')
            .fontSize(14)
            .backgroundColor('#F5222D')
            .fontColor(Color.White)
            .borderRadius(20)
            .padding({ left: 16, right: 16, top: 8, bottom: 8 })
            .onClick(() => {
              this.deleteSelectedPhotos();
            })
        }
        .width('100%')
        .padding(16)
        .backgroundColor(Color.White)
        .border({ width: { top: 1 }, color: '#E8E8E8' })
      }

      // 浮动按钮
      if (!this.isMultiSelectMode) {
        Button('+')
          .fontSize(32)
          .width(56)
          .height(56)
          .borderRadius(28)
          .backgroundColor('#1890FF')
          .fontColor(Color.White)
          .position({ x: '85%', y: '85%' })
          .onClick(() => {
            this.addPhotos();
          })
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
    .bindSheet(this.showAlbumNameDialog, this.EditAlbumDialog(), {
      height: 300,
      showClose: true,
      onDisappear: () => {
        this.albumName = '';
        this.albumDescription = '';
      }
    })
  }

  @Builder
  PhotoGrid() {
    Grid() {
      ForEach(this.photos, (photo: Photo) => {
        GridItem() {
          Stack({ alignContent: Alignment.TopEnd }) {
            Image(photo.thumbnailPath || photo.originalPath)
              .width('100%')
              .aspectRatio(1)
              .backgroundColor('#E0E0E0')
              .borderRadius(4)
              .objectFit(ImageFit.Cover)
              .onClick(() => {
                if (this.isMultiSelectMode) {
                  this.viewModel.togglePhotoSelection(photo.id);
                } else {
                  router.pushUrl({
                    url: 'pages/PhotoDetailPage',
                    params: { photoId: photo.id }
                  });
                }
              })

            if (this.isMultiSelectMode) {
              Checkbox(this.selectedPhotos.has(photo.id))
                .select(this.selectedPhotos.has(photo.id))
                .width(24)
                .height(24)
                .margin(8)
                .onChange((value: boolean) => {
                  this.viewModel.togglePhotoSelection(photo.id);
                })
            }
          }
        }
      })
    }
    .columnsTemplate('1fr 1fr 1fr')
    .rowsGap(4)
    .columnsGap(4)
    .padding(8)
    .layoutWeight(1)
  }

  @Builder
  EditAlbumDialog() {
    Column() {
      Text('编辑相册')
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .margin({ bottom: 24 })

      TextInput({ placeholder: '相册名称', text: this.albumName })
        .width('100%')
        .height(44)
        .backgroundColor('#F5F5F5')
        .borderRadius(8)
        .padding({ left: 16, right: 16 })
        .margin({ bottom: 16 })
        .onChange((value: string) => {
          this.albumName = value;
        })

      TextInput({ placeholder: '相册描述（可选）', text: this.albumDescription })
        .width('100%')
        .height(44)
        .backgroundColor('#F5F5F5')
        .borderRadius(8)
        .padding({ left: 16, right: 16 })
        .margin({ bottom: 24 })
        .onChange((value: string) => {
          this.albumDescription = value;
        })

      Row() {
        Button('取消')
          .fontSize(16)
          .backgroundColor('#F5F5F5')
          .fontColor('#333')
          .layoutWeight(1)
          .height(44)
          .borderRadius(22)
          .onClick(() => {
            this.showAlbumNameDialog = false;
          })

        Button('保存')
          .fontSize(16)
          .backgroundColor('#1890FF')
          .fontColor(Color.White)
          .layoutWeight(1)
          .height(44)
          .borderRadius(22)
          .margin({ left: 12 })
          .onClick(async () => {
            if (!this.albumName.trim()) {
              promptAction.showToast({ message: '请输入相册名称' });
              return;
            }

            const success = await this.viewModel.updateAlbumInfo({
              name: this.albumName,
              description: this.albumDescription
            });
            if (success) {
              promptAction.showToast({ message: '保存成功' });
              this.showAlbumNameDialog = false;
            } else {
              promptAction.showToast({ message: '保存失败' });
            }
          })
      }
      .width('100%')
    }
    .width('100%')
    .padding(24)
  }

  addPhotos(): void {
    // 这将在后续更新中使用PhotoPicker实现
    promptAction.showToast({ message: 'PhotoPicker集成即将推出' });
  }

  deleteSelectedPhotos(): void {
    promptAction.showDialog({
      title: '确认删除',
      message: `删除选中的 ${this.selectedPhotos.size} 张照片？`,
      buttons: [
        { text: '取消', color: '#999' },
        { text: '删除', color: '#F5222D' }
      ]
    }, async (err, data) => {
      if (data.index === 1) {
        const success = await this.viewModel.deleteSelected();
        if (success) {
          promptAction.showToast({ message: '删除成功' });
        } else {
          promptAction.showToast({ message: '删除失败' });
        }
      }
    });
  }
}
