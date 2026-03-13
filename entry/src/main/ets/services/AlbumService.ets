import relationalStore from '@ohos.data.relationalStore';
import { Album, CreateAlbumRequest, UpdateAlbumRequest } from '../models/Album';
import { DatabaseService } from './DatabaseService';
import { Logger } from '../common/utils/Logger';

export class AlbumService {
  static async createAlbum(name: string, description: string = ''): Promise<Album> {
    const now = Date.now();
    const values: relationalStore.ValuesBucket = {
      name: name,
      coverPhotoPath: '',
      photoCount: 0,
      description: description,
      createdAt: now,
      updatedAt: now
    };

    try {
      const rowId = await DatabaseService.insert('albums', values);
      const album = await AlbumService.getAlbumById(rowId);
      if (!album) {
        throw new Error('创建相册失败');
      }
      Logger.info('AlbumService', '相册创建成功: %{public}d', rowId);
      return album;
    } catch (error) {
      Logger.error('AlbumService', '创建相册失败: %{public}s', JSON.stringify(error));
      throw error;
    }
  }

  static async getAllAlbums(): Promise<Album[]> {
    try {
      const resultSet = await DatabaseService.query(
        'SELECT * FROM albums ORDER BY createdAt DESC',
        []
      );
      const albums: Album[] = [];
      if (resultSet.rowCount > 0) {
        resultSet.goToFirstRow();
        do {
          albums.push(AlbumService.mapResultSetToAlbum(resultSet));
        } while (resultSet.goToNextRow());
      }
      resultSet.close();
      return albums;
    } catch (error) {
      Logger.error('AlbumService', '获取所有相册失败: %{public}s', JSON.stringify(error));
      throw error;
    }
  }

  static async getAlbumById(id: number): Promise<Album | null> {
    try {
      const resultSet = await DatabaseService.query(
        'SELECT * FROM albums WHERE id = ?',
        [id]
      );
      if (resultSet.rowCount === 0) {
        resultSet.close();
        return null;
      }
      resultSet.goToFirstRow();
      const album = AlbumService.mapResultSetToAlbum(resultSet);
      resultSet.close();
      return album;
    } catch (error) {
      Logger.error('AlbumService', '获取相册失败: %{public}s', JSON.stringify(error));
      throw error;
    }
  }

  static async updateAlbum(id: number, updates: Partial<UpdateAlbumRequest>): Promise<Album> {
    const values: relationalStore.ValuesBucket = {
      updatedAt: Date.now()
    };

    if (updates.name !== undefined) {
      values['name'] = updates.name;
    }
    if (updates.description !== undefined) {
      values['description'] = updates.description;
    }
    if (updates.coverPhotoPath !== undefined) {
      values['coverPhotoPath'] = updates.coverPhotoPath;
    }

    try {
      const predicates = new relationalStore.RdbPredicates('albums');
      predicates.equalTo('id', id);
      const rowsAffected = await DatabaseService.update('albums', values, predicates);
      if (rowsAffected === 0) {
        throw new Error('相册未找到');
      }
      const album = await AlbumService.getAlbumById(id);
      if (!album) {
        throw new Error('更新相册失败');
      }
      Logger.info('AlbumService', '相册更新成功: %{public}d', id);
      return album;
    } catch (error) {
      Logger.error('AlbumService', '更新相册失败: %{public}s', JSON.stringify(error));
      throw error;
    }
  }

  static async deleteAlbum(id: number): Promise<void> {
    try {
      const predicates = new relationalStore.RdbPredicates('albums');
      predicates.equalTo('id', id);
      const rowsAffected = await DatabaseService.delete('albums', predicates);
      if (rowsAffected === 0) {
        throw new Error('相册未找到');
      }
      Logger.info('AlbumService', '相册删除成功: %{public}d', id);
    } catch (error) {
      Logger.error('AlbumService', '删除相册失败: %{public}s', JSON.stringify(error));
      throw error;
    }
  }

  static async setCoverPhoto(albumId: number, photoPath: string): Promise<void> {
    await AlbumService.updateAlbum(albumId, { coverPhotoPath: photoPath });
    Logger.info('AlbumService', '相册封面设置成功: %{public}d', albumId);
  }

  static async updatePhotoCount(albumId: number): Promise<void> {
    try {
      const resultSet = await DatabaseService.query(
        'SELECT COUNT(*) as count FROM photos WHERE albumId = ?',
        [albumId]
      );
      resultSet.goToFirstRow();
      const count = resultSet.getLong(resultSet.getColumnIndex('count'));
      resultSet.close();

      const values: relationalStore.ValuesBucket = {
        photoCount: count,
        updatedAt: Date.now()
      };
      const predicates = new relationalStore.RdbPredicates('albums');
      predicates.equalTo('id', albumId);
      await DatabaseService.update('albums', values, predicates);
    } catch (error) {
      Logger.error('AlbumService', '更新照片数量失败: %{public}s', JSON.stringify(error));
      throw error;
    }
  }

  private static mapResultSetToAlbum(resultSet: relationalStore.ResultSet): Album {
    return {
      id: resultSet.getLong(resultSet.getColumnIndex('id')),
      name: resultSet.getString(resultSet.getColumnIndex('name')),
      coverPhotoPath: resultSet.getString(resultSet.getColumnIndex('coverPhotoPath')),
      photoCount: resultSet.getLong(resultSet.getColumnIndex('photoCount')),
      description: resultSet.getString(resultSet.getColumnIndex('description')),
      createdAt: resultSet.getLong(resultSet.getColumnIndex('createdAt')),
      updatedAt: resultSet.getLong(resultSet.getColumnIndex('updatedAt'))
    };
  }
}
