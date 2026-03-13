import { describe, it, expect } from '@ohos/hypium';
import { StorageService } from '../../../main/ets/services/StorageService';

export default function storageServiceTest() {
  describe('StorageService', () => {
    it('should save and retrieve string value', async () => {
      const key = 'test_key';
      const value = 'test_value';
      
      await StorageService.putString(key, value);
      const result = await StorageService.getString(key, '');
      
      expect(result).assertEqual(value);
    });

    it('should save and retrieve json object', async () => {
      const key = 'test_object';
      const value = { name: 'test', age: 25 };
      
      await StorageService.putObject(key, value);
      const result = await StorageService.getObject(key, null);
      
      expect(result.name).assertEqual('test');
      expect(result.age).assertEqual(25);
    });

    it('should return default value when key not exists', async () => {
      const result = await StorageService.getString('not_exists', 'default');
      expect(result).assertEqual('default');
    });

    it('should delete value by key', async () => {
      const key = 'to_delete';
      await StorageService.putString(key, 'value');
      await StorageService.remove(key);
      const result = await StorageService.getString(key, 'default');
      expect(result).assertEqual('default');
    });
  });
}
