import { describe, it, expect, beforeAll, afterAll } from '@ohos/hypium';
import common from '@ohos.app.ability.common';
import { DatabaseService } from '../../../main/ets/services/DatabaseService';
import { AlbumService } from '../../../main/ets/services/AlbumService';
import { CreateAlbumRequest } from '../../../main/ets/models/Album';

export default function albumServiceTest() {
  describe('AlbumService', () => {
    let context: common.Context;
    let createdAlbumId: number;

    beforeAll(async () => {
      await DatabaseService.init(context);
    });

    afterAll(async () => {
      // 清理测试数据
    });

    it('应该创建新相册', async () => {
      const request: CreateAlbumRequest = {
        name: '测试相册',
        description: '测试描述'
      };

      const album = await AlbumService.createAlbum(request.name, request.description);
      expect(album).not.toBeNull();
      expect(album.name).assertEqual(request.name);
      expect(album.description).assertEqual(request.description);
      createdAlbumId = album.id;
    });

    it('应该获取所有相册', async () => {
      const albums = await AlbumService.getAllAlbums();
      expect(albums.length).assertLarger(0);
    });

    it('应该通过ID获取相册', async () => {
      const album = await AlbumService.getAlbumById(createdAlbumId);
      expect(album).not.toBeNull();
      expect(album.id).assertEqual(createdAlbumId);
    });

    it('应该更新相册', async () => {
      const updated = await AlbumService.updateAlbum(createdAlbumId, { name: '更新后的名称' });
      expect(updated.name).assertEqual('更新后的名称');
    });

    it('应该设置封面照片', async () => {
      const coverPath = '/path/to/cover.jpg';
      await AlbumService.setCoverPhoto(createdAlbumId, coverPath);
      const album = await AlbumService.getAlbumById(createdAlbumId);
      expect(album.coverPhotoPath).assertEqual(coverPath);
    });

    it('应该更新照片数量', async () => {
      await AlbumService.updatePhotoCount(createdAlbumId);
      const album = await AlbumService.getAlbumById(createdAlbumId);
      expect(album.photoCount).assertEqual(0); // 还没有添加照片
    });

    it('应该删除相册', async () => {
      await AlbumService.deleteAlbum(createdAlbumId);
      const album = await AlbumService.getAlbumById(createdAlbumId);
      expect(album).toBeNull();
    });
  });
}
