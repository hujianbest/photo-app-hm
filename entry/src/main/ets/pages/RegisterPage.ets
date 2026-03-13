import router from '@ohos.router';
import { RegisterViewModel } from '../viewmodels/RegisterViewModel';
import { UserRole } from '../common/constants/Constants';

@Entry
@Component
struct RegisterPage {
  @State viewModel: RegisterViewModel = new RegisterViewModel();
  @State phone: string = '';
  @State password: string = '';
  @State confirmPassword: string = '';
  @State nickname: string = '';
  @State selectedRole: number = 0;
  @State isLoading: boolean = false;

  async handleRegister() {
    this.viewModel.phone = this.phone;
    this.viewModel.password = this.password;
    this.viewModel.confirmPassword = this.confirmPassword;
    this.viewModel.nickname = this.nickname;
    this.viewModel.role = this.selectedRole === 0 ? UserRole.PHOTOGRAPHER : UserRole.MODEL;

    const success = await this.viewModel.register();

    if (success) {
      router.replaceUrl({
        url: 'pages/MainPage'
      });
    }
  }

  build() {
    Column() {
      Row() {
        Image($r('sys.media.ohos_ic_public_arrow_left'))
          .width(24)
          .height(24)
          .onClick(() => {
            router.back();
          })
        
        Text('注册')
          .fontSize(18)
          .fontWeight(FontWeight.Medium)
          .layoutWeight(1)
          .textAlign(TextAlign.Center)
        
        Blank()
          .width(24)
      }
      .width('100%')
      .height(56)
      .padding({ left: 16, right: 16 })

      Scroll() {
        Column({ space: 20 }) {
          Column({ space: 10 }) {
            Text('选择身份')
              .fontSize(14)
              .fontColor('#666666')
              .width('100%')

            Row({ space: 20 }) {
              Column() {
                Image(this.selectedRole === 0 ? $r('app.media.photographer_selected') : $r('app.media.photographer'))
                  .width(60)
                  .height(60)
                
                Text('摄影师')
                  .fontSize(14)
                  .fontColor(this.selectedRole === 0 ? '#007DFF' : '#333333')
                  .margin({ top: 8 })
              }
              .layoutWeight(1)
              .padding(15)
              .borderRadius(10)
              .backgroundColor(this.selectedRole === 0 ? '#E8F4FF' : '#F5F5F5')
              .onClick(() => {
                this.selectedRole = 0;
              })

              Column() {
                Image(this.selectedRole === 1 ? $r('app.media.model_selected') : $r('app.media.model'))
                  .width(60)
                  .height(60)
                
                Text('模特')
                  .fontSize(14)
                  .fontColor(this.selectedRole === 1 ? '#007DFF' : '#333333')
                  .margin({ top: 8 })
              }
              .layoutWeight(1)
              .padding(15)
              .borderRadius(10)
              .backgroundColor(this.selectedRole === 1 ? '#E8F4FF' : '#F5F5F5')
              .onClick(() => {
                this.selectedRole = 1;
              })
            }
            .width('100%')
          }
          .width('100%')
          .margin({ top: 20 })

          TextInput({ placeholder: '请输入手机号' })
            .width('100%')
            .height(50)
            .type(InputType.PhoneNumber)
            .maxLength(11)
            .onChange((value) => {
              this.phone = value;
            })

          TextInput({ placeholder: '请输入密码（至少6位）' })
            .width('100%')
            .height(50)
            .type(InputType.Password)
            .onChange((value) => {
              this.password = value;
            })

          TextInput({ placeholder: '请确认密码' })
            .width('100%')
            .height(50)
            .type(InputType.Password)
            .onChange((value) => {
              this.confirmPassword = value;
            })

          TextInput({ placeholder: '请输入昵称' })
            .width('100%')
            .height(50)
            .maxLength(20)
            .onChange((value) => {
              this.nickname = value;
            })

          Button(this.isLoading ? '注册中...' : '注册')
            .width('100%')
            .height(50)
            .fontSize(16)
            .enabled(!this.isLoading)
            .onClick(() => {
              this.isLoading = true;
              this.handleRegister().finally(() => {
                this.isLoading = false;
              });
            })
            .margin({ top: 20 })

          Row() {
            Text('注册即表示同意')
              .fontSize(12)
              .fontColor('#999999')
            
            Text('《用户协议》')
              .fontSize(12)
              .fontColor('#007DFF')
            
            Text('和')
              .fontSize(12)
              .fontColor('#999999')
            
            Text('《隐私政策》')
              .fontSize(12)
              .fontColor('#007DFF')
          }
          .margin({ top: 15 })
        }
        .width('85%')
        .margin({ left: '7.5%', right: '7.5%' })
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#FFFFFF')
  }
}
