import { AuthService } from '../services/AuthService';
import { Toast } from '../common/utils/Toast';
import { Logger } from '../common/utils/Logger';
import { RegisterRequest, UserRole } from '../models/User';

export class RegisterViewModel {
  phone: string = '';
  password: string = '';
  confirmPassword: string = '';
  nickname: string = '';
  role: UserRole = UserRole.PHOTOGRAPHER;
  isLoading: boolean = false;

  validateInput(): boolean {
    if (!this.phone || !/^1[3-9]\d{9}$/.test(this.phone)) {
      Toast.showShort('请输入正确的手机号');
      return false;
    }

    if (!this.password || this.password.length < 6) {
      Toast.showShort('密码至少6位');
      return false;
    }

    if (this.password !== this.confirmPassword) {
      Toast.showShort('两次密码不一致');
      return false;
    }

    if (!this.nickname || this.nickname.trim().length === 0) {
      Toast.showShort('请输入昵称');
      return false;
    }

    return true;
  }

  async register(): Promise<boolean> {
    if (!this.validateInput()) {
      return false;
    }

    this.isLoading = true;

    try {
      const request: RegisterRequest = {
        phone: this.phone,
        password: this.password,
        nickname: this.nickname,
        role: this.role
      };

      await AuthService.register(request);
      Toast.showShort('注册成功');
      return true;
    } catch (error) {
      Logger.error('RegisterViewModel', 'Register failed: %{public}s', JSON.stringify(error));
      Toast.showShort('注册失败，请重试');
      return false;
    } finally {
      this.isLoading = false;
    }
  }
}
