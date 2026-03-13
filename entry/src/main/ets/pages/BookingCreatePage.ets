import router from '@ohos.router';
import promptAction from '@ohos.promptAction';
import { BookingService } from '../services/BookingService';
import { CreateBookingRequest } from '../models/Booking';

@Entry
@Component
struct BookingCreatePage {
  @State title: string = '';
  @State description: string = '';
  @State style: string = '';
  @State selectedDate: string = '';
  @State selectedTime: string = '';
  @State location: string = '';
  @State city: string = '';
  @State duration: string = '2';
  @State fee: string = '';
  @State isSubmitting: boolean = false;

  navigateBack() {
    router.back();
  }

  async submitBooking() {
    if (!this.title.trim() || !this.location.trim()) {
      promptAction.showToast({ message: '请填写必要信息' });
      return;
    }

    if (!this.style) {
      promptAction.showToast({ message: '请选择拍摄风格' });
      return;
    }

    if (!this.selectedDate || !this.selectedTime) {
      promptAction.showToast({ message: '请选择预约时间' });
      return;
    }

    this.isSubmitting = true;

    try {
      const request: CreateBookingRequest = {
        targetId: '',
        title: this.title.trim(),
        description: this.description.trim(),
        style: this.style,
        scheduledTime: `${this.selectedDate}T${this.selectedTime}:00`,
        location: {
          address: this.location.trim(),
          city: this.city.trim()
        },
        duration: parseInt(this.duration) || 2,
        fee: parseInt(this.fee) || 0
      };

      await BookingService.createBooking(request);
      promptAction.showToast({ message: '约拍请求已发送' });
      router.back();
    } catch (error) {
      promptAction.showToast({ message: '发布失败，请重试' });
    } finally {
      this.isSubmitting = false;
    }
  }

  build() {
    Column() {
      Row() {
        Button('<')
          .fontSize(20)
          .backgroundColor(Color.Transparent)
          .fontColor('#333')
          .onClick(() => {
            this.navigateBack();
          })

        Text('发布约拍')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .layoutWeight(1)

        Button('发布')
          .fontSize(16)
          .backgroundColor('#1890FF')
          .fontColor(Color.White)
          .borderRadius(15)
          .padding({ left: 16, right: 16, top: 8, bottom: 8 })
          .enabled(!this.isSubmitting)
          .onClick(() => {
            this.submitBooking();
          })
      }
      .width('100%')
      .padding(16)
      .backgroundColor(Color.White)
    }

    Column({ space: 20 }) {
      Column({ space: 8 }) {
        Text('标题 *').fontSize(14).fontColor('#333')
        TextInput({ placeholder: '请输入约拍标题', text: this.title })
          .width('100%')
          .height(50)
          .backgroundColor('#F5F5F5')
          .borderRadius(8)
          .onChange((value: string) => { this.title = value; })
      }
      .alignItems(HorizontalAlign.Start)

      Column({ space: 8 }) {
        Text('详细描述').fontSize(14).fontColor('#333')
        TextArea({ placeholder: '描述你的约拍需求...', text: this.description })
          .width('100%')
          .height(100)
          .backgroundColor('#F5F5F5')
          .borderRadius(8)
          .onChange((value: string) => { this.description = value; })
      }
      .alignItems(HorizontalAlign.Start)

      Column({ space: 8 }) {
        Text('拍摄风格 *').fontSize(14).fontColor('#333')
        Row({ space: 10 }) {
          this.StyleChip('人像', 'portrait')
          this.StyleChip('风光', 'landscape')
          this.StyleChip('街拍', 'street')
          this.StyleChip('婚纱', 'wedding')
          this.StyleChip('写真', 'artistic')
        }
        .width('100%')
      }
      .alignItems(HorizontalAlign.Start)

      Column({ space: 8 }) {
        Text('预约时间 *').fontSize(14).fontColor('#333')
        Row({ space: 10 }) {
          TextInput({ placeholder: '选择日期', text: this.selectedDate })
            .width('48%')
            .height(50)
            .backgroundColor('#F5F5F5')
            .borderRadius(8)
            .onClick(() => {
              promptAction.showToast({ message: '日期选择器即将实现' });
            })

          TextInput({ placeholder: '选择时间', text: this.selectedTime })
            .width('48%')
            .height(50)
            .backgroundColor('#F5F5F5')
            .borderRadius(8)
            .onClick(() => {
              promptAction.showToast({ message: '时间选择器即将实现' });
            })
        }
        .width('100%')
      }
      .alignItems(HorizontalAlign.Start)

      Column({ space: 8 }) {
        Text('拍摄地点 *').fontSize(14).fontColor('#333')
        TextInput({ placeholder: '请输入详细地址', text: this.location })
          .width('100%')
          .height(50)
          .backgroundColor('#F5F5F5')
          .borderRadius(8)
          .onChange((value: string) => { this.location = value; })
      }
      .alignItems(HorizontalAlign.Start)

      Row({ space: 10 }) {
        Column({ space: 8 }) {
          Text('城市 *').fontSize(14).fontColor('#333')
          TextInput({ placeholder: '城市', text: this.city })
            .width('100%')
            .height(50)
            .backgroundColor('#F5F5F5')
            .borderRadius(8)
            .onChange((value: string) => { this.city = value; })
        }
        .width('48%')

        Column({ space: 8 }) {
          Text('时长(小时)').fontSize(14).fontColor('#333')
          TextInput({ placeholder: '时长', text: this.duration })
            .width('100%')
            .height(50)
            .backgroundColor('#F5F5F5')
            .borderRadius(8)
            .type(InputType.Number)
            .onChange((value: string) => { this.duration = value; })
        }
        .width('48%')
      }
      .width('100%')

      Column({ space: 8 }) {
        Text('费用(元)').fontSize(14).fontColor('#333')
        TextInput({ placeholder: '请输入费用', text: this.fee })
          .width('100%')
          .height(50)
          .backgroundColor('#F5F5F5')
          .borderRadius(8)
          .type(InputType.Number)
          .onChange((value: string) => { this.fee = value; })
      }
      .alignItems(HorizontalAlign.Start)
    }
    .width('100%')
    .layoutWeight(1)
    .padding(16)
    .backgroundColor(Color.White)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }

  @Builder
  StyleChip(label: string, value: string) {
    Text(label)
      .fontSize(14)
      .fontColor(this.style === value ? '#FFFFFF' : '#666666')
      .padding({ left: 12, right: 12, top: 8, bottom: 8 })
      .borderRadius(8)
      .backgroundColor(this.style === value ? '#1890FF' : '#F5F5F5')
      .onClick(() => {
        this.style = value;
      })
  }
}
