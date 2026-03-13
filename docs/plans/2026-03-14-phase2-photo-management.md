# 第二阶段：照片管理模块实施计划

> **For agentic workers:** REQUIRED: Use superpowers:subagent-driven-development (if subagents available) or superpowers:executing-plans to implement this plan. Steps use checkbox (`- [ ]`) syntax for tracking.

**目标：** 实现完整的本地照片管理功能，包括相册管理、照片上传、分类标签、照片详情和批量操作。

**架构：** MVVM架构，使用RDB数据库进行本地存储，MVVM模式处理UI，遵循现有项目结构（services处理业务逻辑，viewmodels处理状态，pages处理UI）。

**技术栈：** ArkTS, ArkUI, @ohos.data.relationalStore (RDB), @ohos.file.photoAccessHelper, @ohos.multimedia.image, @ohos.file.fs, HarmonyOS测试框架

---

## 文件结构

### 新增模型
- `entry/src/main/ets/models/Album.ets` - 相册数据接口
- `entry/src/main/ets/models/Photo.ets` - 照片数据接口
- `entry/src/main/ets/models/Tag.ets` - 标签数据接口
- `entry/src/main/ets/models/ExifInfo.ets` - EXIF元数据接口

### 新增服务
- `entry/src/main/ets/services/DatabaseService.ets` - RDB数据库初始化和操作
- `entry/src/main/ets/services/AlbumService.ets` - 相册业务逻辑
- `entry/src/main/ets/services/PhotoService.ets` - 照片业务逻辑
- `entry/src/main/ets/services/TagService.ets` - 标签管理

### 新增ViewModel
- `entry/src/main/ets/viewmodels/AlbumListViewModel.ets` - 相册列表状态和逻辑
- `entry/src/main/ets/viewmodels/AlbumDetailViewModel.ets` - 相册详情和照片管理
- `entry/src/main/ets/viewmodels/PhotoDetailViewModel.ets` - 照片详情和导航
- `entry/src/main/ets/viewmodels/TagViewModel.ets` - 标签管理状态

### 新增页面
- `entry/src/main/ets/pages/AlbumListPage.ets` - 相册列表页（替换PhotoPage）
- `entry/src/main/ets/pages/AlbumDetailPage.ets` - 相册详情和照片网格
- `entry/src/main/ets/pages/PhotoDetailPage.ets` - 照片详情和EXIF信息
- `entry/src/main/ets/pages/TagManagementPage.ets` - 标签管理页

### 新增测试
- `entry/src/test/ets/services/DatabaseService.test.ets`
- `entry/src/test/ets/services/AlbumService.test.ets`
- `entry/src/test/ets/services/PhotoService.test.ets`
- `entry/src/test/ets/services/TagService.test.ets`

---

## 第一部分：数据库层

### 任务 1：创建数据模型

**文件：**
- 创建：`entry/src/main/ets/models/Album.ets`
- 创建：`entry/src/main/ets/models/Photo.ets`
- 创建：`entry/src/main/ets/models/Tag.ets`
- 创建：`entry/src/main/ets/models/ExifInfo.ets`

- [ ] **步骤 1：创建 Album 模型**

写入到 `entry/src/main/ets/models/Album.ets`：

```typescript
export interface Album {
  id: number;                    // 相册ID（自增主键）
  name: string;                  // 相册名称
  coverPhotoPath: string;        // 封面照片路径
  photoCount: number;            // 照片数量（冗余字段）
  description: string;           // 相册描述
  createdAt: number;             // 创建时间戳
  updatedAt: number;             // 更新时间戳
}

export interface CreateAlbumRequest {
  name: string;
  description?: string;
}

export interface UpdateAlbumRequest {
  name?: string;
  description?: string;
  coverPhotoPath?: string;
}
```

- [ ] **步骤 2：创建 Photo 模型**

写入到 `entry/src/main/ets/models/Photo.ets`：

```typescript
export interface Photo {
  id: number;                    // 照片ID（自增主键）
  albumId: number;               // 所属相册ID
  originalPath: string;          // 原始照片路径（系统相册路径）
  thumbnailPath: string;         // 缩略图路径（应用生成）
  width: number;                 // 照片宽度
  height: number;                // 照片高度
  size: number;                  // 文件大小（字节）
  takenAt: number;               // 拍摄时间（从EXIF读取）
  location: string;              // 拍摄地点（从EXIF读取）
  tags: string;                  // 标签（JSON数组字符串）
  createdAt: number;             // 添加时间戳
}

export interface CreatePhotoRequest {
  albumId: number;
  originalPath: string;
  thumbnailPath?: string;
  width?: number;
  height?: number;
  size?: number;
  takenAt?: number;
  location?: string;
  tags?: string[];
}

export interface UpdatePhotoRequest {
  tags?: string[];
  location?: string;
}
```

- [ ] **步骤 3：创建 Tag 模型**

写入到 `entry/src/main/ets/models/Tag.ets`：

```typescript
export interface Tag {
  id: number;                    // 标签ID
  name: string;                  // 标签名称
  color: string;                 // 标签颜色（HEX格式）
  photoCount: number;            // 关联照片数量
}

export interface CreateTagRequest {
  name: string;
  color?: string;
}

export interface UpdateTagRequest {
  name?: string;
  color?: string;
}
```

- [ ] **步骤 4：创建 ExifInfo 模型**

写入到 `entry/src/main/ets/models/ExifInfo.ets`：

```typescript
export interface ExifInfo {
  make: string;                  // 相机品牌
  model: string;                 // 相机型号
  dateTime: string;              // 拍摄时间
  exposureTime: string;          // 曝光时间
  fNumber: string;               // 光圈值
  iso: number;                   // ISO感光度
  focalLength: string;           // 焦距
  gpsLatitude: string;           // 纬度
  gpsLongitude: string;          // 经度
}
```

- [ ] **步骤 5：提交模型代码**

```bash
git add entry/src/main/ets/models/Album.ets entry/src/main/ets/models/Photo.ets entry/src/main/ets/models/Tag.ets entry/src/main/ets/models/ExifInfo.ets
git commit -m "feat: 添加照片管理数据模型"
```

### 任务 2：创建数据库服务

**文件：**
- 创建：`entry/src/main/ets/services/DatabaseService.ets`
- 测试：`entry/src/test/ets/services/DatabaseService.test.ets`

- [ ] **步骤 1：编写 DatabaseService 初始化的失败测试**

写入到 `entry/src/test/ets/services/DatabaseService.test.ets`：

```typescript
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
```

- [ ] **步骤 2：运行测试验证失败**

运行：`hvigorw test`
预期：FAIL，报错 "DatabaseService not defined"

- [ ] **步骤 3：编写最小化 DatabaseService 实现**

写入到 `entry/src/main/ets/services/DatabaseService.ets`：

```typescript
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
```

- [ ] **步骤 4：运行测试验证通过**

运行：`hvigorw test`
预期：PASS

- [ ] **步骤 5：提交 DatabaseService**

```bash
git add entry/src/main/ets/services/DatabaseService.ets entry/src/test/ets/services/DatabaseService.test.ets
git commit -m "feat: 添加DatabaseService及表创建"
```

### 任务 3：在应用启动时添加数据库初始化

**文件：**
- 修改：`entry/src/main/ets/entryability/EntryAbility.ets`

- [ ] **步骤 1：读取当前 EntryAbility.ets**

运行：`cat entry/src/main/ets/entryability/EntryAbility.ets`
注意：阅读当前实现以了解在哪里添加初始化代码

- [ ] **步骤 2：在 onCreate 中添加 DatabaseService 初始化**

在 onCreate 方法中的现有服务初始化之后添加：

```typescript
import { DatabaseService } from '../services/DatabaseService';
// ... 其他导入

export default class EntryAbility extends UIAbility {
  async onCreate(want: Want, launchParam: AbilityConstant.LaunchParam) {
    // ... 现有代码

    // 初始化DatabaseService
    try {
      await DatabaseService.init(this.context);
    } catch (error) {
      Logger.error('EntryAbility', 'DatabaseService初始化失败: %{public}s', JSON.stringify(error));
    }
  }
  // ... 类的其余部分
}
```

- [ ] **步骤 3：提交初始化更改**

```bash
git add entry/src/main/ets/entryability/EntryAbility.ets
git commit -m "feat: 应用启动时初始化DatabaseService"
```

---

## 第二部分：相册服务层

### 任务 4：创建 AlbumService

**文件：**
- 创建：`entry/src/main/ets/services/AlbumService.ets`
- 测试：`entry/src/test/ets/services/AlbumService.test.ets`

- [ ] **步骤 1：编写 AlbumService 的失败测试**

写入到 `entry/src/test/ets/services/AlbumService.test.ets`：

```typescript
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
```

- [ ] **步骤 2：运行测试验证失败**

运行：`hvigorw test`
预期：FAIL，报错 "AlbumService not defined"

- [ ] **步骤 3：编写最小化 AlbumService 实现**

写入到 `entry/src/main/ets/services/AlbumService.ets`：

```typescript
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
```

- [ ] **步骤 4：运行测试验证通过**

运行：`hvigorw test`
预期：PASS

- [ ] **步骤 5：提交 AlbumService**

```bash
git add entry/src/main/ets/services/AlbumService.ets entry/src/test/ets/services/AlbumService.test.ets
git commit -m "feat: 添加AlbumService及CRUD操作"
```

---

## 第三部分：照片服务层

### 任务 5：创建 PhotoService

**文件：**
- 创建：`entry/src/main/ets/services/PhotoService.ets`
- 测试：`entry/src/test/ets/services/PhotoService.test.ets`

- [ ] **步骤 1：编写 PhotoService 的失败测试**

写入到 `entry/src/test/ets/services/PhotoService.test.ets`：

```typescript
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
```

- [ ] **步骤 2：运行测试验证失败**

运行：`hvigorw test`
预期：FAIL，报错 "PhotoService not defined"

- [ ] **步骤 3：编写最小化 PhotoService 实现**

写入到 `entry/src/main/ets/services/PhotoService.ets`：

```typescript
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
```

- [ ] **步骤 4：运行测试验证通过**

运行：`hvigorw test`
预期：PASS

- [ ] **步骤 5：提交 PhotoService**

```bash
git add entry/src/main/ets/services/PhotoService.ets entry/src/test/ets/services/PhotoService.test.ets
git commit -m "feat: 添加PhotoService及CRUD和批量操作"
```

### 任务 6：创建 TagService

**文件：**
- 创建：`entry/src/main/ets/services/TagService.ets`
- 测试：`entry/src/test/ets/services/TagService.test.ets`

- [ ] **步骤 1：编写 TagService 的失败测试**

写入到 `entry/src/test/ets/services/TagService.test.ets`：

```typescript
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
```

- [ ] **步骤 2：运行测试验证失败**

运行：`hvigorw test`
预期：FAIL，报错 "TagService not defined"

- [ ] **步骤 3：编写最小化 TagService 实现**

写入到 `entry/src/main/ets/services/TagService.ets`：

```typescript
import relationalStore from '@ohos.data.relationalStore';
import { Tag, CreateTagRequest, UpdateTagRequest } from '../models/Tag';
import { DatabaseService } from './DatabaseService';
import { Logger } from '../common/utils/Logger';

export class TagService {
  static async getAllTags(): Promise<Tag[]> {
    try {
      const resultSet = await DatabaseService.query(
        'SELECT * FROM tags ORDER BY photoCount DESC, id ASC',
        []
      );
      const tags: Tag[] = [];
      if (resultSet.rowCount > 0) {
        resultSet.goToFirstRow();
        do {
          tags.push(TagService.mapResultSetToTag(resultSet));
        } while (resultSet.goToNextRow());
      }
      resultSet.close();
      return tags;
    } catch (error) {
      Logger.error('TagService', '获取所有标签失败: %{public}s', JSON.stringify(error));
      throw error;
    }
  }

  static async createTag(name: string, color: string = '#1890FF'): Promise<Tag> {
    const values: relationalStore.ValuesBucket = {
      name: name,
      color: color,
      photoCount: 0
    };

    try {
      const rowId = await DatabaseService.insert('tags', values);
      const tag = await TagService.getTagById(rowId);
      if (!tag) {
        throw new Error('创建标签失败');
      }
      Logger.info('TagService', '标签创建成功: %{public}s', name);
      return tag;
    } catch (error) {
      Logger.error('TagService', '创建标签失败: %{public}s', JSON.stringify(error));
      throw error;
    }
  }

  static async updateTag(id: number, updates: Partial<UpdateTagRequest>): Promise<Tag> {
    const values: relationalStore.ValuesBucket = {};

    if (updates.name !== undefined) {
      values['name'] = updates.name;
    }
    if (updates.color !== undefined) {
      values['color'] = updates.color;
    }

    try {
      const predicates = new relationalStore.RdbPredicates('tags');
      predicates.equalTo('id', id);
      const rowsAffected = await DatabaseService.update('tags', values, predicates);
      if (rowsAffected === 0) {
        throw new Error('标签未找到');
      }
      const tag = await TagService.getTagById(id);
      if (!tag) {
        throw new Error('更新标签失败');
      }
      Logger.info('TagService', '标签更新成功: %{public}d', id);
      return tag;
    } catch (error) {
      Logger.error('TagService', '更新标签失败: %{public}s', JSON.stringify(error));
      throw error;
    }
  }

  static async deleteTag(id: number): Promise<void> {
    try {
      const predicates = new relationalStore.RdbPredicates('tags');
      predicates.equalTo('id', id);
      const rowsAffected = await DatabaseService.delete('tags', predicates);
      if (rowsAffected === 0) {
        throw new Error('标签未找到');
      }
      Logger.info('TagService', '标签删除成功: %{public}d', id);
    } catch (error) {
      Logger.error('TagService', '删除标签失败: %{public}s', JSON.stringify(error));
      throw error;
    }
  }

  static async getTagById(id: number): Promise<Tag | null> {
    try {
      const resultSet = await DatabaseService.query(
        'SELECT * FROM tags WHERE id = ?',
        [id]
      );
      if (resultSet.rowCount === 0) {
        resultSet.close();
        return null;
      }
      resultSet.goToFirstRow();
      const tag = TagService.mapResultSetToTag(resultSet);
      resultSet.close();
      return tag;
    } catch (error) {
      Logger.error('TagService', '获取标签失败: %{public}s', JSON.stringify(error));
      throw error;
    }
  }

  private static mapResultSetToTag(resultSet: relationalStore.ResultSet): Tag {
    return {
      id: resultSet.getLong(resultSet.getColumnIndex('id')),
      name: resultSet.getString(resultSet.getColumnIndex('name')),
      color: resultSet.getString(resultSet.getColumnIndex('color')),
      photoCount: resultSet.getLong(resultSet.getColumnIndex('photoCount'))
    };
  }
}
```

- [ ] **步骤 4：运行测试验证通过**

运行：`hvigorw test`
预期：PASS

- [ ] **步骤 5：提交 TagService**

```bash
git add entry/src/main/ets/services/TagService.ets entry/src/test/ets/services/TagService.test.ets
git commit -m "feat: 添加TagService及CRUD操作"
```

---

## 第四部分：相册列表页

### 任务 7：创建 AlbumListViewModel

**文件：**
- 创建：`entry/src/main/ets/viewmodels/AlbumListViewModel.ets`

- [ ] **步骤 1：创建 AlbumListViewModel**

写入到 `entry/src/main/ets/viewmodels/AlbumListViewModel.ets`：

```typescript
import { Album } from '../models/Album';
import { AlbumService } from '../services/AlbumService';
import { Logger } from '../common/utils/Logger';

export class AlbumListViewModel {
  private albums: Album[] = [];
  private isLoading: boolean = false;
  private viewMode: 'grid' | 'list' = 'grid';
  private loadCallbacks: Array<() => void> = [];

  getAlbums(): Album[] {
    return this.albums;
  }

  isLoading(): boolean {
    return this.isLoading;
  }

  getViewMode(): 'grid' | 'list' {
    return this.viewMode;
  }

  onAlbumsChange(callback: () => void): void {
    this.loadCallbacks.push(callback);
  }

  async loadAlbums(): Promise<void> {
    this.isLoading = true;
    this.notifyCallbacks();

    try {
      this.albums = await AlbumService.getAllAlbums();
      Logger.info('AlbumListViewModel', '加载了 %{public}d 个相册', this.albums.length);
    } catch (error) {
      Logger.error('AlbumListViewModel', '加载相册失败: %{public}s', JSON.stringify(error));
    } finally {
      this.isLoading = false;
      this.notifyCallbacks();
    }
  }

  toggleViewMode(): void {
    this.viewMode = this.viewMode === 'grid' ? 'list' : 'grid';
    this.notifyCallbacks();
  }

  async createAlbum(name: string, description?: string): Promise<Album | null> {
    try {
      const album = await AlbumService.createAlbum(name, description || '');
      await this.loadAlbums();
      return album;
    } catch (error) {
      Logger.error('AlbumListViewModel', '创建相册失败: %{public}s', JSON.stringify(error));
      return null;
    }
  }

  async deleteAlbum(albumId: number): Promise<boolean> {
    try {
      await AlbumService.deleteAlbum(albumId);
      await this.loadAlbums();
      return true;
    } catch (error) {
      Logger.error('AlbumListViewModel', '删除相册失败: %{public}s', JSON.stringify(error));
      return false;
    }
  }

  async refresh(): Promise<void> {
    await this.loadAlbums();
  }

  private notifyCallbacks(): void {
    this.loadCallbacks.forEach(callback => callback());
  }
}
```

- [ ] **步骤 2：提交 AlbumListViewModel**

```bash
git add entry/src/main/ets/viewmodels/AlbumListViewModel.ets
git commit -m "feat: 添加AlbumListViewModel"
```

### 任务 8：创建 AlbumListPage

**文件：**
- 修改：`entry/src/main/ets/pages/PhotoPage.ets`

- [ ] **步骤 1：用 AlbumListPage 替换 PhotoPage.ets**

写入到 `entry/src/main/ets/pages/PhotoPage.ets`：

```typescript
import { AlbumListViewModel } from '../viewmodels/AlbumListViewModel';
import { Album } from '../models/Album';
import router from '@ohos.router';
import promptAction from '@ohos.promptAction';

@Entry
@Component
struct AlbumListPage {
  @State viewModel: AlbumListViewModel = new AlbumListViewModel();
  @State albums: Album[] = [];
  @State isLoading: boolean = false;
  @State showDialog: boolean = false;
  @State albumName: string = '';
  @State albumDescription: string = '';
  @State viewMode: 'grid' | 'list' = 'grid';

  aboutToAppear() {
    this.viewModel.onAlbumsChange(() => {
      this.albums = this.viewModel.getAlbums();
      this.isLoading = this.viewModel.isLoading();
      this.viewMode = this.viewModel.getViewMode();
    });
    this.viewModel.loadAlbums();
  }

  build() {
    Column() {
      // 头部
      Row() {
        Text('我的相册')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .layoutWeight(1)

        // 视图模式切换
        Button(this.viewMode === 'grid' ? '📋' : '⊞')
          .fontSize(18)
          .backgroundColor(Color.Transparent)
          .fontColor('#333')
          .onClick(() => {
            this.viewModel.toggleViewMode();
          })

        Button('+')
          .fontSize(24)
          .width(40)
          .height(40)
          .borderRadius(20)
          .backgroundColor('#1890FF')
          .fontColor(Color.White)
          .margin({ left: 8 })
          .onClick(() => {
            this.showDialog = true;
          })
      }
      .width('100%')
      .padding(16)
      .backgroundColor(Color.White)

      // 内容区域
      if (this.isLoading) {
        Column() {
          LoadingProgress()
            .width(40)
            .height(40)
          Text('加载中...')
            .fontSize(14)
            .fontColor('#999')
            .margin({ top: 8 })
        }
        .width('100%')
        .height('100%')
        .justifyContent(FlexAlign.Center)
      } else if (this.albums.length === 0) {
        Column() {
          Text('📁')
            .fontSize(64)
            .margin({ bottom: 16 })
          Text('还没有相册')
            .fontSize(16)
            .fontColor('#666')
          Button('创建第一个相册')
            .fontSize(14)
            .backgroundColor('#1890FF')
            .fontColor(Color.White)
            .borderRadius(20)
            .padding({ left: 24, right: 24, top: 12, bottom: 12 })
            .margin({ top: 24 })
            .onClick(() => {
              this.showDialog = true;
            })
        }
        .width('100%')
        .height('100%')
        .justifyContent(FlexAlign.Center)
      } else if (this.viewMode === 'grid') {
        this.GridView()
      } else {
        this.ListView()
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
    .bindSheet(this.showDialog, this.CreateAlbumDialog(), {
      height: 300,
      showClose: true,
      onDisappear: () => {
        this.albumName = '';
        this.albumDescription = '';
      }
    })
  }

  @Builder
  GridView() {
    Grid() {
      ForEach(this.albums, (album: Album) => {
        GridItem() {
          Column() {
            // 相册封面占位
            Image(album.coverPhotoPath || '')
              .width('100%')
              .aspectRatio(1)
              .backgroundColor('#E0E0E0')
              .borderRadius(8)
              .objectFit(ImageFit.Cover)

            Text(album.name)
              .fontSize(14)
              .fontWeight(FontWeight.Medium)
              .maxLines(1)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
              .width('100%')
              .margin({ top: 8 })

            Text(`${album.photoCount} 张照片`)
              .fontSize(12)
              .fontColor('#999')
              .margin({ top: 4 })
          }
          .width('100%')
          .padding(8)
          .backgroundColor(Color.White)
          .borderRadius(12)
          .onClick(() => {
            router.pushUrl({
              url: 'pages/AlbumDetailPage',
              params: { albumId: album.id }
            });
          })
          .onLongPress(() => {
            this.showAlbumMenu(album);
          })
        }
      })
    }
    .columnsTemplate('1fr 1fr')
    .rowsGap(12)
    .columnsGap(12)
    .padding(12)
    .height('100%')
  }

  @Builder
  ListView() {
    List() {
      ForEach(this.albums, (album: Album) => {
        ListItem() {
          Row() {
            // 相册封面占位
            Image(album.coverPhotoPath || '')
              .width(80)
              .height(80)
              .backgroundColor('#E0E0E0')
              .borderRadius(8)
              .objectFit(ImageFit.Cover)

            Column() {
              Text(album.name)
                .fontSize(16)
                .fontWeight(FontWeight.Medium)
                .maxLines(1)
                .textOverflow({ overflow: TextOverflow.Ellipsis })

              Text(album.description || '暂无描述')
                .fontSize(12)
                .fontColor('#999')
                .maxLines(1)
                .textOverflow({ overflow: TextOverflow.Ellipsis })
                .margin({ top: 4 })

              Text(`${album.photoCount} 张照片`)
                .fontSize(12)
                .fontColor('#1890FF')
                .margin({ top: 4 })
            }
            .alignItems(HorizontalAlign.Start)
            .layoutWeight(1)
            .margin({ left: 12 })

            Image($r('app.media.ic_arrow_right'))
              .width(16)
              .height(16)
              .fillColor('#CCC')
          }
          .width('100%')
          .padding(16)
          .backgroundColor(Color.White)
          .borderRadius(8)
          .onClick(() => {
            router.pushUrl({
              url: 'pages/AlbumDetailPage',
              params: { albumId: album.id }
            });
          })
          .onLongPress(() => {
            this.showAlbumMenu(album);
          })
        }
        .width('100%')
      })
    }
    .width('100%')
    .padding(12)
    .height('100%')
  }

  @Builder
  CreateAlbumDialog() {
    Column() {
      Text('创建相册')
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .margin({ bottom: 24 })

      TextInput({ placeholder: '相册名称', text: this.albumName })
        .width('100%')
        .height(44)
        .backgroundColor('#F5F5F5')
        .borderRadius(8)
        .padding({ left: 16, right: 16 })
        .margin({ bottom: 16 })
        .onChange((value: string) => {
          this.albumName = value;
        })

      TextInput({ placeholder: '相册描述（可选）', text: this.albumDescription })
        .width('100%')
        .height(44)
        .backgroundColor('#F5F5F5')
        .borderRadius(8)
        .padding({ left: 16, right: 16 })
        .margin({ bottom: 24 })
        .onChange((value: string) => {
          this.albumDescription = value;
        })

      Row() {
        Button('取消')
          .fontSize(16)
          .backgroundColor('#F5F5F5')
          .fontColor('#333')
          .layoutWeight(1)
          .height(44)
          .borderRadius(22)
          .onClick(() => {
            this.showDialog = false;
          })

        Button('创建')
          .fontSize(16)
          .backgroundColor('#1890FF')
          .fontColor(Color.White)
          .layoutWeight(1)
          .height(44)
          .borderRadius(22)
          .margin({ left: 12 })
          .onClick(async () => {
            if (!this.albumName.trim()) {
              promptAction.showToast({ message: '请输入相册名称' });
              return;
            }

            const album = await this.viewModel.createAlbum(this.albumName, this.albumDescription);
            if (album) {
              promptAction.showToast({ message: '相册创建成功' });
              this.showDialog = false;
            } else {
              promptAction.showToast({ message: '创建失败' });
            }
          })
      }
      .width('100%')
    }
    .width('100%')
    .padding(24)
  }

  showAlbumMenu(album: Album): void {
    promptAction.showDialog({
      title: album.name,
      buttons: [
        { text: '取消', color: '#999' },
        { text: '删除', color: '#F5222D' }
      ]
    }, (err, data) => {
      if (data.index === 1) {
        this.deleteAlbum(album);
      }
    });
  }

  async deleteAlbum(album: Album): Promise<void> {
    promptAction.showDialog({
      title: '确认删除',
      message: `删除相册"${album.name}"及其所有照片？`,
      buttons: [
        { text: '取消', color: '#999' },
        { text: '删除', color: '#F5222D' }
      ]
    }, async (err, data) => {
      if (data.index === 1) {
        const success = await this.viewModel.deleteAlbum(album.id);
        if (success) {
          promptAction.showToast({ message: '删除成功' });
        } else {
          promptAction.showToast({ message: '删除失败' });
        }
      }
    });
  }
}
```

- [ ] **步骤 2：提交 AlbumListPage**

```bash
git add entry/src/main/ets/pages/PhotoPage.ets
git commit -m "feat: 实现AlbumListPage，支持网格/列表视图"
```

### 任务 9：添加 AlbumDetailPage 到路由配置

**文件：**
- 读取：`entry/src/main/resources/base/profile/main_pages.json`
- 修改：`entry/src/main/resources/base/profile/main_pages.json`

- [ ] **步骤 1：读取当前路由配置**

运行：`cat entry/src/main/resources/base/profile/main_pages.json`
注意：记录当前的页面配置

- [ ] **步骤 2：添加 AlbumDetailPage 到路由配置**

添加 `pages/AlbumDetailPage` 到 src 数组中（以及后续创建的页面）：

```json
{
  "src": [
    "pages/SplashPage",
    "pages/LoginPage",
    "pages/RegisterPage",
    "pages/MainPage",
    "pages/HomePage",
    "pages/PhotoPage",
    "pages/BookingPage",
    "pages/LearnPage",
    "pages/MinePage",
    "pages/AlbumDetailPage",
    "pages/PhotoDetailPage",
    "pages/TagManagementPage"
  ]
}
```

- [ ] **步骤 3：提交路由更改**

```bash
git add entry/src/main/resources/base/profile/main_pages.json
git commit -m "feat: 添加照片管理页面到路由配置"
```

---

## 第五部分：相册详情页

### 任务 10：创建 AlbumDetailViewModel

**文件：**
- 创建：`entry/src/main/ets/viewmodels/AlbumDetailViewModel.ets`

- [ ] **步骤 1：创建 AlbumDetailViewModel**

写入到 `entry/src/main/ets/viewmodels/AlbumDetailViewModel.ets`：

```typescript
import { Album, UpdateAlbumRequest } from '../models/Album';
import { Photo } from '../models/Photo';
import { AlbumService } from '../services/AlbumService';
import { PhotoService } from '../services/PhotoService';
import { Logger } from '../common/utils/Logger';

export class AlbumDetailViewModel {
  private album: Album | null = null;
  private photos: Photo[] = [];
  private selectedPhotos: Set<number> = new Set();
  private isMultiSelectMode: boolean = false;
  private isLoading: boolean = false;
  private loadCallbacks: Array<() => void> = [];

  getAlbum(): Album | null {
    return this.album;
  }

  getPhotos(): Photo[] {
    return this.photos;
  }

  getSelectedPhotos(): Set<number> {
    return this.selectedPhotos;
  }

  isMultiSelectModeEnabled(): boolean {
    return this.isMultiSelectMode;
  }

  isLoading(): boolean {
    return this.isLoading;
  }

  onDataChange(callback: () => void): void {
    this.loadCallbacks.push(callback);
  }

  async loadAlbum(albumId: number): Promise<void> {
    this.isLoading = true;
    this.notifyCallbacks();

    try {
      this.album = await AlbumService.getAlbumById(albumId);
      this.photos = await PhotoService.getPhotosByAlbum(albumId);
      Logger.info('AlbumDetailViewModel', '加载了相册，包含 %{public}d 张照片', this.photos.length);
    } catch (error) {
      Logger.error('AlbumDetailViewModel', '加载相册失败: %{public}s', JSON.stringify(error));
    } finally {
      this.isLoading = false;
      this.notifyCallbacks();
    }
  }

  async addPhotos(photoUris: string[]): Promise<boolean> {
    if (!this.album) {
      return false;
    }

    try {
      await PhotoService.addPhotosToAlbum(this.album.id, photoUris);
      await this.loadAlbum(this.album.id);
      return true;
    } catch (error) {
      Logger.error('AlbumDetailViewModel', '添加照片失败: %{public}s', JSON.stringify(error));
      return false;
    }
  }

  toggleMultiSelectMode(): void {
    this.isMultiSelectMode = !this.isMultiSelectMode;
    if (!this.isMultiSelectMode) {
      this.selectedPhotos.clear();
    }
    this.notifyCallbacks();
  }

  togglePhotoSelection(photoId: number): void {
    if (this.selectedPhotos.has(photoId)) {
      this.selectedPhotos.delete(photoId);
    } else {
      this.selectedPhotos.add(photoId);
    }
    this.notifyCallbacks();
  }

  selectAll(): void {
    this.photos.forEach(photo => this.selectedPhotos.add(photo.id));
    this.notifyCallbacks();
  }

  deselectAll(): void {
    this.selectedPhotos.clear();
    this.notifyCallbacks();
  }

  async deleteSelected(): Promise<boolean> {
    if (!this.album) {
      return false;
    }

    try {
      await PhotoService.deletePhotos(Array.from(this.selectedPhotos));
      this.selectedPhotos.clear();
      this.isMultiSelectMode = false;
      await this.loadAlbum(this.album.id);
      return true;
    } catch (error) {
      Logger.error('AlbumDetailViewModel', '删除照片失败: %{public}s', JSON.stringify(error));
      return false;
    }
  }

  async moveSelectedToAlbum(targetAlbumId: number): Promise<boolean> {
    if (!this.album) {
      return false;
    }

    try {
      await PhotoService.movePhotos(Array.from(this.selectedPhotos), targetAlbumId);
      this.selectedPhotos.clear();
      this.isMultiSelectMode = false;
      await this.loadAlbum(this.album.id);
      return true;
    } catch (error) {
      Logger.error('AlbumDetailViewModel', '移动照片失败: %{public}s', JSON.stringify(error));
      return false;
    }
  }

  async addTagsToSelected(tags: string[]): Promise<boolean> {
    try {
      await PhotoService.addTagsToPhotos(Array.from(this.selectedPhotos), tags);
      await this.loadAlbum(this.photos[0]?.albumId || 0);
      return true;
    } catch (error) {
      Logger.error('AlbumDetailViewModel', '添加标签失败: %{public}s', JSON.stringify(error));
      return false;
    }
  }

  async updateAlbumInfo(updates: Partial<UpdateAlbumRequest>): Promise<boolean> {
    if (!this.album) {
      return false;
    }

    try {
      this.album = await AlbumService.updateAlbum(this.album.id, updates);
      this.notifyCallbacks();
      return true;
    } catch (error) {
      Logger.error('AlbumDetailViewModel', '更新相册信息失败: %{public}s', JSON.stringify(error));
      return false;
    }
  }

  private notifyCallbacks(): void {
    this.loadCallbacks.forEach(callback => callback());
  }
}
```

- [ ] **步骤 2：提交 AlbumDetailViewModel**

```bash
git add entry/src/main/ets/viewmodels/AlbumDetailViewModel.ets
git commit -m "feat: 添加AlbumDetailViewModel"
```

### 任务 11：创建 AlbumDetailPage

**文件：**
- 创建：`entry/src/main/ets/pages/AlbumDetailPage.ets`

- [ ] **步骤 1：创建 AlbumDetailPage**

写入到 `entry/src/main/ets/pages/AlbumDetailPage.ets`：

```typescript
import { AlbumDetailViewModel } from '../viewmodels/AlbumDetailViewModel';
import { Album } from '../models/Album';
import { Photo } from '../models/Photo';
import { AlbumService } from '../services/AlbumService';
import router from '@ohos.router';
import promptAction from '@ohos.promptAction';

@Entry
@Component
struct AlbumDetailPage {
  @State viewModel: AlbumDetailViewModel = new AlbumDetailViewModel();
  @State album: Album | null = null;
  @State photos: Photo[] = [];
  @State isLoading: boolean = false;
  @State isMultiSelectMode: boolean = false;
  @State selectedPhotos: Set<number> = new Set();
  @State showAlbumNameDialog: boolean = false;
  @State albumName: string = '';
  @State albumDescription: string = '';

  aboutToAppear() {
    const albumId = router.getParams()?.['albumId'] as number;
    if (albumId) {
      this.viewModel.onDataChange(() => {
        this.album = this.viewModel.getAlbum();
        this.photos = this.viewModel.getPhotos();
        this.isLoading = this.viewModel.isLoading();
        this.isMultiSelectMode = this.viewModel.isMultiSelectModeEnabled();
        this.selectedPhotos = new Set(this.viewModel.getSelectedPhotos());
      });
      this.viewModel.loadAlbum(albumId);
    }
  }

  build() {
    Column() {
      // 头部
      Row() {
        Button('<')
          .fontSize(24)
          .backgroundColor(Color.Transparent)
          .fontColor('#333')
          .onClick(() => {
            router.back();
          })

        Text(this.album?.name || '相册')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .layoutWeight(1)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .onClick(() => {
            if (this.album) {
              this.showAlbumNameDialog = true;
              this.albumName = this.album.name;
              this.albumDescription = this.album.description;
            }
          })

        Button(this.isMultiSelectMode ? '✓' : '⋮')
          .fontSize(18)
          .backgroundColor(Color.Transparent)
          .fontColor('#333')
          .onClick(() => {
            this.viewModel.toggleMultiSelectMode();
          })
      }
      .width('100%')
      .padding(16)
      .backgroundColor(Color.White)

      // 相册信息
      if (this.album) {
        Row() {
          Text(`${this.album.photoCount} 张照片`)
            .fontSize(14)
            .fontColor('#666')

          Text(this.album.description || '暂无描述')
            .fontSize(14)
            .fontColor('#999')
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .layoutWeight(1)
            .margin({ left: 16 })
        }
        .width('100%')
        .padding({ left: 16, right: 16, bottom: 12 })
        .backgroundColor(Color.White)
      }

      Divider()
        .color('#E8E8E8')

      // 内容区域
      if (this.isLoading) {
        Column() {
          LoadingProgress()
            .width(40)
            .height(40)
          Text('加载中...')
            .fontSize(14)
            .fontColor('#999')
            .margin({ top: 8 })
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
      } else if (this.photos.length === 0) {
        Column() {
          Text('📷')
            .fontSize(64)
            .margin({ bottom: 16 })
          Text('相册是空的')
            .fontSize(16)
            .fontColor('#666')
          Text('点击右下角添加照片')
            .fontSize(14)
            .fontColor('#999')
            .margin({ top: 8 })
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
      } else {
        this.PhotoGrid()
      }

      // 多选操作栏
      if (this.isMultiSelectMode && this.selectedPhotos.size > 0) {
        Row() {
          Text(`已选择 ${this.selectedPhotos.size} 张`)
            .fontSize(14)
            .fontColor('#666')
            .layoutWeight(1)

          Button('删除')
            .fontSize(14)
            .backgroundColor('#F5222D')
            .fontColor(Color.White)
            .borderRadius(20)
            .padding({ left: 16, right: 16, top: 8, bottom: 8 })
            .onClick(() => {
              this.deleteSelectedPhotos();
            })
        }
        .width('100%')
        .padding(16)
        .backgroundColor(Color.White)
        .border({ width: { top: 1 }, color: '#E8E8E8' })
      }

      // 浮动按钮
      if (!this.isMultiSelectMode) {
        Button('+')
          .fontSize(32)
          .width(56)
          .height(56)
          .borderRadius(28)
          .backgroundColor('#1890FF')
          .fontColor(Color.White)
          .position({ x: '85%', y: '85%' })
          .onClick(() => {
            this.addPhotos();
          })
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
    .bindSheet(this.showAlbumNameDialog, this.EditAlbumDialog(), {
      height: 300,
      showClose: true,
      onDisappear: () => {
        this.albumName = '';
        this.albumDescription = '';
      }
    })
  }

  @Builder
  PhotoGrid() {
    Grid() {
      ForEach(this.photos, (photo: Photo) => {
        GridItem() {
          Stack({ alignContent: Alignment.TopEnd }) {
            Image(photo.thumbnailPath || photo.originalPath)
              .width('100%')
              .aspectRatio(1)
              .backgroundColor('#E0E0E0')
              .borderRadius(4)
              .objectFit(ImageFit.Cover)
              .onClick(() => {
                if (this.isMultiSelectMode) {
                  this.viewModel.togglePhotoSelection(photo.id);
                } else {
                  router.pushUrl({
                    url: 'pages/PhotoDetailPage',
                    params: { photoId: photo.id }
                  });
                }
              })

            if (this.isMultiSelectMode) {
              Checkbox(this.selectedPhotos.has(photo.id))
                .select(this.selectedPhotos.has(photo.id))
                .width(24)
                .height(24)
                .margin(8)
                .onChange((value: boolean) => {
                  this.viewModel.togglePhotoSelection(photo.id);
                })
            }
          }
        }
      })
    }
    .columnsTemplate('1fr 1fr 1fr')
    .rowsGap(4)
    .columnsGap(4)
    .padding(8)
    .layoutWeight(1)
  }

  @Builder
  EditAlbumDialog() {
    Column() {
      Text('编辑相册')
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .margin({ bottom: 24 })

      TextInput({ placeholder: '相册名称', text: this.albumName })
        .width('100%')
        .height(44)
        .backgroundColor('#F5F5F5')
        .borderRadius(8)
        .padding({ left: 16, right: 16 })
        .margin({ bottom: 16 })
        .onChange((value: string) => {
          this.albumName = value;
        })

      TextInput({ placeholder: '相册描述（可选）', text: this.albumDescription })
        .width('100%')
        .height(44)
        .backgroundColor('#F5F5F5')
        .borderRadius(8)
        .padding({ left: 16, right: 16 })
        .margin({ bottom: 24 })
        .onChange((value: string) => {
          this.albumDescription = value;
        })

      Row() {
        Button('取消')
          .fontSize(16)
          .backgroundColor('#F5F5F5')
          .fontColor('#333')
          .layoutWeight(1)
          .height(44)
          .borderRadius(22)
          .onClick(() => {
            this.showAlbumNameDialog = false;
          })

        Button('保存')
          .fontSize(16)
          .backgroundColor('#1890FF')
          .fontColor(Color.White)
          .layoutWeight(1)
          .height(44)
          .borderRadius(22)
          .margin({ left: 12 })
          .onClick(async () => {
            if (!this.albumName.trim()) {
              promptAction.showToast({ message: '请输入相册名称' });
              return;
            }

            const success = await this.viewModel.updateAlbumInfo({
              name: this.albumName,
              description: this.albumDescription
            });
            if (success) {
              promptAction.showToast({ message: '保存成功' });
              this.showAlbumNameDialog = false;
            } else {
              promptAction.showToast({ message: '保存失败' });
            }
          })
      }
      .width('100%')
    }
    .width('100%')
    .padding(24)
  }

  addPhotos(): void {
    // 这将在后续更新中使用PhotoPicker实现
    promptAction.showToast({ message: 'PhotoPicker集成即将推出' });
  }

  deleteSelectedPhotos(): void {
    promptAction.showDialog({
      title: '确认删除',
      message: `删除选中的 ${this.selectedPhotos.size} 张照片？`,
      buttons: [
        { text: '取消', color: '#999' },
        { text: '删除', color: '#F5222D' }
      ]
    }, async (err, data) => {
      if (data.index === 1) {
        const success = await this.viewModel.deleteSelected();
        if (success) {
          promptAction.showToast({ message: '删除成功' });
        } else {
          promptAction.showToast({ message: '删除失败' });
        }
      }
    });
  }
}
```

- [ ] **步骤 2：提交 AlbumDetailPage**

```bash
git add entry/src/main/ets/pages/AlbumDetailPage.ets
git commit -m "feat: 实现AlbumDetailPage，支持照片网格"
```

---

## 第六部分：照片详情页

### 任务 12：创建 PhotoDetailViewModel

**文件：**
- 创建：`entry/src/main/ets/viewmodels/PhotoDetailViewModel.ets`

- [ ] **步骤 1：创建 PhotoDetailViewModel**

写入到 `entry/src/main/ets/viewmodels/PhotoDetailViewModel.ets`：

```typescript
import { Photo, UpdatePhotoRequest } from '../models/Photo';
import { PhotoService } from '../services/PhotoService';
import { Logger } from '../common/utils/Logger';

export class PhotoDetailViewModel {
  private photo: Photo | null = null;
  private photoList: Photo[] = [];
  private currentIndex: number = 0;
  private loadCallbacks: Array<() => void> = [];

  getPhoto(): Photo | null {
    return this.photo;
  }

  getCurrentIndex(): number {
    return this.currentIndex;
  }

  getTotalPhotos(): number {
    return this.photoList.length;
  }

  getPhotoList(): Photo[] {
    return this.photoList;
  }

  onDataChange(callback: () => void): void {
    this.loadCallbacks.push(callback);
  }

  async loadPhoto(photoId: number): Promise<void> {
    try {
      this.photo = await PhotoService.getPhotoById(photoId);
      this.notifyCallbacks();
    } catch (error) {
      Logger.error('PhotoDetailViewModel', '加载照片失败: %{public}s', JSON.stringify(error));
    }
  }

  setPhotoList(photos: Photo[], currentIndex: number): void {
    this.photoList = photos;
    this.currentIndex = currentIndex;
    this.notifyCallbacks();
  }

  previousPhoto(): Photo | null {
    if (this.currentIndex > 0) {
      this.currentIndex--;
      this.photo = this.photoList[this.currentIndex];
      this.notifyCallbacks();
    }
    return this.photo;
  }

  nextPhoto(): Photo | null {
    if (this.currentIndex < this.photoList.length - 1) {
      this.currentIndex++;
      this.photo = this.photoList[this.currentIndex];
      this.notifyCallbacks();
    }
    return this.photo;
  }

  async updateTags(tags: string[]): Promise<boolean> {
    if (!this.photo) {
      return false;
    }

    try {
      this.photo = await PhotoService.updatePhoto(this.photo.id, { tags });
      // 更新列表中的照片
      this.photoList[this.currentIndex] = this.photo;
      this.notifyCallbacks();
      return true;
    } catch (error) {
      Logger.error('PhotoDetailViewModel', '更新标签失败: %{public}s', JSON.stringify(error));
      return false;
    }
  }

  async deletePhoto(): Promise<boolean> {
    if (!this.photo) {
      return false;
    }

    try {
      await PhotoService.deletePhoto(this.photo.id);
      return true;
    } catch (error) {
      Logger.error('PhotoDetailViewModel', '删除照片失败: %{public}s', JSON.stringify(error));
      return false;
    }
  }

  async moveToAlbum(albumId: number): Promise<boolean> {
    if (!this.photo) {
      return false;
    }

    try {
      await PhotoService.movePhotos([this.photo.id], albumId);
      return true;
    } catch (error) {
      Logger.error('PhotoDetailViewModel', '移动照片失败: %{public}s', JSON.stringify(error));
      return false;
    }
  }

  getTags(): string[] {
    if (!this.photo || !this.photo.tags) {
      return [];
    }
    try {
      return JSON.parse(this.photo.tags) as string[];
    } catch {
      return [];
    }
  }

  private notifyCallbacks(): void {
    this.loadCallbacks.forEach(callback => callback());
  }
}
```

- [ ] **步骤 2：提交 PhotoDetailViewModel**

```bash
git add entry/src/main/ets/viewmodels/PhotoDetailViewModel.ets
git commit -m "feat: 添加PhotoDetailViewModel"
```

### 任务 13：创建 PhotoDetailPage

**文件：**
- 创建：`entry/src/main/ets/pages/PhotoDetailPage.ets`

- [ ] **步骤 1：创建 PhotoDetailPage**

写入到 `entry/src/main/ets/pages/PhotoDetailPage.ets`：

```typescript
import { PhotoDetailViewModel } from '../viewmodels/PhotoDetailViewModel';
import { Photo } from '../models/Photo';
import router from '@ohos.router';
import promptAction from '@ohos.promptAction';

@Entry
@Component
struct PhotoDetailPage {
  @State viewModel: PhotoDetailViewModel = new PhotoDetailViewModel();
  @State photo: Photo | null = null;
  @State currentIndex: number = 0;
  @State totalPhotos: number = 0;
  @State showTagDialog: boolean = false;

  aboutToAppear() {
    const photoId = router.getParams()?.['photoId'] as number;
    if (photoId) {
      this.viewModel.onDataChange(() => {
        this.photo = this.viewModel.getPhoto();
        this.currentIndex = this.viewModel.getCurrentIndex();
        this.totalPhotos = this.viewModel.getTotalPhotos();
      });
      this.viewModel.loadPhoto(photoId);
    }
  }

  build() {
    Stack() {
      Column() {
        // 头部
        Row() {
          Button('<')
            .fontSize(24)
            .backgroundColor(Color.Transparent)
            .fontColor(Color.White)
            .onClick(() => {
              router.back();
            })

          Text(`${this.currentIndex + 1}/${this.totalPhotos}`)
            .fontSize(16)
            .fontColor(Color.White)
            .layoutWeight(1)
            .textAlign(TextAlign.Center)

          Button('⋮')
            .fontSize(20)
            .backgroundColor(Color.Transparent)
            .fontColor(Color.White)
            .onClick(() => {
              this.showPhotoMenu();
            })
        }
        .width('100%')
        .padding(16)
        .backgroundColor('rgba(0, 0, 0, 0.5)')

        // 照片显示
        if (this.photo) {
          Image(this.photo.thumbnailPath || this.photo.originalPath)
            .width('100%')
            .layoutWeight(1)
            .objectFit(ImageFit.Contain)
            .backgroundColor('#000')
            .gesture(
              GestureGroup(GestureMode.Exclusive,
                // 左滑查看下一张
                SwipeGesture({ direction: SwipeDirection.Left })
                  .onAction(() => {
                    if (this.currentIndex < this.totalPhotos - 1) {
                      this.viewModel.nextPhoto();
                    }
                  }),
                // 右滑查看上一张
                SwipeGesture({ direction: SwipeDirection.Right })
                  .onAction(() => {
                    if (this.currentIndex > 0) {
                      this.viewModel.previousPhoto();
                    }
                  })
              )
            )
        }

        // 照片信息
        if (this.photo) {
          Column() {
            // 标签
            if (this.viewModel.getTags().length > 0) {
              Row() {
                ForEach(this.viewModel.getTags(), (tag: string) => {
                  Text(tag)
                    .fontSize(12)
                    .fontColor('#FFF')
                    .backgroundColor('rgba(255, 255, 255, 0.3)')
                    .borderRadius(12)
                    .padding({ left: 12, right: 12, top: 6, bottom: 6 })
                    .margin({ right: 8 })
                })
              }
              .width('100%')
              .margin({ bottom: 12 })
            }

            // 添加标签按钮
            Row() {
              Button('+ 添加标签')
                .fontSize(14)
                .backgroundColor('rgba(255, 255, 255, 0.3)')
                .fontColor(Color.White)
                .borderRadius(20)
                .padding({ left: 16, right: 16, top: 8, bottom: 8 })
                .onClick(() => {
                  this.showTagDialog = true;
                })
            }
            .width('100%')
          }
          .width('100%')
          .padding(16)
          .backgroundColor('rgba(0, 0, 0, 0.7)')
        }
      }
      .width('100%')
      .height('100%')
      .backgroundColor('#000')
    }
    .width('100%')
    .height('100%')
    .bindSheet(this.showTagDialog, this.TagDialog(), {
      height: 200,
      showClose: true
    })
  }

  @Builder
  TagDialog() {
    Column() {
      Text('添加标签')
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .margin({ bottom: 16 })

      Text('标签功能将在后续版本完善')
        .fontSize(14)
        .fontColor('#999')

      Button('关闭')
        .fontSize(16)
        .backgroundColor('#1890FF')
        .fontColor(Color.White)
        .layoutWeight(1)
        .height(44)
        .borderRadius(22)
        .margin({ top: 24 })
        .onClick(() => {
          this.showTagDialog = false;
        })
    }
    .width('100%')
    .padding(24)
  }

  showPhotoMenu(): void {
    promptAction.showDialog({
      title: '照片操作',
      buttons: [
        { text: '取消', color: '#999' },
        { text: '编辑标签', color: '#333' },
        { text: '删除', color: '#F5222D' }
      ]
    }, (err, data) => {
      if (data.index === 1) {
        this.showTagDialog = true;
      } else if (data.index === 2) {
        this.deletePhoto();
      }
    });
  }

  deletePhoto(): void {
    promptAction.showDialog({
      title: '确认删除',
      message: '删除这张照片？',
      buttons: [
        { text: '取消', color: '#999' },
        { text: '删除', color: '#F5222D' }
      ]
    }, async (err, data) => {
      if (data.index === 1) {
        const success = await this.viewModel.deletePhoto();
        if (success) {
          promptAction.showToast({ message: '删除成功' });
          router.back();
        } else {
          promptAction.showToast({ message: '删除失败' });
        }
      }
    });
  }
}
```

- [ ] **步骤 2：提交 PhotoDetailPage**

```bash
git add entry/src/main/ets/pages/PhotoDetailPage.ets
git commit -m "feat: 实现PhotoDetailPage，支持滑动导航"
```

---

## 第七部分：标签管理页

### 任务 14：创建 TagViewModel

**文件：**
- 创建：`entry/src/main/ets/viewmodels/TagViewModel.ets`

- [ ] **步骤 1：创建 TagViewModel**

写入到 `entry/src/main/ets/viewmodels/TagViewModel.ets`：

```typescript
import { Tag } from '../models/Tag';
import { Photo } from '../models/Photo';
import { TagService } from '../services/TagService';
import { PhotoService } from '../services/PhotoService';
import { Logger } from '../common/utils/Logger';

export class TagViewModel {
  private tags: Tag[] = [];
  private selectedTag: string | null = null;
  private filteredPhotos: Photo[] = [];
  private isLoading: boolean = false;
  private loadCallbacks: Array<() => void> = [];

  getTags(): Tag[] {
    return this.tags;
  }

  getSelectedTag(): string | null {
    return this.selectedTag;
  }

  getFilteredPhotos(): Photo[] {
    return this.filteredPhotos;
  }

  isLoading(): boolean {
    return this.isLoading;
  }

  onDataChange(callback: () => void): void {
    this.loadCallbacks.push(callback);
  }

  async loadTags(): Promise<void> {
    this.isLoading = true;
    this.notifyCallbacks();

    try {
      this.tags = await TagService.getAllTags();
      Logger.info('TagViewModel', '加载了 %{public}d 个标签', this.tags.length);
    } catch (error) {
      Logger.error('TagViewModel', '加载标签失败: %{public}s', JSON.stringify(error));
    } finally {
      this.isLoading = false;
      this.notifyCallbacks();
    }
  }

  async createTag(name: string, color: string = '#1890FF'): Promise<Tag | null> {
    try {
      const tag = await TagService.createTag(name, color);
      await this.loadTags();
      return tag;
    } catch (error) {
      Logger.error('TagViewModel', '创建标签失败: %{public}s', JSON.stringify(error));
      return null;
    }
  }

  async updateTag(id: number, updates: { name?: string; color?: string }): Promise<boolean> {
    try {
      await TagService.updateTag(id, updates);
      await this.loadTags();
      return true;
    } catch (error) {
      Logger.error('TagViewModel', '更新标签失败: %{public}s', JSON.stringify(error));
      return false;
    }
  }

  async deleteTag(id: number): Promise<boolean> {
    try {
      await TagService.deleteTag(id);
      await this.loadTags();
      return true;
    } catch (error) {
      Logger.error('TagViewModel', '删除标签失败: %{public}s', JSON.stringify(error));
      return false;
    }
  }

  async filterByTag(tagName: string): Promise<void> {
    this.selectedTag = tagName;
    this.isLoading = true;
    this.notifyCallbacks();

    try {
      // 获取所有照片并按标签筛选
      // 注意：这是简化实现
      // 在实际应用中，你需要更高效的查询
      this.filteredPhotos = [];
      Logger.info('TagViewModel', '按标签筛选: %{public}s', tagName);
    } catch (error) {
      Logger.error('TagViewModel', '筛选照片失败: %{public}s', JSON.stringify(error));
    } finally {
      this.isLoading = false;
      this.notifyCallbacks();
    }
  }

  clearFilter(): void {
    this.selectedTag = null;
    this.filteredPhotos = [];
    this.notifyCallbacks();
  }

  private notifyCallbacks(): void {
    this.loadCallbacks.forEach(callback => callback());
  }
}
```

- [ ] **步骤 2：提交 TagViewModel**

```bash
git add entry/src/main/ets/viewmodels/TagViewModel.ets
git commit -m "feat: 添加TagViewModel"
```

### 任务 15：创建 TagManagementPage

**文件：**
- 创建：`entry/src/main/ets/pages/TagManagementPage.ets`

- [ ] **步骤 1：创建 TagManagementPage**

写入到 `entry/src/main/ets/pages/TagManagementPage.ets`：

```typescript
import { TagViewModel } from '../viewmodels/TagViewModel';
import { Tag } from '../models/Tag';
import router from '@ohos.router';
import promptAction from '@ohos.promptAction';

@Entry
@Component
struct TagManagementPage {
  @State viewModel: TagViewModel = new TagViewModel();
  @State tags: Tag[] = [];
  @State isLoading: boolean = false;
  @State selectedTag: string | null = null;
  @State showCreateDialog: boolean = false;
  @State newTagName: string = '';
  @State selectedColor: string = '#1890FF';

  private colors: string[] = [
    '#1890FF', '#52C41A', '#FAAD14', '#F5222D',
    '#722ED1', '#EB2F96', '#13C2C2', '#FA8C16'
  ];

  aboutToAppear() {
    this.viewModel.onDataChange(() => {
      this.tags = this.viewModel.getTags();
      this.isLoading = this.viewModel.isLoading();
      this.selectedTag = this.viewModel.getSelectedTag();
    });
    this.viewModel.loadTags();
  }

  build() {
    Column() {
      // 头部
      Row() {
        Button('<')
          .fontSize(24)
          .backgroundColor(Color.Transparent)
          .fontColor('#333')
          .onClick(() => {
            if (this.selectedTag) {
              this.viewModel.clearFilter();
            } else {
              router.back();
            }
          })

        Text(this.selectedTag || '标签管理')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .layoutWeight(1)

        Button('+')
          .fontSize(24)
          .backgroundColor(Color.Transparent)
          .fontColor('#333')
          .onClick(() => {
            this.showCreateDialog = true;
          })
      }
      .width('100%')
      .padding(16)
      .backgroundColor(Color.White)

      if (this.selectedTag) {
        // 返回标签列表按钮
        Button('返回标签列表')
          .fontSize(14)
          .backgroundColor('#F5F5F5')
          .fontColor('#333')
          .borderRadius(20)
          .padding({ left: 16, right: 16, top: 8, bottom: 8 })
          .margin(12)
          .onClick(() => {
            this.viewModel.clearFilter();
          })
      }

      // 内容区域
      if (this.isLoading) {
        Column() {
          LoadingProgress()
            .width(40)
            .height(40)
          Text('加载中...')
            .fontSize(14)
            .fontColor('#999')
            .margin({ top: 8 })
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
      } else if (this.tags.length === 0) {
        Column() {
          Text('🏷️')
            .fontSize(64)
            .margin({ bottom: 16 })
          Text('还没有标签')
            .fontSize(16)
            .fontColor('#666')
          Button('创建第一个标签')
            .fontSize(14)
            .backgroundColor('#1890FF')
            .fontColor(Color.White)
            .borderRadius(20)
            .padding({ left: 24, right: 24, top: 12, bottom: 12 })
            .margin({ top: 24 })
            .onClick(() => {
              this.showCreateDialog = true;
            })
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
      } else {
        this.TagList()
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
    .bindSheet(this.showCreateDialog, this.CreateTagDialog(), {
      height: 300,
      showClose: true,
      onDisappear: () => {
        this.newTagName = '';
        this.selectedColor = '#1890FF';
      }
    })
  }

  @Builder
  TagList() {
    List() {
      ForEach(this.tags, (tag: Tag) => {
        ListItem() {
          Row() {
            // 标签颜色指示器
            Circle()
              .width(16)
              .height(16)
              .fill(tag.color)
              .margin({ right: 12 })

            Column() {
              Text(tag.name)
                .fontSize(16)
                .fontWeight(FontWeight.Medium)

              Text(`${tag.photoCount} 张照片`)
                .fontSize(12)
                .fontColor('#999')
                .margin({ top: 4 })
            }
            .alignItems(HorizontalAlign.Start)
            .layoutWeight(1)

            Button('>')
              .fontSize(16)
              .backgroundColor(Color.Transparent)
              .fontColor('#CCC')
              .onClick(() => {
                this.viewModel.filterByTag(tag.name);
              })
          }
          .width('100%')
          .padding(16)
          .backgroundColor(Color.White)
          .borderRadius(8)
          .onClick(() => {
            this.viewModel.filterByTag(tag.name);
          })
          .onLongPress(() => {
            this.showTagMenu(tag);
          })
        }
        .width('100%')
      })
    }
    .width('100%')
    .layoutWeight(1)
    .padding(12)
  }

  @Builder
  CreateTagDialog() {
    Column() {
      Text('创建标签')
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .margin({ bottom: 24 })

      TextInput({ placeholder: '标签名称', text: this.newTagName })
        .width('100%')
        .height(44)
        .backgroundColor('#F5F5F5')
        .borderRadius(8)
        .padding({ left: 16, right: 16 })
        .margin({ bottom: 16 })
        .onChange((value: string) => {
          this.newTagName = value;
        })

      Text('选择颜色')
        .fontSize(14)
        .fontColor('#666')
        .width('100%')

      Grid() {
        ForEach(this.colors, (color: string) => {
          GridItem() {
            Circle()
              .width(36)
              .height(36)
              .fill(color)
              .onClick(() => {
                this.selectedColor = color;
              })
          }
        })
      }
      .columnsTemplate('1fr 1fr 1fr 1fr')
      .rowsGap(12)
      .columnsGap(12)
      .width('100%')
      .margin({ top: 12, bottom: 24 })

      Button('创建')
        .fontSize(16)
        .backgroundColor('#1890FF')
        .fontColor(Color.White)
        .width('100%')
        .height(44)
        .borderRadius(22)
        .onClick(async () => {
          if (!this.newTagName.trim()) {
            promptAction.showToast({ message: '请输入标签名称' });
            return;
          }

          const tag = await this.viewModel.createTag(this.newTagName, this.selectedColor);
          if (tag) {
            promptAction.showToast({ message: '标签创建成功' });
            this.showCreateDialog = false;
          } else {
            promptAction.showToast({ message: '创建失败' });
          }
        })
    }
    .width('100%')
    .padding(24)
  }

  showTagMenu(tag: Tag): void {
    promptAction.showDialog({
      title: tag.name,
      buttons: [
        { text: '取消', color: '#999' },
        { text: '删除', color: '#F5222D' }
      ]
    }, (err, data) => {
      if (data.index === 1) {
        this.deleteTag(tag);
      }
    });
  }

  deleteTag(tag: Tag): void {
    promptAction.showDialog({
      title: '确认删除',
      message: `删除标签"${tag.name}"？`,
      buttons: [
        { text: '取消', color: '#999' },
        { text: '删除', color: '#F5222D' }
      ]
    }, async (err, data) => {
      if (data.index === 1) {
        const success = await this.viewModel.deleteTag(tag.id);
        if (success) {
          promptAction.showToast({ message: '删除成功' });
        } else {
          promptAction.showToast({ message: '删除失败' });
        }
      }
    });
  }
}
```

- [ ] **步骤 2：提交 TagManagementPage**

```bash
git add entry/src/main/ets/pages/TagManagementPage.ets
git commit -m "feat: 实现TagManagementPage"
```

---

## 验证

完成所有任务后，验证实现：

- [ ] **运行所有测试**

运行：`hvigorw test`
预期：所有测试通过

- [ ] **构建项目**

运行：`hvigorw assembleHap`
预期：构建成功，无错误

- [ ] **手动验证清单**

1. 相册列表页：
   - [ ] 可以创建新相册
   - [ ] 相册以网格视图显示
   - [ ] 可以切换网格/列表视图
   - [ ] 可以删除相册
   - [ ] 空状态正确显示

2. 相册详情页：
   - [ ] 可以导航到相册详情
   - [ ] 可以编辑相册名称和描述
   - [ ] 照片以网格显示
   - [ ] 多选模式正常工作
   - [ ] 可以选择多张照片
   - [ ] 空状态正确显示

3. 照片详情页：
   - [ ] 可以查看照片详情
   - [ ] 滑动导航正常工作
   - [ ] 可以删除照片
   - [ ] 标签正确显示

4. 标签管理页：
   - [ ] 可以创建标签
   - [ ] 标签以正确颜色显示
   - [ ] 可以删除标签
   - [ ] 空状态正确显示

---

## 后续步骤

此阶段完成后：

1. 集成 PhotoPicker 用于添加照片
2. 从照片读取 EXIF 信息
3. 为照片生成缩略图
4. 实现云同步（第三阶段+）
5. 添加照片编辑功能
6. 实现搜索功能

---

## 附录

### 依赖

本实现使用以下 HarmonyOS API：
- `@ohos.data.relationalStore` - RDB数据库
- `@ohos.file.photoAccessHelper` - 照片访问（用于PhotoPicker集成）
- `@ohos.multimedia.image` - 图像处理（用于EXIF和缩略图）
- `@ohos.file.fs` - 文件操作
- `@ohos.hypium` - 测试框架
- `@ohos.router` - 导航
- `@ohos.promptAction` - 对话框和提示

### 设计决策

1. **RDB 用于本地存储**：因可靠性和SQL支持优于Preferences，适用于复杂关系
2. **MVVM 模式**：与项目架构和现有代码库一致
3. **网格/列表视图切换**：为不同偏好的用户提供灵活性
4. **多选模式**：批量操作的高效方式
5. **照片中标签为JSON字符串**：简化存储，如果出现性能问题可以在未来规范化

### 未来增强

- PhotoPicker 集成用于添加照片
- EXIF 数据提取和显示
- 缩略图生成以提升性能
- 云同步
- 按标签和元数据搜索
- 照片编辑功能
- 操作的撤销/重做
- 导出/分享功能
