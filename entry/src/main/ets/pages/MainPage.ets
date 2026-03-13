import { AuthService } from '../services/AuthService';
import router from '@ohos.router';

@Entry
@Component
struct MainPage {
  @State currentIndex: number = 0;

  private tabsController: TabsController = new TabsController();

  build() {
    Column() {
      Tabs({
        barPosition: BarPosition.End,
        controller: this.tabsController
      }) {
        TabContent() {
          HomePage()
        }
        .tabBar(this.TabBuilder(0, '首页', $r('app.media.home'), $r('app.media.home_selected')))

        TabContent() {
          PhotoPage()
        }
        .tabBar(this.TabBuilder(1, '照片', $r('app.media.photo'), $r('app.media.photo_selected')))

        TabContent() {
          BookingPage()
        }
        .tabBar(this.TabBuilder(2, '约拍', $r('app.media.booking'), $r('app.media.booking_selected')))

        TabContent() {
          LearnPage()
        }
        .tabBar(this.TabBuilder(3, '学习', $r('app.media.learn'), $r('app.media.learn_selected')))

        TabContent() {
          MinePage()
        }
        .tabBar(this.TabBuilder(4, '我的', $r('app.media.mine'), $r('app.media.mine_selected')))
      }
      .barHeight(56)
      .barBackgroundColor('#FFFFFF')
      .onChange((index: number) => {
        this.currentIndex = index;
      })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }

  @Builder
  TabBuilder(index: number, title: string, normalIcon: Resource, selectedIcon: Resource) {
    Column() {
      Image(this.currentIndex === index ? selectedIcon : normalIcon)
        .width(24)
        .height(24)

      Text(title)
        .fontSize(12)
        .fontColor(this.currentIndex === index ? '#007DFF' : '#999999')
        .margin({ top: 4 })
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
  }
}
