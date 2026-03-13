import { NotificationListViewModel } from '../viewmodels/NotificationListViewModel';
import { NotificationItem } from '../models/Notification';
import router from '@ohos.router';
import promptAction from '@ohos.promptAction';

@Entry
@Component
struct NotificationListPage {
  @State viewModel: NotificationListViewModel = new NotificationListViewModel();
  @State notifications: NotificationItem[] = [];
  @State unreadCount: number = 0;
  @State isLoading: boolean = false;

  aboutToAppear() {
    this.viewModel.onDataChange(() => {
      this.notifications = this.viewModel.getNotifications();
      this.unreadCount = this.viewModel.getUnreadCount();
      this.isLoading = this.viewModel.isLoading();
    });
    this.viewModel.loadNotifications();
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

        Text('消息通知')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .layoutWeight(1)

        if (this.unreadCount > 0) {
          Text(`${this.unreadCount}`)
            .fontSize(14)
            .fontColor(Color.White)
            .backgroundColor('#F5222D')
            .borderRadius(10)
            .padding({ left: 8, right: 8, top: 4, bottom: 4 })
        }
      }
      .width('100%')
      .padding(16)
      .backgroundColor(Color.White)
      .border({ width: { bottom: 1 }, color: '#E8E8E8' })
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
    } else if (this.notifications.length === 0) {
      Column() {
        Text('🔔')
          .fontSize(64)
          .margin({ bottom: 16 })
        Text('还没有消息')
          .fontSize(16)
          .fontColor('#666')
      }
      .width('100%')
      .layoutWeight(1)
      .justifyContent(FlexAlign.Center)
    } else {
      List() {
        ForEach(this.notifications, (notification: NotificationItem) => {
          ListItem() {
            this.NotificationItem(notification)
          }
        })
      }
      .width('100%')
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }

  @Builder
  NotificationItem(notification: NotificationItem) {
    Row() {
      // 图标
      Circle()
        .width(40)
        .height(40)
        .fill(notification.isRead ? '#E8E8E8' : '#1890FF')
        .margin({ right: 12 })
        .onClick(() => {
          this.viewModel.markAsRead(notification);
        })

      Column() {
        Text(this.getNotificationTitle(notification.type))
          .fontSize(15)
          .fontWeight(FontWeight.Medium)

        Text(notification.content)
          .fontSize(14)
          .fontColor('#666')
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .margin({ top: 4 })

        Text(notification.createdAt)
          .fontSize(12)
          .fontColor('#999')
          .margin({ top: 4 })
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)

      // 删除按钮
      Image($r('app.media.ic_delete'))
        .width(20)
        .height(20)
        .fillColor('#999')
        .onClick(() => {
          this.showDeleteMenu(notification);
        })
    }
    .width('100%')
    .padding(16)
    .backgroundColor(notification.isRead ? Color.White : '#F0F8FF')
    .margin({ bottom: 1 })
    .onClick(() => {
      this.handleNotificationClick(notification);
    })
  }

  getNotificationTitle(type: string): string {
    switch (type) {
      case 'like':
        return '点赞通知';
      case 'comment':
        return '评论通知';
      case 'follow':
        return '关注通知';
      case 'mention':
        return '提及通知';
      default:
        return '通知';
    }
  }

  handleNotificationClick(notification: NotificationItem): void {
    this.viewModel.markAsRead(notification);

    // 根据通知类型跳转
    if (notification.targetType === 'post' && notification.targetId) {
      router.pushUrl({
        url: 'pages/PostDetailPage',
        params: { postId: notification.targetId }
      });
    }
  }

  showDeleteMenu(notification: NotificationItem): void {
    promptAction.showDialog({
      title: '删除通知',
      message: '确定要删除这条通知吗？',
      buttons: [
        { text: '取消', color: '#999' },
        { text: '删除', color: '#F5222D' }
      ]
    }, async (err, data) => {
      if (data.index === 1) {
        await this.viewModel.deleteNotification(notification);
      }
    });
  }
}
