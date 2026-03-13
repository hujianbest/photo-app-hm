import { AlbumListViewModel } from '../viewmodels/AlbumListViewModel';
import { Album } from '../models/Album';
import router from '@ohos.router';
import promptAction from '@ohos.promptAction';

@Entry
@Component
struct AlbumListPage {
  @State viewModel: AlbumListViewModel = new AlbumListViewModel();
  @State albums: Album[] = [];
  @State isLoading: boolean = false;
  @State showDialog: boolean = false;
  @State albumName: string = '';
  @State albumDescription: string = '';
  @State viewMode: 'grid' | 'list' = 'grid';

  aboutToAppear() {
    this.viewModel.onAlbumsChange(() => {
      this.albums = this.viewModel.getAlbums();
      this.isLoading = this.viewModel.isLoading();
      this.viewMode = this.viewModel.getViewMode();
    });
    this.viewModel.loadAlbums();
  }

  build() {
    Column() {
      // 头部
      Row() {
        Text('我的相册')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .layoutWeight(1)

        // 视图模式切换
        Button(this.viewMode === 'grid' ? '📋' : '⊞')
          .fontSize(18)
          .backgroundColor(Color.Transparent)
          .fontColor('#333')
          .onClick(() => {
            this.viewModel.toggleViewMode();
          })

        Button('+')
          .fontSize(24)
          .width(40)
          .height(40)
          .borderRadius(20)
          .backgroundColor('#1890FF')
          .fontColor(Color.White)
          .margin({ left: 8 })
          .onClick(() => {
            this.showDialog = true;
          })
      }
      .width('100%')
      .padding(16)
      .backgroundColor(Color.White)

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
        .height('100%')
        .justifyContent(FlexAlign.Center)
      } else if (this.albums.length === 0) {
        Column() {
          Text('📁')
            .fontSize(64)
            .margin({ bottom: 16 })
          Text('还没有相册')
            .fontSize(16)
            .fontColor('#666')
          Button('创建第一个相册')
            .fontSize(14)
            .backgroundColor('#1890FF')
            .fontColor(Color.White)
            .borderRadius(20)
            .padding({ left: 24, right: 24, top: 12, bottom: 12 })
            .margin({ top: 24 })
            .onClick(() => {
              this.showDialog = true;
            })
        }
        .width('100%')
        .height('100%')
        .justifyContent(FlexAlign.Center)
      } else if (this.viewMode === 'grid') {
        this.GridView()
      } else {
        this.ListView()
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
    .bindSheet(this.showDialog, this.CreateAlbumDialog(), {
      height: 300,
      showClose: true,
      onDisappear: () => {
        this.albumName = '';
        this.albumDescription = '';
      }
    })
  }

  @Builder
  GridView() {
    Grid() {
      ForEach(this.albums, (album: Album) => {
        GridItem() {
          Column() {
            // 相册封面占位
            Image(album.coverPhotoPath || '')
              .width('100%')
              .aspectRatio(1)
              .backgroundColor('#E0E0E0')
              .borderRadius(8)
              .objectFit(ImageFit.Cover)

            Text(album.name)
              .fontSize(14)
              .fontWeight(FontWeight.Medium)
              .maxLines(1)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
              .width('100%')
              .margin({ top: 8 })

            Text(`${album.photoCount} 张照片`)
              .fontSize(12)
              .fontColor('#999')
              .margin({ top: 4 })
          }
          .width('100%')
          .padding(8)
          .backgroundColor(Color.White)
          .borderRadius(12)
          .onClick(() => {
            router.pushUrl({
              url: 'pages/AlbumDetailPage',
              params: { albumId: album.id }
            });
          })
          .onLongPress(() => {
            this.showAlbumMenu(album);
          })
        }
      })
    }
    .columnsTemplate('1fr 1fr')
    .rowsGap(12)
    .columnsGap(12)
    .padding(12)
    .height('100%')
  }

  @Builder
  ListView() {
    List() {
      ForEach(this.albums, (album: Album) => {
        ListItem() {
          Row() {
            // 相册封面占位
            Image(album.coverPhotoPath || '')
              .width(80)
              .height(80)
              .backgroundColor('#E0E0E0')
              .borderRadius(8)
              .objectFit(ImageFit.Cover)

            Column() {
              Text(album.name)
                .fontSize(16)
                .fontWeight(FontWeight.Medium)
                .maxLines(1)
                .textOverflow({ overflow: TextOverflow.Ellipsis })

              Text(album.description || '暂无描述')
                .fontSize(12)
                .fontColor('#999')
                .maxLines(1)
                .textOverflow({ overflow: TextOverflow.Ellipsis })
                .margin({ top: 4 })

              Text(`${album.photoCount} 张照片`)
                .fontSize(12)
                .fontColor('#1890FF')
                .margin({ top: 4 })
            }
            .alignItems(HorizontalAlign.Start)
            .layoutWeight(1)
            .margin({ left: 12 })

            Text('>')
              .fontSize(16)
              .fontColor('#CCC')
          }
          .width('100%')
          .padding(16)
          .backgroundColor(Color.White)
          .borderRadius(8)
          .onClick(() => {
            router.pushUrl({
              url: 'pages/AlbumDetailPage',
              params: { albumId: album.id }
            });
          })
          .onLongPress(() => {
            this.showAlbumMenu(album);
          })
        }
        .width('100%')
      })
    }
    .width('100%')
    .padding(12)
    .height('100%')
  }

  @Builder
  CreateAlbumDialog() {
    Column() {
      Text('创建相册')
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
            this.showDialog = false;
          })

        Button('创建')
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

            const album = await this.viewModel.createAlbum(this.albumName, this.albumDescription);
            if (album) {
              promptAction.showToast({ message: '相册创建成功' });
              this.showDialog = false;
            } else {
              promptAction.showToast({ message: '创建失败' });
            }
          })
      }
      .width('100%')
    }
    .width('100%')
    .padding(24)
  }

  showAlbumMenu(album: Album): void {
    promptAction.showDialog({
      title: album.name,
      buttons: [
        { text: '取消', color: '#999' },
        { text: '删除', color: '#F5222D' }
      ]
    }, (err, data) => {
      if (data.index === 1) {
        this.deleteAlbum(album);
      }
    });
  }

  async deleteAlbum(album: Album): Promise<void> {
    promptAction.showDialog({
      title: '确认删除',
      message: `删除相册"${album.name}"及其所有照片？`,
      buttons: [
        { text: '取消', color: '#999' },
        { text: '删除', color: '#F5222D' }
      ]
    }, async (err, data) => {
      if (data.index === 1) {
        const success = await this.viewModel.deleteAlbum(album.id);
        if (success) {
          promptAction.showToast({ message: '删除成功' });
        } else {
          promptAction.showToast({ message: '删除失败' });
        }
      }
    });
  }
}
