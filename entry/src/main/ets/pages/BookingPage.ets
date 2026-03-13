import { BookingListViewModel } from '../viewmodels/BookingListViewModel';
import { Booking } from '../models/Booking';
import { BookingStatus } from '../models/Booking';
import router from '@ohos.router';

@Entry
@Component
struct BookingPage {
  @State viewModel: BookingListViewModel = new BookingListViewModel();
  @State bookings: Booking[] = [];
  @State isLoading: boolean = false;
  @State selectedStatus: BookingStatus | null = null;
  @State statusDialogVisible: boolean = false;

  aboutToAppear() {
    this.viewModel.onDataChange(() => {
      this.bookings = this.viewModel.getBookings();
      this.isLoading = this.viewModel.isLoading();
    });
    this.viewModel.loadBookings();
  }

  navigateToDetail(bookingId: string) {
    router.pushUrl({
      url: 'pages/BookingDetailPage',
      params: { bookingId }
    });
  }

  navigateToCreate() {
    router.pushUrl({
      url: 'pages/BookingCreatePage'
    });
  }

  filterByStatus(status: BookingStatus) {
    this.selectedStatus = status;
    this.viewModel.loadBookings(status);
    this.statusDialogVisible = false;
  }

  build() {
    Column() {
      Row() {
        Text('约拍')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .layoutWeight(1)

        Button('发布')
          .fontSize(14)
          .backgroundColor('#1890FF')
          .fontColor(Color.White)
          .borderRadius(15)
          .onClick(() => {
            this.navigateToCreate();
          })

        Button('筛选')
          .fontSize(14)
          .backgroundColor('#F0F0F0')
          .fontColor('#333')
          .borderRadius(15)
          .margin({ left: 8 })
          .onClick(() => {
            this.statusDialogVisible = true;
          })
      }
      .width('100%')
      .padding(16)
      .backgroundColor(Color.White)
    }

    Row({ space: 10 }) {
      this.StatusChip('全部', null)
      this.StatusChip('待确认', BookingStatus.PENDING)
      this.StatusChip('已确认', BookingStatus.CONFIRMED)
      this.StatusChip('进行中', BookingStatus.IN_PROGRESS)
      this.StatusChip('已完成', BookingStatus.COMPLETED)
    }
    .width('100%')
    .padding({ left: 16, right: 16, top: 12, bottom: 12 })
    .backgroundColor(Color.White)
    .margin({ bottom: 8 })

    if (this.isLoading) {
      Column() {
        LoadingProgress().width(40).height(40)
        Text('加载中...').fontSize(14).fontColor('#999').margin({ top: 8 })
      }
      .width('100%')
      .layoutWeight(1)
      .justifyContent(FlexAlign.Center)
    } else if (this.bookings.length === 0) {
      Column() {
        Text('📅').fontSize(64).margin({ bottom: 16 })
        Text('还没有约拍记录').fontSize(16).fontColor('#666')
        Text('发布你的第一个约拍吧').fontSize(14).fontColor('#999').margin({ top: 8 })
      }
      .width('100%')
      .layoutWeight(1)
      .justifyContent(FlexAlign.Center)
    } else {
      List({ space: 8 }) {
        ForEach(this.bookings, (booking: Booking) => {
          ListItem() {
            this.BookingCard(booking)
          }
          .onClick(() => {
            this.navigateToDetail(booking.id);
          })
        })
      }
      .width('100%')
      .layoutWeight(1)
      .padding({ left: 12, right: 12 })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }

  @Builder
  StatusChip(label: string, status: BookingStatus | null) {
    Text(label)
      .fontSize(13)
      .fontColor(this.selectedStatus === status ? '#FFFFFF' : '#666666')
      .padding({ left: 12, right: 12, top: 6, bottom: 6 })
      .borderRadius(15)
      .backgroundColor(this.selectedStatus === status ? '#1890FF' : '#F5F5F5')
      .onClick(() => {
        this.filterByStatus(status);
      })
  }

  @Builder
  BookingCard(booking: Booking) {
    Row() {
      Image(booking.requester.avatar)
        .width(50)
        .height(50)
        .borderRadius(25)

      Column({ space: 6 }) {
        Row() {
          Text(booking.requester.nickname)
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .fontColor('#333')

          Text(this.getStatusText(booking.status))
            .fontSize(12)
            .fontColor('#FFFFFF')
            .padding({ left: 8, right: 8, top: 4, bottom: 4 })
            .borderRadius(10)
            .backgroundColor(this.getStatusColor(booking.status))
        }
        .width('100%')
        .justifyContent(SpaceBetween)

        Text(booking.title)
          .fontSize(15)
          .fontColor('#333')
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })

        Row() {
          Text(booking.style)
            .fontSize(12)
            .fontColor('#1890FF')
            .padding({ left: 6, right: 6, top: 2, bottom: 2 })
            .borderRadius(4)
            .backgroundColor('#E6F7FF')

          Text(`${booking.location.city}`)
            .fontSize(12)
            .fontColor('#666')
            .margin({ left: 8 })

          Text(`${booking.duration}小时`)
            .fontSize(12)
            .fontColor('#666')
            .margin({ left: 8 })

          Text(`¥${booking.fee}`)
            .fontSize(12)
            .fontColor('#FF4D4F')
            .fontWeight(FontWeight.Medium)
            .margin({ left: 8 })
        }
        .width('100%')

        Text(booking.scheduledTime.split('T')[0])
          .fontSize(12)
          .fontColor('#999')
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)
      .margin({ left: 12 })

      Image($r('sys.media.ohos_ic_public_arrow_right'))
        .width(20)
        .height(20)
        .fillColor('#999')
    }
    .width('100%')
    .padding(16)
    .backgroundColor(Color.White)
    .borderRadius(10)
  }

  getStatusText(status: BookingStatus): string {
    switch (status) {
      case BookingStatus.PENDING: return '待确认';
      case BookingStatus.CONFIRMED: return '已确认';
      case BookingStatus.IN_PROGRESS: return '进行中';
      case BookingStatus.COMPLETED: return '已完成';
      case BookingStatus.CANCELLED: return '已取消';
      case BookingStatus.REJECTED: return '已拒绝';
      default: return '未知';
    }
  }

  getStatusColor(status: BookingStatus): string {
    switch (status) {
      case BookingStatus.PENDING: return '#FFA500';
      case BookingStatus.CONFIRMED: return '#52C41A';
      case BookingStatus.IN_PROGRESS: return '#1890FF';
      case BookingStatus.COMPLETED: return '#722ED1';
      case BookingStatus.CANCELLED: return '#999999';
      case BookingStatus.REJECTED: return '#FF4D4F';
      default: return '#999999';
    }
  }
}
