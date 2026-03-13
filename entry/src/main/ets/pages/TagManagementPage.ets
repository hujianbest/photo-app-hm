import { TagViewModel } from '../viewmodels/TagViewModel';
import { Tag } from '../models/Tag';
import router from '@ohos.router';
import promptAction from '@ohos.promptAction';

@Entry
@Component
struct TagManagementPage {
  @State viewModel: TagViewModel = new TagViewModel();
  @State tags: Tag[] = [];
  @State isLoading: boolean = false;
  @State selectedTag: string | null = null;
  @State showCreateDialog: boolean = false;
  @State newTagName: string = '';
  @State selectedColor: string = '#1890FF';

  private colors: string[] = [
    '#1890FF', '#52C41A', '#FAAD14', '#F5222D',
    '#722ED1', '#EB2F96', '#13C2C2', '#FA8C16'
  ];

  aboutToAppear() {
    this.viewModel.onDataChange(() => {
      this.tags = this.viewModel.getTags();
      this.isLoading = this.viewModel.isLoading();
      this.selectedTag = this.viewModel.getSelectedTag();
    });
    this.viewModel.loadTags();
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
            if (this.selectedTag) {
              this.viewModel.clearFilter();
            } else {
              router.back();
            }
          })

        Text(this.selectedTag || '标签管理')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .layoutWeight(1)

        Button('+')
          .fontSize(24)
          .backgroundColor(Color.Transparent)
          .fontColor('#333')
          .onClick(() => {
            this.showCreateDialog = true;
          })
      }
      .width('100%')
      .padding(16)
      .backgroundColor(Color.White)

      if (this.selectedTag) {
        // 返回标签列表按钮
        Button('返回标签列表')
          .fontSize(14)
          .backgroundColor('#F5F5F5')
          .fontColor('#333')
          .borderRadius(20)
          .padding({ left: 16, right: 16, top: 8, bottom: 8 })
          .margin(12)
          .onClick(() => {
            this.viewModel.clearFilter();
          })
      }

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
      } else if (this.tags.length === 0) {
        Column() {
          Text('🏷️')
            .fontSize(64)
            .margin({ bottom: 16 })
          Text('还没有标签')
            .fontSize(16)
            .fontColor('#666')
          Button('创建第一个标签')
            .fontSize(14)
            .backgroundColor('#1890FF')
            .fontColor(Color.White)
            .borderRadius(20)
            .padding({ left: 24, right: 24, top: 12, bottom: 12 })
            .margin({ top: 24 })
            .onClick(() => {
              this.showCreateDialog = true;
            })
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
      } else {
        this.TagList()
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
    .bindSheet(this.showCreateDialog, this.CreateTagDialog(), {
      height: 300,
      showClose: true,
      onDisappear: () => {
        this.newTagName = '';
        this.selectedColor = '#1890FF';
      }
    })
  }

  @Builder
  TagList() {
    List() {
      ForEach(this.tags, (tag: Tag) => {
        ListItem() {
          Row() {
            // 标签颜色指示器
            Circle()
              .width(16)
              .height(16)
              .fill(tag.color)
              .margin({ right: 12 })

            Column() {
              Text(tag.name)
                .fontSize(16)
                .fontWeight(FontWeight.Medium)

              Text(`${tag.photoCount} 张照片`)
                .fontSize(12)
                .fontColor('#999')
                .margin({ top: 4 })
            }
            .alignItems(HorizontalAlign.Start)
            .layoutWeight(1)

            Text('>')
              .fontSize(16)
              .fontColor('#CCC')
              .onClick(() => {
                this.viewModel.filterByTag(tag.name);
              })
          }
          .width('100%')
          .padding(16)
          .backgroundColor(Color.White)
          .borderRadius(8)
          .onClick(() => {
            this.viewModel.filterByTag(tag.name);
          })
          .onLongPress(() => {
            this.showTagMenu(tag);
          })
        }
        .width('100%')
      })
    }
    .width('100%')
    .layoutWeight(1)
    .padding(12)
  }

  @Builder
  CreateTagDialog() {
    Column() {
      Text('创建标签')
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .margin({ bottom: 24 })

      TextInput({ placeholder: '标签名称', text: this.newTagName })
        .width('100%')
        .height(44)
        .backgroundColor('#F5F5F5')
        .borderRadius(8)
        .padding({ left: 16, right: 16 })
        .margin({ bottom: 16 })
        .onChange((value: string) => {
          this.newTagName = value;
        })

      Text('选择颜色')
        .fontSize(14)
        .fontColor('#666')
        .width('100%')

      Grid() {
        ForEach(this.colors, (color: string) => {
          GridItem() {
            Circle()
              .width(36)
              .height(36)
              .fill(color)
              .onClick(() => {
                this.selectedColor = color;
              })
          }
        })
      }
      .columnsTemplate('1fr 1fr 1fr 1fr')
      .rowsGap(12)
      .columnsGap(12)
      .width('100%')
      .margin({ top: 12, bottom: 24 })

      Button('创建')
        .fontSize(16)
        .backgroundColor('#1890FF')
        .fontColor(Color.White)
        .width('100%')
        .height(44)
        .borderRadius(22)
        .onClick(async () => {
          if (!this.newTagName.trim()) {
            promptAction.showToast({ message: '请输入标签名称' });
            return;
          }

          const tag = await this.viewModel.createTag(this.newTagName, this.selectedColor);
          if (tag) {
            promptAction.showToast({ message: '标签创建成功' });
            this.showCreateDialog = false;
          } else {
            promptAction.showToast({ message: '创建失败' });
          }
        })
    }
    .width('100%')
    .padding(24)
  }

  showTagMenu(tag: Tag): void {
    promptAction.showDialog({
      title: tag.name,
      buttons: [
        { text: '取消', color: '#999' },
        { text: '删除', color: '#F5222D' }
      ]
    }, (err, data) => {
      if (data.index === 1) {
        this.deleteTag(tag);
      }
    });
  }

  deleteTag(tag: Tag): void {
    promptAction.showDialog({
      title: '确认删除',
      message: `删除标签"${tag.name}"？`,
      buttons: [
        { text: '取消', color: '#999' },
        { text: '删除', color: '#F5222D' }
      ]
    }, async (err, data) => {
      if (data.index === 1) {
        const success = await this.viewModel.deleteTag(tag.id);
        if (success) {
          promptAction.showToast({ message: '删除成功' });
        } else {
          promptAction.showToast({ message: '删除失败' });
        }
      }
    });
  }
}
