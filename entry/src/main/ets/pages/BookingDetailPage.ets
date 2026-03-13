import { BookingDetailViewModel } from '../viewmodels/BookingDetailViewModel';
import { Booking, BookingStatus } from '../models/Booking';
import router from '@ohos.router';
import promptAction from '@ohos.promptAction';

@Entry
@Component
struct BookingDetailPage {
  @State viewModel: BookingDetailViewModel = new BookingDetailViewModel();
  @State booking: Booking | null = null;
  @State isLoading: boolean = false;
  private bookingId: string = '';

  aboutToAppear() {
    const params = router.getParams() as Record<string, string>;
    this.bookingId = params?.bookingId || '';

    this.viewModel.onDataChange(() => {
      this.booking = this.viewModel.getBooking();
      this.isLoading = this.viewModel.isLoading();
    });

    if (this.bookingId) {
      this.viewModel.loadBooking(this.bookingId);
    }
  }

  navigateBack() {
    router.back();
  }

  navigateToChat() {
    if (this.booking) {
      router.pushUrl({
        url: 'pages/ChatPage',
        params: {
          userId: this.booking.targetId,
          bookingId: this.bookingId
        }
      });
    }
  }

  async handleAccept() {
    const success = await this.viewModel.acceptBooking();
    if (success) {
      promptAction.showToast({ message: '已接受约拍' });
    }
  }

  async handleReject() {
    promptAction.showDialog({
      title: '确认拒绝',
      message: '确定要拒绝这个约拍请求吗？',
      buttons: [
        { text: '取消', color: '#999' },
        { text: '拒绝', color: '#FF4D4F' }
      ]
    }, async (err, data) => {
      if (data.index === 1) {
        const success = await this.viewModel.rejectBooking();
        if (success) {
          promptAction.showToast({ message: '已拒绝约拍' });
          this.navigateBack();
        }
      }
    });
  }

  async handleCancel() {
    promptAction.showDialog({
      title: '确认取消',
      message: '确定要取消这个约拍吗？',
      buttons: [
        { text: '取消', color: '#999' },
        { text: '确定', color: '#FF4D4F' }
      ]
    }, async (err, data) => {
      if (data.index === 1) {
        const success = await this.viewModel.cancelBooking();
        if (success) {
          promptAction.showToast({ message: '已取消约拍' });
          this.navigateBack();
        }
      }
    });
  }

  async handleComplete() {
    promptAction.showDialog({
      title: '确认完成',
      message: '确认约拍已完成？',
      buttons: [
        { text: '取消', color: '#999' },
        { text: '确认完成', color: '#52C41A' }
      ]
    }, async (err, data) => {
      if (data.index === 1) {
        const success = await this.viewModel.completeBooking();
        if (success) {
          promptAction.showToast({ message: '约拍已完成' });
        }
      }
    });
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

        Text('约拍详情')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .layoutWeight(1)

        if (this.booking) {
          Button('聊天')
            .fontSize(14)
            .backgroundColor('#1890FF')
            .fontColor(Color.White)
            .borderRadius(15)
            .onClick(() => {
              this.navigateToChat();
            })
        }
      }
      .width('100%')
      .padding(16)
      .backgroundColor(Color.White)
    }

    if (this.isLoading) {
      Column() {
        LoadingProgress().width(40).height(40)
        Text('加载中...').fontSize(14).fontColor('#999').margin({ top: 8 })
      }
      .width('100%')
      .layoutWeight(1)
      .justifyContent(FlexAlign.Center)
    } else if (this.booking) {
      Scroll() {
        Column({ space: 16 }) {
          Row() {
            Column() {
              Text(this.viewModel.getStatusText(this.booking.status))
                .fontSize(24)
                .fontWeight(FontWeight.Bold)
                .fontColor(this.viewModel.getStatusColor(this.booking.status))

              Text(this.booking.scheduledTime.split('T')[0])
                .fontSize(14)
                .fontColor('#666')
                .margin({ top: 4 })
            }
            .alignItems(HorizontalAlign.Start)
            .layoutWeight(1)

            this.ActionButtons()
          }
          .width('100%')
          .padding(20)
          .backgroundColor('#F0F8FF')
          .borderRadius(10)

          Column({ space: 12 }) {
            Text('对方信息').fontSize(16).fontWeight(FontWeight.Medium).fontColor('#333')

            Row() {
              Image(this.booking.requester.avatar)
                .width(60)
                .height(60)
                .borderRadius(30)

              Column({ space: 4 }) {
                Text(this.booking.requester.nickname)
                  .fontSize(16)
                  .fontWeight(FontWeight.Medium)
                  .fontColor('#333')

                Row({ space: 8 }) {
                  Text(`评分 ${this.booking.requester.rating}`).fontSize(14).fontColor('#FFA500')
                  Text(this.booking.requester.role).fontSize(12).fontColor('#999')
                }
              }
              .alignItems(HorizontalAlign.Start)
              .margin({ left: 12 })
            }
            .width('100%')
          }
          .width('100%')
          .padding(16)
          .backgroundColor(Color.White)
          .borderRadius(10)

          Column({ space: 12 }) {
            this.DetailItem('标题', this.booking.title)
            this.DetailItem('风格', this.booking.style)
            this.DetailItem('地点', this.booking.location.address)
            this.DetailItem('城市', this.booking.location.city)
            this.DetailItem('时长', `${this.booking.duration} 小时`)
            this.DetailItem('费用', `¥${this.booking.fee}`)
          }
          .width('100%')
          .padding(16)
          .backgroundColor(Color.White)
          .borderRadius(10)

          Column({ space: 8 }) {
            Text('详细描述').fontSize(14).fontColor('#666')
            Text(this.booking.description).fontSize(15).fontColor('#333').lineHeight(24)
          }
          .width('100%')
          .padding(16)
          .backgroundColor(Color.White)
          .borderRadius(10)
        }
        .width('100%')
        .padding(16)
      }
      .layoutWeight(1)
      .scrollBar(BarState.Auto)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }

  @Builder
  ActionButtons() {
    if (this.booking?.status === BookingStatus.PENDING) {
      Row({ space: 10 }) {
        Button('拒绝').fontSize(14).backgroundColor('#FFF1F0').fontColor('#FF4D4F').borderRadius(15)
          .onClick(() => { this.handleReject(); })
        Button('接受').fontSize(14).backgroundColor('#52C41A').fontColor(Color.White).borderRadius(15)
          .onClick(() => { this.handleAccept(); })
      }
    } else if (this.booking?.status === BookingStatus.CONFIRMED) {
      Button('取消约拍').fontSize(14).backgroundColor('#FF4D4F').fontColor(Color.White).borderRadius(15)
        .onClick(() => { this.handleCancel(); })
    } else if (this.booking?.status === BookingStatus.IN_PROGRESS) {
      Button('完成约拍').fontSize(14).backgroundColor('#52C41A').fontColor(Color.White).borderRadius(15)
        .onClick(() => { this.handleComplete(); })
    }
  }

  @Builder
  DetailItem(label: string, value: string) {
    Row() {
      Text(label).fontSize(14).fontColor('#666').width(80)
      Text(value).fontSize(15).fontColor('#333').layoutWeight(1)
    }
    .width('100%')
  }
}
