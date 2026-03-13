import router from '@ohos.router';
import { AuthService } from '../services/AuthService';
import { Logger } from '../common/utils/Logger';

@Entry
@Component
struct SplashPage {
  async aboutToAppear() {
    await this.checkAuthAndNavigate();
  }

  async checkAuthAndNavigate() {
    try {
      const isLoggedIn = await AuthService.isLoggedIn();
      
      setTimeout(async () => {
        if (isLoggedIn) {
          router.replaceUrl({
            url: 'pages/MainPage'
          });
        } else {
          router.replaceUrl({
            url: 'pages/LoginPage'
          });
        }
      }, 1500);
    } catch (error) {
      Logger.error('SplashPage', 'Auth check failed: %{public}s', JSON.stringify(error));
      router.replaceUrl({
        url: 'pages/LoginPage'
      });
    }
  }

  build() {
    Column() {
      Column() {
        Image($r('app.media.logo'))
          .width(120)
          .height(120)
          .margin({ bottom: 20 })
        
        Text('摄影圈')
          .fontSize(32)
          .fontWeight(FontWeight.Bold)
          .fontColor('#333333')
        
        Text('记录美好瞬间')
          .fontSize(14)
          .fontColor('#999999')
          .margin({ top: 10 })
      }
      .justifyContent(FlexAlign.Center)
      .width('100%')
      .height('100%')
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#FFFFFF')
    .justifyContent(FlexAlign.Center)
  }
}
