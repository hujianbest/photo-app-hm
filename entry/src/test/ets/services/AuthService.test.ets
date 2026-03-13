import { describe, it, expect, beforeEach } from '@ohos/hypium';
import { AuthService } from '../../../main/ets/services/AuthService';
import { StorageService } from '../../../main/ets/services/StorageService';

export default function authServiceTest() {
  describe('AuthService', () => {
    beforeEach(async () => {
      await StorageService.clear();
    });

    it('should register new user successfully', async () => {
      const request = {
        phone: '13800138000',
        password: 'Test123456',
        nickname: '测试用户',
        role: 'photographer'
      };
      
      const response = await AuthService.register(request);
      expect(response.token).assertNotEmpty();
      expect(response.user.nickname).assertEqual('测试用户');
    });

    it('should login with phone and password', async () => {
      const request = {
        phone: '13800138000',
        password: 'Test123456'
      };
      
      const response = await AuthService.login(request);
      expect(response.token).assertNotEmpty();
    });

    it('should save token to storage after login', async () => {
      await AuthService.login({
        phone: '13800138000',
        password: 'Test123456'
      });
      
      const token = await AuthService.getToken();
      expect(token).assertNotEmpty();
    });

    it('should return null when not logged in', async () => {
      const user = await AuthService.getCurrentUser();
      expect(user).assertNull();
    });

    it('should logout and clear token', async () => {
      await AuthService.login({
        phone: '13800138000',
        password: 'Test123456'
      });
      
      await AuthService.logout();
      
      const token = await AuthService.getToken();
      expect(token).assertNull();
    });
  });
}
