import { ProfileViewModel } from '../viewmodels/ProfileViewModel';
import { BookingProfile } from '../models/BookingProfile';
import { Booking } from '../models/Booking';
import router from '@ohos.router';

@Entry
@Component
struct ProfilePage {
  @State viewModel: ProfileViewModel = new ProfileViewModel();
  @State profile: BookingProfile | null = null;
  @State isLoading: boolean = false;
  private userId: string = '';

  aboutToAppear() {
    const params = router.getParams() as Record<string, string>;
    this.userId = params?.userId || '';

    this.viewModel.onDataChange(() => {
      this.profile = this.viewModel.getProfile();
      this.isLoading = this.viewModel.isLoading();
    });

    if (this.userId) {
      this.viewModel.loadProfile(this.userId);
    } else {
      this.viewModel.loadMyProfile();
    }
  }

  navigateBack() {
    router.back();
  }

  navigateToBookingDetail(bookingId: string) {
    router.pushUrl({
      url: 'pages/BookingDetailPage',
      params: { bookingId }
    });
  }

  navigateToChat(userId: string) {
    router.pushUrl({
      url: 'pages/ChatPage',
      params: { userId }
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

        Text('个人档案')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .layoutWeight(1)

        if (this.profile) {
          Button('聊天')
            .fontSize(14)
            .backgroundColor('#1890FF')
            .fontColor(Color.White)
            .borderRadius(15)
            .onClick(() => {
              this.navigateToChat(this.profile.userId);
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
    } else if (this.profile) {
      Scroll() {
        Column({ space: 16 }) {
          Column({ space: 12 }) {
            Row() {
              Image(this.profile.avatar)
                .width(80)
                .height(80)
                .borderRadius(40)

              Column({ space: 6 }) {
                Row() {
                  Text(this.profile.nickname)
                    .fontSize(20)
                    .fontWeight(FontWeight.Bold)
                    .fontColor('#333')

                  if (this.profile.isVerified) {
                    Image($r('app.media.ic_verified'))
                      .width(20)
                      .height(20)
                      .margin({ left: 4 })
                  }
                }

                Text(this.profile.role === 'photographer' ? '摄影师' : '模特')
                  .fontSize(14)
                  .fontColor('#1890FF')
                  .padding({ left: 8, right: 8, top: 4, bottom: 4 })
                  .borderRadius(10)
                  .backgroundColor('#E6F7FF')
              }
              .alignItems(HorizontalAlign.Start)
              .layoutWeight(1)
            }
            .width('100%')

            Row({ space: 20 }) {
              this.StatItem('评分', this.profile.rating)
              this.StatItem('评价', this.profile.reviewCount)
              this.StatItem('约拍', this.profile.completedBookings)
            }
            .width('100%')
            .justifyContent(FlexAlign.SpaceAround)
            .margin({ top: 12 })

            Text(this.profile.bio)
              .fontSize(14)
              .fontColor('#666')
              .lineHeight(22)

            if (this.profile.styleTags.length > 0) {
              Row({ space: 8 }) {
                ForEach(this.profile.styleTags, (tag: string) => {
                  Text(tag)
                    .fontSize(13)
                    .fontColor('#1890FF')
                    .padding({ left: 10, right: 10, top: 6, bottom: 6 })
                    .borderRadius(15)
                    .backgroundColor('#E6F7FF')
                })
              }
              .width('100%')
              .margin({ top: 12 })
            }
          }
          .width('100%')
          .padding(20)
          .backgroundColor(Color.White)
          .borderRadius(10)

          Row({ space: 10 }) {
            this.InfoCard($r('app.media.ic_location'), this.profile.location.city, '服务地区')
            if (this.profile.priceRange) {
              this.InfoCard($r('app.media.ic_price'), `¥${this.profile.priceRange.min}-${this.profile.priceRange.max}`, '价格范围')
            }
          }
          .width('100%')

          Column({ space: 12 }) {
            Text('作品集').fontSize(16).fontWeight(FontWeight.Medium).fontColor('#333')

            Grid() {
              ForEach(this.profile.portfolio, (item) => {
                GridItem() {
                  Image(item.imageUrl)
                    .width('100%')
                    .aspectRatio(1)
                    .objectFit(ImageFit.Cover)
                    .borderRadius(8)
                }
              })
            }
            .columnsTemplate('1fr 1fr 1fr')
            .columnsGap(8)
            .rowsGap(8)
          }
          .width('100%')
          .padding(16)
          .backgroundColor(Color.White)
          .borderRadius(10)

          Column({ space: 8 }) {
            Text('可约时间').fontSize(14).fontColor('#666')

            Row({ space: 12 }) {
              ForEach(['周一', '周二', '周三', '周四', '周五', '周六', '周日'], (day, index) => {
                Text(day)
                  .fontSize(12)
                  .fontColor(this.profile.availability.weekdays[index] ? '#FFFFFF' : '#999')
                  .width(36)
                  .height(36)
                  .borderRadius(18)
                  .textAlign(TextAlign.Center)
                  .backgroundColor(this.profile.availability.weekdays[index] ? '#1890FF' : '#F5F5F5')
              })
            }
            .width('100%')
            .justifyContent(FlexAlign.SpaceBetween)

            Text(`${this.profile.availability.timeRange.start} - ${this.profile.availability.timeRange.end}`)
              .fontSize(14)
              .fontColor('#333')
              .margin({ top: 8 })
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
  StatItem(label: string, value: number) {
    Column() {
      Text(value.toString())
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor('#333')

      Text(label)
        .fontSize(12)
        .fontColor('#999')
        .margin({ top: 4 })
    }
    .alignItems(HorizontalAlign.Center)
  }

  @Builder
  InfoCard(icon: Resource, value: string, label: string) {
    Row() {
      Image(icon).width(24).height(24).margin({ right: 8 })

      Column({ space: 4 }) {
        Text(value).fontSize(15).fontWeight(FontWeight.Medium).fontColor('#333')
        Text(label).fontSize(12).fontColor('#999')
      }
      .alignItems(HorizontalAlign.Start)
    }
    .width('48%')
    .padding(16)
    .backgroundColor(Color.White)
    .borderRadius(10)
  }
}
