import { describe, it, expect } from '@ohos/hypium';
import { HttpService } from '../../../main/ets/services/HttpService';

export default function httpServiceTest() {
  describe('HttpService', () => {
    it('should make GET request successfully', async () => {
      const response = await HttpService.get<{ status: string }>('/health');
      expect(response.code).assertEqual(200);
    });

    it('should make POST request with body', async () => {
      const body = { username: 'test', password: '123456' };
      const response = await HttpService.post<any>('/auth/login', body);
      expect(response).assertNotNull();
    });

    it('should include auth token in headers when set', async () => {
      HttpService.setToken('test_token');
      const headers = HttpService.getHeaders();
      expect(headers['Authorization']).assertEqual('Bearer test_token');
    });
  });
}
