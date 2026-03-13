import { describe, it, expect, beforeAll } from '@ohos/hypium';
import common from '@ohos.app.ability.common';
import { DatabaseService } from '../../../main/ets/services/DatabaseService';

export default function databaseServiceTest() {
  describe('DatabaseService', () => {
    let context: common.Context;

    beforeAll(() => {
      // Context将由测试运行器提供
    });

    it('应该成功初始化数据库', async () => {
      await DatabaseService.init(context);
      // 不应该抛出任何错误
      expect(true).assertEqual(true);
    });

    it('应该创建albums表', async () => {
      const albums = await DatabaseService.query('SELECT COUNT(*) as count FROM albums', []);
      expect(albums.length).assertLarger(0);
    });

    it('应该创建photos表', async () => {
      const photos = await DatabaseService.query('SELECT COUNT(*) as count FROM photos', []);
      expect(photos.length).assertLarger(0);
    });

    it('应该创建tags表', async () => {
      const tags = await DatabaseService.query('SELECT COUNT(*) as count FROM tags', []);
      expect(tags.length).assertLarger(0);
    });
  });
}
