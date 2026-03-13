import { HomeViewModel } from '../viewmodels/HomeViewModel';
import { Post } from '../models/Post';
import router from '@ohos.router';
import promptAction from '@ohos.promptAction';

@Entry
@Component
struct HomePage {
  @State viewModel: HomeViewModel = new HomeViewModel();
  @State posts: Post[] = [];
  @State isLoading: boolean = false;
  @State hasMore: boolean = true;

  aboutToAppear() {
    this.viewModel.onDataChange(() => {
      this.posts = this.viewModel.getPosts();
      this.isLoading = this.viewModel.isLoading();
      this.hasMore = this.viewModel.hasMorePosts();
    });
    this.viewModel.loadPosts();
  }

  build() {
    Column() {
      // 顶部导航
      Row() {
        Text('社区')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .layoutWeight(1)

        Button('发布')
          .fontSize(14)
          .backgroundColor('#1890FF')
          .fontColor(Color.White)
          .borderRadius(20)
          .padding({ left: 16, right: 16, top: 8, bottom: 8 })
          .onClick(() => {
            this.navigateToPostCreate();
          })
      }
      .width('100%')
      .padding(16)
      .backgroundColor(Color.White)
    }

      // 内容区域
      if (this.isLoading && this.posts.length === 0) {
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
      } else if (this.posts.length === 0) {
        Column() {
          Text('📸')
            .fontSize(64)
            .margin({ bottom: 16 })
          Text('还没有动态')
            .fontSize(16)
            .fontColor('#666')
          Text('发布第一条作品开始分享吧')
            .fontSize(14)
            .fontColor('#999')
            .margin({ top: 8 })
          Button('发布作品')
            .fontSize(14)
            .backgroundColor('#1890FF')
            .fontColor(Color.White)
            .borderRadius(20)
            .padding({ left: 24, right: 24, top: 12, bottom: 12 })
            .margin({ top: 24 })
            .onClick(() => {
              this.navigateToPostCreate();
            })
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
      } else {
        List() {
          ForEach(this.posts, (post: Post) => {
            ListItem() {
              this.PostCard(post)
            }
          })
        }
        .width('100%')
        .layoutWeight(1)
        .padding(12)
      }

      // 加载更多指示器
      if (this.hasMore && this.posts.length > 0) {
        Row() {
          LoadingProgress()
            .width(20)
            .height(20)
          Text('加载更多...')
            .fontSize(14)
            .fontColor('#999')
            .margin({ left: 8 })
        }
        .width('100%')
        .padding(16)
        .backgroundColor('#F5F5F5')
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
    .onScrollIndex((start, end) => {
      // 滚动到底部加载更多
      if (end === this.posts.length - 1 && this.hasMore && !this.isLoading) {
        this.viewModel.loadMorePosts();
      }
    })
  }

  @Builder
  PostCard(post: Post) {
    Column() {
      // 用户信息
      Row() {
        Image(post.user.avatar || '')
          .width(40)
          .height(40)
          .borderRadius(20)
          .objectFit(ImageFit.Cover)

        Column() {
          Text(post.user.nickname)
            .fontSize(16)
            .fontWeight(FontWeight.Medium)

          Text(post.createdAt)
            .fontSize(12)
            .fontColor('#999')
            .margin({ top: 2 })
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)
        .margin({ left: 12 })

        // 更多按钮
        Text('⋮')
          .fontSize(16)
          .fontColor('#999')
          .onClick(() => {
            this.showPostMenu(post);
          })
      }
      .width('100%')
      .padding(16)
      .backgroundColor(Color.White)
      .borderRadius({ topLeft: 12, topRight: 12 })

      // 内容
      if (post.content) {
        Text(post.content)
          .fontSize(15)
          .fontColor('#333')
          .lineHeight(22)
          .width('100%')
          .padding({ left: 16, right: 16, top: 12, bottom: 12 })
      }

      // 照片
      if (post.photos && post.photos.length > 0) {
        this.PhotoGrid(post.photos)
      }

      // 操作栏
      Row() {
        Row() {
          Text('♥')
            .fontSize(16)
            .fontColor(post.isLiked ? '#F5222D' : '#999')
            .margin({ right: 4 })

          Text(`${post.likeCount}`)
            .fontSize(14)
            .fontColor(post.isLiked ? '#F5222D' : '#666')
        }
        .layoutWeight(1)
        .onClick(() => {
          this.viewModel.likePost(post);
        })

        Row() {
          Text('💬')
            .fontSize(16)
            .fontColor('#999')
            .margin({ right: 4 })

          Text(`${post.commentCount}`)
            .fontSize(14)
            .fontColor('#666')
        }
        .onClick(() => {
          this.navigateToPostDetail(post.id);
        })

        Row() {
          Text('☆')
            .fontSize(16)
            .fontColor(post.isCollected ? '#FAAD14' : '#999')
            .margin({ right: 4 })

          Text(post.isCollected ? '已收藏' : '收藏')
            .fontSize(14)
            .fontColor(post.isCollected ? '#FAAD14' : '#666')
        }
        .onClick(() => {
          this.viewModel.collectPost(post);
        })
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 12, bottom: 12 })
      .justifyContent(FlexAlign.SpaceAround)
      .backgroundColor(Color.White)
      .borderRadius({ bottomLeft: 12, bottomRight: 12 })
    }
    .width('100%')
    .backgroundColor(Color.White)
    .borderRadius(12)
    .margin({ bottom: 12 })
    .onClick(() => {
      this.navigateToPostDetail(post.id);
    })
  }

  @Builder
  PhotoGrid(photos: any[]) {
    Column() {
      Grid() {
        ForEach(photos, (photo: any) => {
          GridItem() {
            Image(photo.url || photo.originalPath)
              .width('100%')
              .aspectRatio(1)
              .borderRadius(8)
              .objectFit(ImageFit.Cover)
          }
        })
      }
      .columnsTemplate(photos.length === 1 ? '1fr' : photos.length === 2 ? '1fr 1fr' : '1fr 1fr 1fr')
      .rowsGap(4)
      .columnsGap(4)
      .width('100%')
    }
    .padding({ left: 16, right: 16, top: 8, bottom: 8 })
    .width('100%')
  }

  navigateToPostDetail(postId: string): void {
    router.pushUrl({
      url: 'pages/PostDetailPage',
      params: { postId: postId }
    });
  }

  navigateToPostCreate(): void {
    router.pushUrl({
      url: 'pages/PostCreatePage'
    });
  }

  showPostMenu(post: Post): void {
    promptAction.showDialog({
      title: '更多操作',
      buttons: [
        { text: '取消', color: '#999' },
        { text: '分享', color: '#333' },
        { text: '举报', color: '#F5222D' }
      ]
    }, (err, data) => {
      if (data.index === 1) {
        // 分享功能
        promptAction.showToast({ message: '分享功能即将推出' });
      } else if (data.index === 2) {
        // 举报功能
        promptAction.showToast({ message: '举报功能即将推出' });
      }
    });
  }
}
