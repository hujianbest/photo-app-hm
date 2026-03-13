import { describe, it, expect, beforeAll, afterAll } from '@ohos/hypium';
import common from '@ohos.app.ability.common';
import { DatabaseService } from '../../../main/ets/services/DatabaseService';
import { TagService } from '../../../main/ets/services/TagService';
import { Tag } from '../../../main/ets/models/Tag';

export default function tagServiceTest() {
  describe('TagService', () => {
    let context: common.Context;
    let testTagId: number;

    beforeAll(async () => {
      await DatabaseService.init(context);
    });

    afterAll(async () => {
      await TagService.deleteTag(testTagId);
    });

    it('应该创建新标签', async () => {
      const tag = await TagService.createTag('风景', '#FF5722');
      expect(tag).not.toBeNull();
      expect(tag.name).assertEqual('风景');
      expect(tag.color).assertEqual('#FF5722');
      testTagId = tag.id;
    });

    it('应该获取所有标签', async () => {
      const tags = await TagService.getAllTags();
      expect(tags.length).assertLarger(0);
    });

    it('应该更新标签', async () => {
      const updated = await TagService.updateTag(testTagId, { name: '更新后的标签' });
      expect(updated.name).assertEqual('更新后的标签');
    });

    it('应该删除标签', async () => {
      const testTag = await TagService.createTag('临时标签');
      await TagService.deleteTag(testTag.id);
      const tag = await TagService.getTagById(testTag.id);
      expect(tag).toBeNull();
    });
  });
}
