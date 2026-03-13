import router from '@ohos.router';
import { MineViewModel } from '../viewmodels/MineViewModel';
import { User } from '../models/User';
import { Toast } from '../common/utils/Toast';

@Entry
@Component
struct MinePage {
  @State viewModel: MineViewModel = new MineViewModel();
  @State user: User | null = null;

  async aboutToAppear() {
    await this.viewModel.loadUserInfo();
    this.user = this.viewModel.user;
  }

  navigateToNotifications() {
    router.pushUrl({
      url: 'pages/NotificationListPage'
    });
  }

  async handleLogout() {
    await this.viewModel.logout();
    Toast.showShort('已退出登录');
    router.replaceUrl({
      url: 'pages/LoginPage'
    });
  }

  build() {
    Column() {
      Column() {
        Row() {
          Image(this.user?.avatar || $r('app.media.default_avatar'))
            .width(70)
            .height(70)
            .borderRadius(35)

          Column({ space: 8 }) {
            Text(this.user?.nickname || '未设置昵称')
              .fontSize(18)
              .fontWeight(FontWeight.Bold)
              .fontColor('#FFFFFF')

            Text(this.user?.bio || '这个人很懒，什么都没写~')
              .fontSize(12)
              .fontColor('#FFFFFF')
              .opacity(0.8)
          }
          .alignItems(HorizontalAlign.Start)
          .layoutWeight(1)
          .margin({ left: 15 })

          Image($r('sys.media.ohos_ic_public_arrow_right'))
            .width(20)
            .height(20)
            .fillColor('#FFFFFF')
        }
        .width('100%')
        .padding({ left: 20, right: 20 })

        Row({ space: 30 }) {
          this.StatItem('作品', this.user?.worksCount || 0)
          this.StatItem('关注', this.user?.followingCount || 0)
          this.StatItem('粉丝', this.user?.followersCount || 0)
          this.StatItem('评分', this.user?.rating || 0)
          this.StatItem('通知', 0, true)
        }
        .width('100%')
        .justifyContent(FlexAlign.Center)
        .margin({ top: 25 })
      }
      .width('100%')
      .padding({ top: 30, bottom: 30 })
      .linearGradient({
        angle: 135,
        colors: [['#007DFF', 0], ['#00C4FF', 1]]
      })

      Column({ space: 10 }) {
        this.MenuItem($r('app.media.profile'), '个人资料', () => {
          // TODO: Navigate to profile edit page
        })

        this.MenuItem($r('app.media.album'), '我的相册', () => {
          // TODO: Navigate to album page
        })

        this.MenuItem($r('app.media.booking'), '约拍记录', () => {
          // TODO: Navigate to booking history page
        })

        this.MenuItem($r('app.media.favorite'), '我的收藏', () => {
          // TODO: Navigate to favorites page
        })

        this.MenuItem($r('app.media.settings'), '设置', () => {
          // TODO: Navigate to settings page
        })

        Button('退出登录')
          .width('100%')
          .height(50)
          .fontSize(16)
          .backgroundColor('#FFFFFF')
          .fontColor('#FF0000')
          .borderRadius(10)
          .onClick(() => {
            this.handleLogout();
          })
          .margin({ top: 20 })
      }
      .width('90%')
      .margin({ left: '5%', right: '5%', top: 20 })
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }

  @Builder
  StatItem(label: string, count: number) {
    Column() {
      Text(count.toString())
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .fontColor('#FFFFFF')

      Text(label)
        .fontSize(12)
        .fontColor('#FFFFFF')
        .opacity(0.8)
        .margin({ top: 5 })
    }
    .width('100%')
    .height('100%')
    .backgroundColor(label === '通知' ? '#1890FF' : '#007DFF')
    .borderRadius(10)
    .onClick(() => {
      if (label === '通知') {
        this.navigateToNotifications();
      }
    })
  }

  @Builder
  MenuItem(icon: Resource, title: string, action: () => void) {
    Row() {
      Image(icon)
        .width(24)
        .height(24)

      Text(title)
        .fontSize(16)
        .fontColor('#333333')
        .margin({ left: 15 })
        .layoutWeight(1)

      Image($r('sys.media.ohos_ic_public_arrow_right'))
        .width(20)
        .height(20)
        .fillColor('#999999')
    }
    .width('100%')
    .height(55)
    .padding({ left: 15, right: 15 })
    .backgroundColor('#FFFFFF')
    .borderRadius(10)
    .onClick(action)
  }
}
