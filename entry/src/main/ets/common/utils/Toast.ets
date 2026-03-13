import promptAction from '@ohos.promptAction';

export class Toast {
  static show(message: string, duration: number = 2000) {
    promptAction.showToast({
      message: message,
      duration: duration
    });
  }

  static showShort(message: string) {
    Toast.show(message, 1500);
  }

  static showLong(message: string) {
    Toast.show(message, 3500);
  }
}
