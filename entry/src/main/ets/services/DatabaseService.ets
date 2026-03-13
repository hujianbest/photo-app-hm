import relationalStore from '@ohos.data.relationalStore';
import common from '@ohos.app.ability.common';
import { Logger } from '../common/utils/Logger';

export class DatabaseService {
  private static rdbStore: relationalStore.RdbStore | null = null;
  private static readonly DB_NAME = 'photo_app.db';
  private static readonly DB_VERSION = 1;

  static async init(context: common.Context): Promise<void> {
    const config: relationalStore.StoreConfig = {
      name: DatabaseService.DB_NAME,
      securityLevel: relationalStore.SecurityLevel.S1
    };

    try {
      DatabaseService.rdbStore = await relationalStore.getRdbStore(context, config);
      await DatabaseService.createTables();
      Logger.info('DatabaseService', '数据库初始化成功');
    } catch (error) {
      Logger.error('DatabaseService', '数据库初始化失败: %{public}s', JSON.stringify(error));
      throw error;
    }
  }

  private static async createTables(): Promise<void> {
    if (!DatabaseService.rdbStore) {
      throw new Error('数据库未初始化');
    }

    // 创建相册表
    await DatabaseService.rdbStore.executeSql(`
      CREATE TABLE IF NOT EXISTS albums (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        coverPhotoPath TEXT DEFAULT '',
        photoCount INTEGER DEFAULT 0,
        description TEXT DEFAULT '',
        createdAt INTEGER NOT NULL,
        updatedAt INTEGER NOT NULL
      )
    `);

    // 创建照片表
    await DatabaseService.rdbStore.executeSql(`
      CREATE TABLE IF NOT EXISTS photos (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        albumId INTEGER NOT NULL,
        originalPath TEXT NOT NULL,
        thumbnailPath TEXT DEFAULT '',
        width INTEGER DEFAULT 0,
        height INTEGER DEFAULT 0,
        size INTEGER DEFAULT 0,
        takenAt INTEGER DEFAULT 0,
        location TEXT DEFAULT '',
        tags TEXT DEFAULT '[]',
        createdAt INTEGER NOT NULL,
        FOREIGN KEY (albumId) REFERENCES albums(id) ON DELETE CASCADE
      )
    `);

    // 创建标签表
    await DatabaseService.rdbStore.executeSql(`
      CREATE TABLE IF NOT EXISTS tags (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL UNIQUE,
        color TEXT DEFAULT '#1890FF',
        photoCount INTEGER DEFAULT 0
      )
    `);

    // 创建索引
    await DatabaseService.rdbStore.executeSql('CREATE INDEX IF NOT EXISTS idx_photos_albumId ON photos(albumId)');
    await DatabaseService.rdbStore.executeSql('CREATE INDEX IF NOT EXISTS idx_photos_takenAt ON photos(takenAt)');
    await DatabaseService.rdbStore.executeSql('CREATE INDEX IF NOT EXISTS idx_tags_name ON tags(name)');

    Logger.info('DatabaseService', '数据表创建成功');
  }

  static async query(sql: string, args: relationalStore.ValuesBucket[]): Promise<relationalStore.ResultSet> {
    if (!DatabaseService.rdbStore) {
      throw new Error('数据库未初始化');
    }

    try {
      return await DatabaseService.rdbStore.querySql(sql, args);
    } catch (error) {
      Logger.error('DatabaseService', '查询失败: %{public}s', JSON.stringify(error));
      throw error;
    }
  }

  static async insert(tableName: string, values: relationalStore.ValuesBucket): Promise<number> {
    if (!DatabaseService.rdbStore) {
      throw new Error('数据库未初始化');
    }

    try {
      return await DatabaseService.rdbStore.insert(tableName, values);
    } catch (error) {
      Logger.error('DatabaseService', '插入失败: %{public}s', JSON.stringify(error));
      throw error;
    }
  }

  static async update(tableName: string, values: relationalStore.ValuesBucket, predicates: relationalStore.RdbPredicates): Promise<number> {
    if (!DatabaseService.rdbStore) {
      throw new Error('数据库未初始化');
    }

    try {
      return await DatabaseService.rdbStore.update(values, predicates);
    } catch (error) {
      Logger.error('DatabaseService', '更新失败: %{public}s', JSON.stringify(error));
      throw error;
    }
  }

  static async delete(tableName: string, predicates: relationalStore.RdbPredicates): Promise<number> {
    if (!DatabaseService.rdbStore) {
      throw new Error('数据库未初始化');
    }

    try {
      return await DatabaseService.rdbStore.delete(predicates);
    } catch (error) {
      Logger.error('DatabaseService', '删除失败: %{public}s', JSON.stringify(error));
      throw error;
    }
  }
}
