import { describe, it, expect, beforeAll, afterAll } from '@ohos/hypium';
import common from '@ohos.app.ability.common';
import { DatabaseService } from '../../../main/ets/services/DatabaseService';
import { AlbumService } from '../../../main/ets/services/AlbumService';
import { PhotoService } from '../../../main/ets/services/PhotoService';
import { Photo } from '../../../main/ets/models/Photo';

export default function photoServiceTest() {
  describe('PhotoService', () => {
    let context: common.Context;
    let testAlbumId: number;
    let testPhotoId: number;

    beforeAll(async () => {
      await DatabaseService.init(context);
      const album = await AlbumService.createAlbum('测试相册', '测试描述');
      testAlbumId = album.id;
    });

    afterAll(async () => {
      await AlbumService.deleteAlbum(testAlbumId);
    });

    it('应该添加照片到相册', async () => {
      const photoUri = '/test/path/photo.jpg';
      const photo = await PhotoService.addPhotosToAlbum(testAlbumId, [photoUri]);
      expect(photo.length).assertEqual(1);
      testPhotoId = photo[0].id;
      expect(photo[0].originalPath).assertEqual(photoUri);
    });

    it('应该获取相册内的照片', async () => {
      const photos = await PhotoService.getPhotosByAlbum(testAlbumId);
      expect(photos.length).assertEqual(1);
      expect(photos[0].id).assertEqual(testPhotoId);
    });

    it('应该通过ID获取照片', async () => {
      const photo = await PhotoService.getPhotoById(testPhotoId);
      expect(photo).not.toBeNull();
      expect(photo.id).assertEqual(testPhotoId);
    });

    it('应该更新照片标签', async () => {
      const tags = ['风景', '自然'];
      const updated = await PhotoService.updatePhoto(testPhotoId, { tags });
      expect(updated.tags).assertEqual(JSON.stringify(tags));
    });

    it('应该删除照片', async () => {
      await PhotoService.deletePhoto(testPhotoId);
      const photo = await PhotoService.getPhotoById(testPhotoId);
      expect(photo).toBeNull();
    });

    it('应该批量删除照片', async () => {
      const photo1 = await PhotoService.addPhotosToAlbum(testAlbumId, ['/test/photo1.jpg']);
      const photo2 = await PhotoService.addPhotosToAlbum(testAlbumId, ['/test/photo2.jpg']);
      await PhotoService.deletePhotos([photo1[0].id, photo2[0].id]);
      const photos = await PhotoService.getPhotosByAlbum(testAlbumId);
      expect(photos.length).assertEqual(0);
    });
  });
}
