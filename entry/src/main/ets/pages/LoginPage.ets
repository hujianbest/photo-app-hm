import router from '@ohos.router';
import { LoginViewModel } from '../viewmodels/LoginViewModel';

@Entry
@Component
struct LoginPage {
  @State viewModel: LoginViewModel = new LoginViewModel();
  @State phone: string = '';
  @State password: string = '';
  @State isLoading: boolean = false;

  async handleLogin() {
    this.viewModel.phone = this.phone;
    this.viewModel.password = this.password;
    
    const success = await this.viewModel.login();
    
    if (success) {
      router.replaceUrl({
        url: 'pages/MainPage'
      });
    }
  }

  handleRegister() {
    router.pushUrl({
      url: 'pages/RegisterPage'
    });
  }

  build() {
    Column() {
      Column() {
        Text('摄影圈')
          .fontSize(32)
          .fontWeight(FontWeight.Bold)
          .fontColor('#333333')
          .margin({ bottom: 40 })
      }
      .width('100%')
      .padding({ top: 80 })

      Column({ space: 20 }) {
        TextInput({ placeholder: '请输入手机号' })
          .width('100%')
          .height(50)
          .type(InputType.PhoneNumber)
          .maxLength(11)
          .onChange((value) => {
            this.phone = value;
          })

        TextInput({ placeholder: '请输入密码' })
          .width('100%')
          .height(50)
          .type(InputType.Password)
          .onChange((value) => {
            this.password = value;
          })

        Button(this.isLoading ? '登录中...' : '登录')
          .width('100%')
          .height(50)
          .fontSize(16)
          .enabled(!this.isLoading)
          .onClick(() => {
            this.isLoading = true;
            this.handleLogin().finally(() => {
              this.isLoading = false;
            });
          })
      }
      .width('85%')
      .margin({ top: 40 })

      Row() {
        Text('还没有账号？')
          .fontSize(14)
          .fontColor('#999999')
        
        Text('立即注册')
          .fontSize(14)
          .fontColor('#007DFF')
          .onClick(() => {
            this.handleRegister();
          })
      }
      .margin({ top: 20 })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#FFFFFF')
  }
}
