import relationalStore from '@ohos.data.relationalStore';
import { Photo, UpdatePhotoRequest } from '../models/Photo';
import { DatabaseService } from './DatabaseService';
import { AlbumService } from './AlbumService';
import { Logger } from '../common/utils/Logger';

export class PhotoService {
  static async addPhotosToAlbum(albumId: number, photoUris: string[]): Promise<Photo[]> {
    const addedPhotos: Photo[] = [];

    try {
      for (const uri of photoUris) {
        const now = Date.now();
        const values: relationalStore.ValuesBucket = {
          albumId: albumId,
          originalPath: uri,
          thumbnailPath: '',
          width: 0,
          height: 0,
          size: 0,
          takenAt: now,
          location: '',
          tags: '[]',
          createdAt: now
        };

        const rowId = await DatabaseService.insert('photos', values);
        const photo = await PhotoService.getPhotoById(rowId);
        if (photo) {
          addedPhotos.push(photo);
        }
      }

      // 更新相册照片数量
      await AlbumService.updatePhotoCount(albumId);
      Logger.info('PhotoService', '添加了 %{public}d 张照片到相册 %{public}d', addedPhotos.length, albumId);
      return addedPhotos;
    } catch (error) {
      Logger.error('PhotoService', '添加照片失败: %{public}s', JSON.stringify(error));
      throw error;
    }
  }

  static async getPhotosByAlbum(albumId: number): Promise<Photo[]> {
    try {
      const resultSet = await DatabaseService.query(
        'SELECT * FROM photos WHERE albumId = ? ORDER BY createdAt DESC',
        [albumId]
      );
      const photos: Photo[] = [];
      if (resultSet.rowCount > 0) {
        resultSet.goToFirstRow();
        do {
          photos.push(PhotoService.mapResultSetToPhoto(resultSet));
        } while (resultSet.goToNextRow());
      }
      resultSet.close();
      return photos;
    } catch (error) {
      Logger.error('PhotoService', '获取相册照片失败: %{public}s', JSON.stringify(error));
      throw error;
    }
  }

  static async getPhotoById(id: number): Promise<Photo | null> {
    try {
      const resultSet = await DatabaseService.query(
        'SELECT * FROM photos WHERE id = ?',
        [id]
      );
      if (resultSet.rowCount === 0) {
        resultSet.close();
        return null;
      }
      resultSet.goToFirstRow();
      const photo = PhotoService.mapResultSetToPhoto(resultSet);
      resultSet.close();
      return photo;
    } catch (error) {
      Logger.error('PhotoService', '获取照片失败: %{public}s', JSON.stringify(error));
      throw error;
    }
  }

  static async updatePhoto(id: number, updates: Partial<UpdatePhotoRequest>): Promise<Photo> {
    const values: relationalStore.ValuesBucket = {};

    if (updates.tags !== undefined) {
      values['tags'] = JSON.stringify(updates.tags);
    }
    if (updates.location !== undefined) {
      values['location'] = updates.location;
    }

    try {
      const predicates = new relationalStore.RdbPredicates('photos');
      predicates.equalTo('id', id);
      const rowsAffected = await DatabaseService.update('photos', values, predicates);
      if (rowsAffected === 0) {
        throw new Error('照片未找到');
      }
      const photo = await PhotoService.getPhotoById(id);
      if (!photo) {
        throw new Error('更新照片失败');
      }
      Logger.info('PhotoService', '照片更新成功: %{public}d', id);
      return photo;
    } catch (error) {
      Logger.error('PhotoService', '更新照片失败: %{public}s', JSON.stringify(error));
      throw error;
    }
  }

  static async deletePhoto(id: number): Promise<void> {
    try {
      const photo = await PhotoService.getPhotoById(id);
      if (!photo) {
        throw new Error('照片未找到');
      }

      const predicates = new relationalStore.RdbPredicates('photos');
      predicates.equalTo('id', id);
      const rowsAffected = await DatabaseService.delete('photos', predicates);
      if (rowsAffected === 0) {
        throw new Error('删除照片失败');
      }

      // 更新相册照片数量
      await AlbumService.updatePhotoCount(photo.albumId);
      Logger.info('PhotoService', '照片删除成功: %{public}d', id);
    } catch (error) {
      Logger.error('PhotoService', '删除照片失败: %{public}s', JSON.stringify(error));
      throw error;
    }
  }

  static async deletePhotos(photoIds: number[]): Promise<number> {
    let deletedCount = 0;
    const albumIdsToUpdate = new Set<number>();

    try {
      for (const id of photoIds) {
        const photo = await PhotoService.getPhotoById(id);
        if (photo) {
          albumIdsToUpdate.add(photo.albumId);
          const predicates = new relationalStore.RdbPredicates('photos');
          predicates.equalTo('id', id);
          const rowsAffected = await DatabaseService.delete('photos', predicates);
          deletedCount += rowsAffected;
        }
      }

      // 更新相册照片数量
      for (const albumId of albumIdsToUpdate) {
        await AlbumService.updatePhotoCount(albumId);
      }

      Logger.info('PhotoService', '删除了 %{public}d 张照片', deletedCount);
      return deletedCount;
    } catch (error) {
      Logger.error('PhotoService', '批量删除照片失败: %{public}s', JSON.stringify(error));
      throw error;
    }
  }

  static async movePhotos(photoIds: number[], targetAlbumId: number): Promise<number> {
    let movedCount = 0;
    const oldAlbumIds = new Set<number>();

    try {
      for (const id of photoIds) {
        const photo = await PhotoService.getPhotoById(id);
        if (photo) {
          oldAlbumIds.add(photo.albumId);
          const values: relationalStore.ValuesBucket = { albumId: targetAlbumId };
          const predicates = new relationalStore.RdbPredicates('photos');
          predicates.equalTo('id', id);
          const rowsAffected = await DatabaseService.update('photos', values, predicates);
          movedCount += rowsAffected;
        }
      }

      // 更新旧相册和新相册的照片数量
      await AlbumService.updatePhotoCount(targetAlbumId);
      for (const albumId of oldAlbumIds) {
        await AlbumService.updatePhotoCount(albumId);
      }

      Logger.info('PhotoService', '移动了 %{public}d 张照片到相册 %{public}d', movedCount, targetAlbumId);
      return movedCount;
    } catch (error) {
      Logger.error('PhotoService', '移动照片失败: %{public}s', JSON.stringify(error));
      throw error;
    }
  }

  static async addTagsToPhotos(photoIds: number[], tags: string[]): Promise<number> {
    let updatedCount = 0;

    try {
      for (const id of photoIds) {
        const photo = await PhotoService.getPhotoById(id);
        if (photo) {
          const existingTags = JSON.parse(photo.tags) as string[];
          const mergedTags = [...new Set([...existingTags, ...tags])];
          await PhotoService.updatePhoto(id, { tags: mergedTags });
          updatedCount++;
        }
      }

      Logger.info('PhotoService', '为 %{public}d 张照片添加了标签', updatedCount);
      return updatedCount;
    } catch (error) {
      Logger.error('PhotoService', '添加标签失败: %{public}s', JSON.stringify(error));
      throw error;
    }
  }

  private static mapResultSetToPhoto(resultSet: relationalStore.ResultSet): Photo {
    return {
      id: resultSet.getLong(resultSet.getColumnIndex('id')),
      albumId: resultSet.getLong(resultSet.getColumnIndex('albumId')),
      originalPath: resultSet.getString(resultSet.getColumnIndex('originalPath')),
      thumbnailPath: resultSet.getString(resultSet.getColumnIndex('thumbnailPath')),
      width: resultSet.getLong(resultSet.getColumnIndex('width')),
      height: resultSet.getLong(resultSet.getColumnIndex('height')),
      size: resultSet.getLong(resultSet.getColumnIndex('size')),
      takenAt: resultSet.getLong(resultSet.getColumnIndex('takenAt')),
      location: resultSet.getString(resultSet.getColumnIndex('location')),
      tags: resultSet.getString(resultSet.getColumnIndex('tags')),
      createdAt: resultSet.getLong(resultSet.getColumnIndex('createdAt'))
    };
  }
}
