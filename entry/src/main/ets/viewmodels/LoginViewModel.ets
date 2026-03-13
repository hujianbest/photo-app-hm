import { AuthService } from '../services/AuthService';
import { Toast } from '../common/utils/Toast';
import { Logger } from '../common/utils/Logger';
import { LoginRequest } from '../models/User';

export class LoginViewModel {
  phone: string = '';
  password: string = '';
  isLoading: boolean = false;

  validateInput(): boolean {
    if (!this.phone || this.phone.trim().length === 0) {
      Toast.showShort('请输入手机号');
      return false;
    }

    if (!this.password || this.password.length < 6) {
      Toast.showShort('密码至少6位');
      return false;
    }

    return true;
  }

  async login(): Promise<boolean> {
    if (!this.validateInput()) {
      return false;
    }

    this.isLoading = true;

    try {
      const request: LoginRequest = {
        phone: this.phone,
        password: this.password
      };

      await AuthService.login(request);
      Toast.showShort('登录成功');
      return true;
    } catch (error) {
      Logger.error('LoginViewModel', 'Login failed: %{public}s', JSON.stringify(error));
      Toast.showShort('登录失败，请检查账号密码');
      return false;
    } finally {
      this.isLoading = false;
    }
  }
}
