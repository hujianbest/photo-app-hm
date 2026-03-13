import { PostDetailViewModel } from '../viewmodels/PostDetailViewModel';
import { Post } from '../models/Post';
import { Comment } from '../models/Comment';
import router from '@ohos.router';
import promptAction from '@ohos.promptAction';

@Entry
@Component
struct PostDetailPage {
  @State viewModel: PostDetailViewModel = new PostDetailViewModel();
  @State post: Post | null = null;
  @State comments: Comment[] = [];
  @State isLoading: boolean = false;
  @State isLoadingComments: boolean = false;
  @State showCommentDialog: boolean = false;
  @State commentText: string = '';

  aboutToAppear() {
    const postId = router.getParams()?.['postId'] as string;
    if (postId) {
      this.viewModel.onDataChange(() => {
        this.post = this.viewModel.getPost();
        this.comments = this.viewModel.getComments();
        this.isLoading = this.viewModel.isLoading();
        this.isLoadingComments = this.viewModel.isLoadingComments();
      });
      this.viewModel.loadPost(postId);
      this.viewModel.loadComments();
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

        Text('帖子详情')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .layoutWeight(1)

        if (this.post) {
          Row() {
            Text('♥')
              .fontSize(16)
              .fontColor(this.post.isLiked ? '#F5222D' : '#999')
              .margin({ right: 8 })

            Text('☆')
              .fontSize(16)
              .fontColor(this.post.isCollected ? '#FAAD14' : '#999')
          }
        }
      }
      .width('100%')
      .padding(16)
      .backgroundColor(Color.White)

      // 内容区域
      Scroll() {
        Column() {
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
            .height(300)
            .justifyContent(FlexAlign.Center)
          } else if (this.post) {
            this.PostDetail(this.post)

            Divider()
              .color('#E8E8E8')

            // 评论区
            Column() {
              Text(`评论 (${this.post.commentCount})`)
                .fontSize(16)
                .fontWeight(FontWeight.Medium)
                .margin({ bottom: 16 })

              if (this.comments.length === 0) {
                Text('还没有评论，快来抢沙发吧')
                  .fontSize(14)
                  .fontColor('#999')
                  .width('100%')
                  .textAlign(TextAlign.Center)
                  .padding(40)
              } else {
                List() {
                  ForEach(this.comments, (comment: Comment) => {
                    ListItem() {
                      this.CommentItem(comment)
                    }
                  })
                }
                .width('100%')
              }

              // 加载更多
              if (this.viewModel.hasMore() && !this.isLoadingComments) {
                Row() {
                  LoadingProgress()
                    .width(16)
                    .height(16)
                  Text('加载更多...')
                    .fontSize(14)
                    .fontColor('#999')
                    .margin({ left: 8 })
                }
                .width('100%')
                .justifyContent(FlexAlign.Center)
                .padding(16)
              }
            }
            .width('100%')
            .padding(16)
          }
        }
        .width('100%')
      }
      .layoutWeight(1)

      // 底部输入框
      Row() {
        TextInput({ placeholder: '写评论...', text: this.commentText })
          .layoutWeight(1)
          .height(44)
          .backgroundColor('#F5F5F5')
          .borderRadius(22)
          .padding({ left: 16, right: 16 })
          .onChange((value: string) => {
            this.commentText = value;
          })

        Button('发送')
          .fontSize(16)
          .backgroundColor('#1890FF')
          .fontColor(Color.White)
          .width(80)
          .height(44)
          .borderRadius(22)
          .onClick(() => {
            this.submitComment();
          })
      }
      .width('100%')
      .padding(16)
      .backgroundColor(Color.White)
      .border({ width: { top: 1 }, color: '#E8E8E8' })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }

  @Builder
  PostDetail(post: Post) {
    Column() {
      // 用户信息
      Row() {
        Image(post.user.avatar || '')
          .width(50)
          .height(50)
          .borderRadius(25)
          .objectFit(ImageFit.Cover)

        Column() {
          Row() {
            Text(post.user.nickname)
              .fontSize(16)
              .fontWeight(FontWeight.Medium)

            if (post.user.isVerified) {
              Text('✓')
                .fontSize(14)
                .fontColor('#1890FF')
                .margin({ left: 4 })
            }
          }

          Text(post.createdAt)
            .fontSize(14)
            .fontColor('#999')
            .margin({ top: 4 })
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)
        .margin({ left: 12 })
      }
      .width('100%')
      .padding(16)
      .backgroundColor(Color.White)
      .borderRadius(12)

      // 内容
      if (post.content) {
        Text(post.content)
          .fontSize(16)
          .fontColor('#333')
          .lineHeight(26)
          .width('100%')
          .padding(16)
          .backgroundColor(Color.White)
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
            .fontColor(this.post.isLiked ? '#F5222D' : '#999')
            .margin({ right: 4 })

          Text(`${post.likeCount}`)
            .fontSize(14)
            .fontColor(this.post.isLiked ? '#F5222D' : '#666')
        }
        .layoutWeight(1)
        .onClick(() => {
          this.viewModel.likePost();
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
          // 滚动到评论区
        })

        Row() {
          Text('☆')
            .fontSize(16)
            .fontColor(this.post.isCollected ? '#FAAD14' : '#999')
            .margin({ right: 4 })

          Text(this.post.isCollected ? '已收藏' : '收藏')
            .fontSize(14)
            .fontColor(this.post.isCollected ? '#FAAD14' : '#666')
        }
        .onClick(() => {
          this.viewModel.collectPost();
        })
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 12, bottom: 12 })
      .justifyContent(FlexAlign.SpaceAround)
      .backgroundColor(Color.White)
      .borderRadius({ bottomLeft: 12, bottomRight: 12 })
    }
    .width('100%')
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

  @Builder
  CommentItem(comment: Comment) {
    Row() {
      Image(comment.user.avatar || '')
        .width(36)
        .height(36)
        .borderRadius(18)
        .objectFit(ImageFit.Cover)

      Column() {
        Text(comment.user.nickname)
          .fontSize(14)
          .fontWeight(FontWeight.Medium)

        Text(comment.content)
          .fontSize(14)
          .fontColor('#333')
          .margin({ top: 4 })

        Row() {
          Text(comment.createdAt)
            .fontSize(12)
            .fontColor('#999')

          if (comment.likeCount > 0) {
            Text(` · ${comment.likeCount} 赞`)
              .fontSize(12)
              .fontColor('#999')
          }
        }
        .margin({ top: 4 })
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)
      .margin({ left: 12 })
    }
    .width('100%')
    .padding(12)
    .backgroundColor('#F9F9F9')
    .borderRadius(8)
    .margin({ bottom: 12 })
  }

  submitComment(): void {
    if (!this.commentText.trim()) {
      promptAction.showToast({ message: '请输入评论内容' });
      return;
    }

    // TODO: 实现评论提交逻辑
    promptAction.showToast({ message: '评论功能即将完善' });
    this.commentText = '';
  }
}
