import { ChatViewModel } from '../viewmodels/ChatViewModel';
import { Message, MessageType } from '../models/Message';
import router from '@ohos.router';

@Entry
@Component
struct ChatPage {
  @State viewModel: ChatViewModel = new ChatViewModel();
  @State messages: Message[] = [];
  @State inputText: string = '';
  @State isLoading: boolean = false;
  @State isSending: boolean = false;
  private userId: string = '';
  private bookingId: string = '';

  aboutToAppear() {
    const params = router.getParams() as Record<string, string>;
    this.userId = params?.userId || '';
    this.bookingId = params?.bookingId || '';

    this.viewModel.onDataChange(() => {
      this.messages = this.viewModel.getMessages();
      this.isLoading = this.viewModel.isLoadingMessages();
      this.isSending = this.viewModel.isSending();
    });

    const conversationId = this.generateConversationId(this.userId);
    this.viewModel.loadMessages(conversationId);
  }

  navigateBack() {
    router.back();
  }

  generateConversationId(userId: string): string {
    const myId = 'current_user_id';
    return [myId, userId].sort().join('_');
  }

  async sendMessage() {
    if (!this.inputText.trim()) {
      return;
    }

    const success = await this.viewModel.sendMessage(
      this.userId,
      this.inputText,
      MessageType.TEXT
    );

    if (success) {
      this.inputText = '';
    }
  }

  isMyMessage(message: Message): boolean {
    return true;
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

        Text('聊天')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .layoutWeight(1)
      }
      .width('100%')
      .padding(16)
      .backgroundColor(Color.White)
      .border({ width: { bottom: 1 }, color: '#E8E8E8' })
    }

    if (this.isLoading) {
      Column() {
        LoadingProgress().width(40).height(40)
        Text('加载中...').fontSize(14).fontColor('#999').margin({ top: 8 })
      }
      .width('100%')
      .layoutWeight(1)
      .justifyContent(FlexAlign.Center)
    } else {
      List({ space: 12 }) {
        ForEach(this.messages, (message: Message) => {
          ListItem() {
            this.MessageBubble(message)
          }
        })
      }
      .width('100%')
      .layoutWeight(1)
      .padding({ left: 12, right: 12, top: 12 })
      .backgroundColor('#F5F5F5')
      .alignListItem(LIST_ALIGN_CENTER)
    }

    Row({ space: 8 }) {
      Button('+')
        .fontSize(24)
        .width(44)
        .height(44)
        .backgroundColor('#F5F5F5')
        .fontColor('#666')
        .borderRadius(22)
        .onClick(() => { })

      TextInput({ placeholder: '输入消息...', text: this.inputText })
        .layoutWeight(1)
        .height(44)
        .backgroundColor('#F5F5F5')
        .borderRadius(22)
        .onChange((value: string) => { this.inputText = value; })

      Button('发送')
        .fontSize(15)
        .width(60)
        .height(44)
        .backgroundColor(this.inputText.trim() ? '#1890FF' : '#B8B8B8')
        .fontColor(Color.White)
        .borderRadius(22)
        .enabled(!this.isSending && this.inputText.trim())
        .onClick(() => {
          this.sendMessage();
        })
    }
    .width('100%')
    .padding(12)
    .backgroundColor(Color.White)
  }

  @Builder
  MessageBubble(message: Message) {
    Row() {
      if (!this.isMyMessage(message)) {
        Image($r('app.media.default_avatar'))
          .width(40)
          .height(40)
          .borderRadius(20)
          .margin({ right: 8 })
      }

      Column() {
        Text(message.content)
          .fontSize(15)
          .fontColor(this.isMyMessage(message) ? '#FFFFFF' : '#333333')
          .padding(12)
          .borderRadius(8)
          .backgroundColor(this.isMyMessage(message) ? '#1890FF' : '#FFFFFF')

        Text(message.createdAt.split('T')[1]?.substring(0, 5) || '')
          .fontSize(11)
          .fontColor('#999')
          .margin({ top: 4 })
      }
      .alignItems(this.isMyMessage(message) ? HorizontalAlign.End : HorizontalAlign.Start)
      .layoutWeight(1)

      if (this.isMyMessage(message)) {
        Image($r('app.media.my_avatar'))
          .width(40)
          .height(40)
          .borderRadius(20)
          .margin({ left: 8 })
      }
    }
    .width('100%')
    .justifyContent(this.isMyMessage(message) ? FlexAlign.End : FlexAlign.Start)
  }
}
