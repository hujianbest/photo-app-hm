# 第二阶段：照片管理模块设计文档

## 概述

**阶段目标**：实现完整的本地照片管理功能，包括相册管理、照片上传、分类标签、照片详情和批量操作。

**技术选型**：
- 数据库：RDB（关系型数据库）
- 照片存储：存储系统相册路径引用
- 架构模式：MVVM
- 云同步：暂不实现，为后续云同步预留接口

---

## 1. 数据模型设计

### 1.1 Album（相册）

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
```

### 1.2 Photo（照片）

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
```

### 1.3 Tag（标签）

```typescript
export interface Tag {
  id: number;                    // 标签ID
  name: string;                  // 标签名称
  color: string;                 // 标签颜色（HEX格式）
  photoCount: number;            // 关联照片数量
}
```

### 1.4 ExifInfo（EXIF信息）

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

---

## 2. 服务层架构

### 2.1 DatabaseService（数据库服务）

负责RDB数据库的初始化和基础操作。

**核心方法**：
- `init(context: Context)`: 初始化数据库，创建表结构
- `query(sql: string, args: any[])`: 执行SQL查询
- `insert(tableName: string, values: ValuesBucket)`: 执行插入
- `update(tableName: string, values: ValuesBucket, predicates: RdbPredicates)`: 执行更新
- `delete(tableName: string, predicates: RdbPredicates)`: 执行删除

**数据库表结构**：

```sql
-- 相册表
CREATE TABLE albums (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL,
  coverPhotoPath TEXT DEFAULT '',
  photoCount INTEGER DEFAULT 0,
  description TEXT DEFAULT '',
  createdAt INTEGER NOT NULL,
  updatedAt INTEGER NOT NULL
)

-- 照片表
CREATE TABLE photos (
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

-- 标签表
CREATE TABLE tags (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL UNIQUE,
  color TEXT DEFAULT '#1890FF',
  photoCount INTEGER DEFAULT 0
)

-- 索引
CREATE INDEX idx_photos_albumId ON photos(albumId)
CREATE INDEX idx_photos_takenAt ON photos(takenAt)
CREATE INDEX idx_tags_name ON tags(name)
```

### 2.2 AlbumService（相册服务）

**核心方法**：
- `createAlbum(name: string, description?: string)`: 创建相册
- `getAllAlbums()`: 获取所有相册
- `getAlbumById(id: number)`: 获取单个相册
- `updateAlbum(id: number, updates: Partial<Album>)`: 更新相册
- `deleteAlbum(id: number)`: 删除相册（级联删除照片记录）
- `setCoverPhoto(albumId: number, photoPath: string)`: 设置封面
- `updatePhotoCount(albumId: number)`: 更新照片数量（内部方法）

### 2.3 PhotoService（照片服务）

**核心方法**：
- `addPhotosToAlbum(albumId: number, photoUris: string[])`: 添加照片到相册
- `getPhotosByAlbum(albumId: number)`: 获取相册内所有照片
- `getPhotoById(id: number)`: 获取单张照片详情
- `updatePhoto(id: number, updates: Partial<Photo>)`: 更新照片信息
- `deletePhoto(id: number)`: 删除照片
- `deletePhotos(photoIds: number[])`: 批量删除
- `movePhotos(photoIds: number[], targetAlbumId: number)`: 批量移动
- `addTagsToPhotos(photoIds: number[], tags: string[])`: 批量添加标签
- `getPhotosByTag(tag: string)`: 按标签筛选
- `generateThumbnail(originalPath: string)`: 生成缩略图
- `readExifInfo(photoPath: string)`: 读取EXIF信息

### 2.4 TagService（标签服务）

**核心方法**：
- `getAllTags()`: 获取所有标签
- `createTag(name: string, color?: string)`: 创建标签
- `updateTag(id: number, updates: Partial<Tag>)`: 更新标签
- `deleteTag(id: number)`: 删除标签（移除照片关联）
- `autoClassifyByTime(photos: Photo[])`: 按时间自动分类
- `updateTagPhotoCount(tagId: number)`: 更新标签照片数量

---

## 3. ViewModel层设计

### 3.1 AlbumListViewModel（相册列表）

**状态属性**：
- `albums: Album[]`: 相册列表
- `isLoading: boolean`: 加载状态
- `viewMode: 'grid' | 'list'`: 视图模式

**核心方法**：
- `loadAlbums()`: 加载相册列表
- `toggleViewMode()`: 切换视图模式
- `createAlbum(name: string, description?: string)`: 创建新相册
- `deleteAlbum(albumId: number)`: 删除相册
- `refresh()`: 刷新列表

### 3.2 AlbumDetailViewModel（相册详情）

**状态属性**：
- `album: Album | null`: 当前相册
- `photos: Photo[]`: 照片列表
- `selectedPhotos: Set<number>`: 选中的照片ID
- `isMultiSelectMode: boolean`: 多选模式
- `isLoading: boolean`: 加载状态

**核心方法**：
- `loadAlbum(albumId: number)`: 加载相册详情和照片
- `addPhotos()`: 添加照片（调用PhotoPicker）
- `toggleMultiSelectMode()`: 进入/退出多选模式
- `togglePhotoSelection(photoId: number)`: 选择/取消选择
- `selectAll() / deselectAll()`: 全选/取消全选
- `deleteSelected()`: 批量删除
- `moveSelectedToAlbum(targetAlbumId: number)`: 批量移动
- `addTagsToSelected(tags: string[])`: 批量添加标签
- `updateAlbumInfo(updates: Partial<Album>)`: 更新相册信息

### 3.3 PhotoDetailViewModel（照片详情）

**状态属性**：
- `photo: Photo | null`: 当前照片
- `exifInfo: ExifInfo | null`: EXIF信息
- `currentIndex: number`: 当前照片索引
- `totalPhotos: number`: 总照片数
- `photoList: Photo[]`: 照片列表（用于滑动切换）

**核心方法**：
- `loadPhoto(photoId: number)`: 加载照片详情
- `setPhotoList(photos: Photo[], currentIndex: number)`: 设置照片列表
- `previousPhoto() / nextPhoto()`: 上一张/下一张
- `updateTags(tags: string[])`: 更新标签
- `deletePhoto()`: 删除照片
- `moveToAlbum(albumId: number)`: 移动到其他相册

### 3.4 TagViewModel（标签管理）

**状态属性**：
- `tags: Tag[]`: 标签列表
- `selectedTag: string | null`: 当前选中的标签
- `photos: Photo[]`: 按标签筛选的照片

**核心方法**：
- `loadTags()`: 加载所有标签
- `createTag(name: string, color: string)`: 创建标签
- `filterByTag(tagName: string)`: 按标签筛选照片
- `clearFilter()`: 清除筛选

---

## 4. 页面设计

### 4.1 页面结构

```
照片管理Tab
├── AlbumListPage（相册列表页）
│   ├── 网格视图：2列相册卡片
│   ├── 列表视图：相册行项
│   └── FAB：创建相册按钮
├── AlbumDetailPage（相册详情页）
│   ├── 顶部：相册信息 + 操作按钮
│   ├── 照片网格：3列照片缩略图
│   ├── 多选模式：底部操作栏
│   └── FAB：添加照片按钮
├── PhotoDetailPage（照片详情页）
│   ├── 大图展示：支持缩放
│   ├── 底部：照片信息 + 标签
│   └── 滑动手势：左右切换
└── TagManagementPage（标签管理页）
    ├── 标签列表：彩色标签卡片
    └── 按标签筛选的照片网格
```

### 4.2 交互设计

**相册列表页**：
- 下拉刷新
- 点击相册进入详情
- 长按相册弹出操作菜单（编辑/删除）
- 点击FAB弹出创建相册对话框

**相册详情页**：
- 点击照片进入详情页
- 长按进入多选模式
- 多选模式：底部显示操作栏（删除/移动/标签）
- 点击FAB调用系统相册选择器

**照片详情页**：
- 双指缩放查看大图
- 左右滑动切换照片
- 底部显示EXIF信息和标签
- 点击标签图标编辑标签

**标签管理页**：
- 标签列表展示
- 点击标签筛选照片
- 长按标签编辑/删除

---

## 5. 数据流设计

### 5.1 添加照片流程

```
用户点击添加按钮
  ↓
调用PhotoPicker选择照片
  ↓
PhotoService.addPhotosToAlbum()
  ↓
├─ 读取照片信息（大小/尺寸）
├─ 读取EXIF信息（时间/地点）
├─ 生成缩略图
├─ 插入照片记录到数据库
└─ 更新相册照片数量
  ↓
ViewModel更新照片列表
  ↓
UI刷新
```

### 5.2 批量操作流程

```
用户长按照片进入多选模式
  ↓
选择多张照片
  ↓
点击操作按钮（删除/移动/标签）
  ↓
PhotoService批量操作
  ├─ 开启事务
  ├─ 批量更新数据库
  └─ 更新相册照片数量
  ↓
ViewModel更新列表
  ↓
退出多选模式，UI刷新
```

---

## 6. 错误处理

### 6.1 错误类型

| 错误类型 | 处理方式 |
|---------|---------|
| 数据库错误 | Toast提示 + 记录日志 |
| 文件读取失败 | Toast提示 + 跳过该照片 |
| EXIF读取失败 | 使用默认值，不影响添加 |
| 缩略图生成失败 | 使用原图路径 |
| 权限不足 | 引导用户授权 |

### 6.2 空状态展示

- 无相册：显示"创建第一个相册"引导
- 相册无照片：显示"添加照片"引导
- 标签筛选无结果：显示"暂无照片"

---

## 7. 性能优化

### 7.1 列表性能

- 使用缩略图路径加载列表，避免加载大图
- 实现图片懒加载
- 使用LazyForEach组件渲染长列表

### 7.2 数据库优化

- 为常用查询字段创建索引
- 使用事务处理批量操作
- 冗余photoCount字段避免COUNT查询

### 7.3 内存优化

- 照片详情页只保留当前照片的大图
- 列表页预加载可见区域的缩略图
- 及时释放不可见图片资源

---

## 8. 测试策略

### 8.1 单元测试

**DatabaseService测试**：
- 数据库初始化
- CRUD操作
- 事务处理

**AlbumService测试**：
- 创建/更新/删除相册
- 照片数量更新

**PhotoService测试**：
- 添加照片
- 批量操作
- 标签筛选

**TagService测试**：
- 标签CRUD
- 自动分类

### 8.2 集成测试

- 添加照片到相册的完整流程
- 批量操作的完整流程
- 照片详情页的滑动切换

### 8.3 UI测试

- 相册列表的视图切换
- 多选模式的交互
- 照片详情的手势操作

---

## 9. 后续扩展

### 9.1 云同步预留接口

所有Service方法返回的数据模型与云端数据模型保持一致，后续添加云同步时：
- 添加 `CloudSyncService`
- 修改Service层方法，添加云端同步逻辑
- ViewModel层无需修改

### 9.2 功能扩展点

- 照片编辑功能
- 智能分类（AI识别）
- 相册加密
- 照片搜索
- 回收站机制

---

## 10. 开发计划

### 10.1 开发顺序

1. **数据库层**（1天）
   - DatabaseService
   - 数据模型定义
   - 数据库表创建

2. **服务层**（2天）
   - AlbumService
   - PhotoService
   - TagService

3. **相册管理页面**（1天）
   - AlbumListViewModel
   - AlbumListPage
   - 创建相册对话框

4. **相册详情页面**（1.5天）
   - AlbumDetailViewModel
   - AlbumDetailPage
   - 多选模式
   - 批量操作

5. **照片详情页面**（1天）
   - PhotoDetailViewModel
   - PhotoDetailPage
   - EXIF信息展示

6. **标签管理**（0.5天）
   - TagViewModel
   - TagManagementPage

7. **测试与优化**（1天）
   - 单元测试
   - 集成测试
   - 性能优化

**总计**：约8天

---

## 11. 注意事项

1. **权限申请**：需要申请相册读取权限
2. **文件路径**：HarmonyOS的文件路径格式与Android不同
3. **EXIF读取**：需要使用 @ohos.multimedia.image API
4. **缩略图生成**：需要使用图片解码和编码API
5. **数据库版本**：预留数据库升级方案

---

## 附录

### A. 依赖的HarmonyOS API

- `@ohos.data.relationalStore`: RDB数据库
- `@ohos.file.photoAccessHelper`: 照片访问
- `@ohos.multimedia.image`: 图片处理
- `@ohos.file.fs`: 文件操作

### B. 参考文档

- HarmonyOS关系型数据库开发指南
- HarmonyOS图片开发指南
- HarmonyOS文件管理开发指南
