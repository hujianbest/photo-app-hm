import hilog from '@ohos.hilog';

export class Logger {
  private static readonly DOMAIN = 0x0000;
  private static readonly APP_TAG = 'PhotoApp';

  static debug(tag: string, message: string, ...args: any[]) {
    hilog.debug(Logger.DOMAIN, tag, message, args);
  }

  static info(tag: string, message: string, ...args: any[]) {
    hilog.info(Logger.DOMAIN, tag, message, args);
  }

  static warn(tag: string, message: string, ...args: any[]) {
    hilog.warn(Logger.DOMAIN, tag, message, args);
  }

  static error(tag: string, message: string, ...args: any[]) {
    hilog.error(Logger.DOMAIN, tag, message, args);
  }
}
