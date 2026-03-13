import UIAbility from '@ohos.app.ability.UIAbility';
import window from '@ohos.window';
import hilog from '@ohos.hilog';
import { StorageService } from '../services/StorageService';
import { DatabaseService } from '../services/DatabaseService';

export default class EntryAbility extends UIAbility {
  async onCreate(want, launchParam) {
    hilog.info(0x0000, 'EntryAbility', 'onCreate');
    StorageService.init(this.context);

    // 初始化DatabaseService
    try {
      await DatabaseService.init(this.context);
    } catch (error) {
      hilog.error(0x0000, 'EntryAbility', 'DatabaseService初始化失败: %{public}s', JSON.stringify(error));
    }
  }

  onDestroy(want, launchParam) {
    hilog.info(0x0000, 'EntryAbility', 'onDestroy');
  }

  onWindowStageCreate(windowStage: window.WindowStage) {
    hilog.info(0x0000, 'EntryAbility', 'onWindowStageCreate');

    windowStage.loadContent('pages/SplashPage', (err, data) => {
      if (err.code) {
        hilog.error(0x0000, 'EntryAbility', 'Failed to load content. Cause: %{public}s', 
          JSON.stringify(err));
        return;
      }
      hilog.info(0x0000, 'EntryAbility', 'Succeeded in loading content. Data: %{public}s',
        JSON.stringify(data));
    });
  }

  onWindowStageDestroy() {
    hilog.info(0x0000, 'EntryAbility', 'onWindowStageDestroy');
  }

  onForeground() {
    hilog.info(0x0000, 'EntryAbility', 'onForeground');
  }

  onBackground() {
    hilog.info(0x0000, 'EntryAbility', 'onBackground');
  }
}
