import { AuthService } from '../services/AuthService';
import { User } from '../models/User';
import { Logger } from '../common/utils/Logger';

export class MineViewModel {
  user: User | null = null;

  async loadUserInfo(): Promise<void> {
    try {
      this.user = await AuthService.getCurrentUser();
    } catch (error) {
      Logger.error('MineViewModel', 'Load user info failed: %{public}s', JSON.stringify(error));
    }
  }

  async logout(): Promise<void> {
    await AuthService.logout();
  }
}
