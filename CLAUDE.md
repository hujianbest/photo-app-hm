# CLAUDE.md - 项目开发指南

> 本文档为 Claude AI 助手提供项目的完整上下文，帮助理解项目架构、开发规范和待办事项。

---

## 项目概述

### 项目信息
- **项目名称**：摄影爱好者APP (HarmonyOS版)
- **目标平台**：HarmonyOS
- **开发语言**：ArkTS (TypeScript超集)
- **UI框架**：ArkUI
- **架构模式**：MVVM (Model-ViewModel-View)
- **当前进度**：4/6 阶段完成 (67%)

### 项目定位
综合性摄影平台，为摄影爱好者提供：
1. 用户管理（注册登录、个人资料）
2. 照片管理（相册、智能分类）
3. 社区交流（作品广场、话题圈子）
4. 约拍匹配（摄影师/模特撮合）
5. 学习中心（教程、技巧文章）
6. 拍摄工具箱（参数计算、构图辅助）

---

## 已完成阶段详情

### Phase 1: 用户管理 ✅
**完成日期**: 2026-03-12

**功能清单**:
- 注册登录（手机号/邮箱）
- 华为账号一键登录
- 个人资料（头像、昵称、简介）
- 角色切换（摄影师/模特）
- 实名认证
- 隐私设置
- 账号安全

**技术要点**:
- AuthService 统一认证
- Token 管理
- 登录状态持久化
- 表单验证

**文件产出**:
- Models: User.ets
- Services: AuthService.ets
- ViewModels: LoginViewModel.ets, RegisterViewModel.ets
- Pages: LoginPage.ets, RegisterPage.ets

---

### Phase 2: 照片管理 ✅
**完成日期**: 2026-03-13

**功能清单**:
- 相册CRUD（创建、编辑、删除）
- 照片导入到本地相册
- 照片详情查看（EXIF信息）
- 标签管理系统
- 批量移动、删除照片
- RDB数据库本地存储

**技术要点**:
- RDB数据库操作
- PhotoPicker 集成
- 图片加载优化
- 批量操作

**文件产出**:
- Models: Album.ets, Photo.ets, Tag.ets, ExifInfo.ets
- Services: AlbumService.ets, PhotoService.ets, TagService.ets
- ViewModels: AlbumListViewModel.ets, AlbumDetailViewModel.ets, PhotoDetailViewModel.ets, TagViewModel.ets
- Pages: PhotoPage.ets, AlbumDetailPage.ets, PhotoDetailPage.ets, TagManagementPage.ets

---

### Phase 3: 社区交流 ✅
**完成日期**: 2026-03-14

**功能清单**:
- 发布流作品广场
- 帖子发布（文本+照片+话题）
- 点赞、评论、收藏
- 话题圈子关注
- 用户关注系统
- 消息通知（点赞、评论、关注）
- 下拉刷新、无限滚动

**技术要点**:
- 远程API调用
- 回调机制状态管理
- 分页加载
- 瀑布流模拟（Grid组件）

**文件产出**:
- Models: Post.ets, Comment.ets, Topic.ets, Notification.ets, Follow.ets
- Services: PostService.ets, CommentService.ets, TopicService.ets, FollowService.ets, NotificationService.ets
- ViewModels: HomeViewModel.ets, PostDetailViewModel.ets, TopicListViewModel.ets, NotificationListViewModel.ets
- Pages: HomePage.ets, PostDetailPage.ets, PostCreatePage.ets, NotificationListPage.ets
- Modified: MinePage.ets (添加通知入口)

---

### Phase 4: 约拍匹配 ✅
**完成日期**: 2026-03-14

**功能清单**:
- 摄影师/模特用户档案展示
- 作品集展示（Grid布局）
- 评分和评价系统
- 可约时间管理（周历+时间范围）
- 约拍发布表单
- 约拍状态管理（6种状态）
- 状态操作（接受/拒绝/取消/完成）
- 聊天功能（基础版）
- 消息列表和会话管理

**技术要点**:
- 状态机设计（BookingStatus枚举）
- 表单验证
- 聊天消息类型（TEXT/IMAGE/BOOKING/SYSTEM）
- 消息气泡布局（左右对齐）

**文件产出**:
- Models: Booking.ets, BookingProfile.ets, Message.ets, BookingFilters.ets
- Services: BookingService.ets, ProfileService.ets, ChatService.ets
- ViewModels: BookingListViewModel.ets, BookingDetailViewModel.ets, ProfileViewModel.ets, ChatViewModel.ets
- Pages: BookingPage.ets, BookingCreatePage.ets, BookingDetailPage.ets, ProfilePage.ets, ChatPage.ets
- Modified: main_pages.json (添加4个新路由)

---

## 待开发阶段

### Phase 5: 学习中心 ⏳
**核心功能**:
- 视频教程（分类：基础/进阶/专项）
- 技巧文章（图文教程、参数解析）
- 作品赏析（大师作品+参数+点评）
- 学习进度跟踪
- 收藏功能

**预估复杂度**: 中等
**预计文件数**: 15-20个

**关键组件**:
- 视频播放器
- 文章阅读器
- 进度条
- 收藏管理

---

### Phase 6: 拍摄工具箱 ⏳
**核心功能**:
- 参数计算器（景深、曝光、超焦距）
- 构图辅助（九宫格、黄金螺旋、对角线）
- 光线提醒（黄金时段、蓝调时刻）
- 计算结果展示

**预估复杂度**: 中等
**预计文件数**: 10-15个

**关键组件**:
- 计算工具类
- 叠加图层
- 定时提醒
- 相机集成（可选）

---

## 项目架构

### MVVM 分层架构

```
┌─────────────────────────────────┐
│   View Layer (Pages)         │
│   - UI组件和页面布局          │
│   - @State响应式更新          │
└──────────────┬──────────────┘
               │
               │ onDataChange
               ↓
┌─────────────────────────────────┐
│   ViewModel Layer             │
│   - 业务逻辑和状态管理          │
│   - Service方法调用            │
└──────────────┬──────────────┘
               │
               ↓
┌─────────────────────────────────┐
│   Service Layer               │
│   - API调用                   │
│   - 数据处理                  │
│   - 错误处理                  │
└──────────────┬──────────────┘
               │
               ↓
┌─────────────────────────────────┐
│   Model Layer                 │
│   - 数据接口定义               │
└─────────────────────────────────┘
```

### 文件组织

```
entry/src/main/ets/
├── common/
│   ├── constants/
│   │   └── Constants.ets      # 常量定义
│   ├── utils/
│   │   ├── Logger.ets         # 日志工具
│   │   └── Toast.ets         # 提示工具
│   └── components/            # 公共组件（待补充）
├── models/                    # 数据模型
│   ├── User.ets
│   ├── Album.ets, Photo.ets
│   ├── Post.ets, Comment.ets, Topic.ets, Follow.ets, Notification.ets
│   └── Booking.ets, BookingProfile.ets, Message.ets, BookingFilters.ets
├── services/                  # 业务服务
│   ├── HttpService.ets        # HTTP服务封装
│   ├── StorageService.ets     # 存储服务
│   ├── DatabaseService.ets     # 数据库服务
│   ├── AuthService.ets
│   ├── AlbumService.ets, PhotoService.ets, TagService.ets
│   ├── PostService.ets, CommentService.ets, TopicService.ets, FollowService.ets, NotificationService.ets
│   └── BookingService.ets, ProfileService.ets, ChatService.ets
├── viewmodels/               # 视图模型
│   ├── LoginViewModel.ets, RegisterViewModel.ets
│   ├── AlbumListViewModel.ets, AlbumDetailViewModel.ets, PhotoDetailViewModel.ets, TagViewModel.ets
│   ├── HomeViewModel.ets, PostDetailViewModel.ets, TopicListViewModel.ets, NotificationListViewModel.ets
│   └── BookingListViewModel.ets, BookingDetailViewModel.ets, ProfileViewModel.ets, ChatViewModel.ets
├── pages/                     # 页面
│   ├── SplashPage.ets
│   ├── LoginPage.ets, RegisterPage.ets
│   ├── MainPage.ets
│   ├── PhotoPage.ets
│   ├── AlbumDetailPage.ets, PhotoDetailPage.ets, TagManagementPage.ets
│   ├── HomePage.ets, PostDetailPage.ets, PostCreatePage.ets, NotificationListPage.ets
│   ├── BookingPage.ets, BookingCreatePage.ets, BookingDetailPage.ets, ProfilePage.ets, ChatPage.ets
│   └── LearnPage.ets, ToolPage.ets (待创建)
└── MinePage.ets
```

---

## 开发规范

### 命名规范

**文件命名**:
- 模型: `*.ets` (如 `User.ets`)
- 服务: `*Service.ets` (如 `UserService.ets`)
- 视图模型: `*ViewModel.ets` (如 `HomeViewModel.ets`)
- 页面: `*Page.ets` (如 `HomePage.ets`)

**类命名**: 大驼峰 (PascalCase)
- `class UserService`, `class HomeViewModel`

**方法命名**: 小驼峰 (camelCase)
- `getUserById()`, `loadPosts()`

**变量命名**: 小驼峰 (camelCase)
- `const userId = 'xxx'`

**枚举命名**: 大驼峰
- `enum BookingStatus { ... }`

### 代码风格

**服务类**:
```typescript
export class ServiceName {
  private static readonly ENDPOINT = '/resource';

  static async methodName(params): Promise<Result> {
    try {
      const response = await HttpService.get<Result>(url);
      Logger.info('ServiceName', '操作成功');
      return response;
    } catch (error) {
      Logger.error('ServiceName', '操作失败');
      throw error;
    }
  }
}
```

**ViewModel**:
```typescript
export class ViewModelName {
  private data: DataType[] = [];
  private isLoading: boolean = false;
  private callbacks: Array<() => void> = [];

  getData(): DataType[] { return this.data; }
  isLoading(): boolean { return this.isLoading; }

  onDataChange(callback: () => void): void {
    this.callbacks.push(callback);
  }

  private notifyCallbacks(): void {
    this.callbacks.forEach(callback => callback());
  }
}
```

**页面组件**:
```typescript
@Entry
@Component
struct PageName {
  @State viewModel: ViewModelName = new ViewModelName();
  @State data: DataType[] = [];
  @State isLoading: boolean = false;

  aboutToAppear() {
    this.viewModel.onDataChange(() => {
      this.data = this.viewModel.getData();
      this.isLoading = this.viewModel.isLoading();
    });
    this.viewModel.loadData();
  }

  build() {
    Column() { ... }
  }

  @Builder
  ComponentName(prop: Type) {
    // UI组件实现
  }
}
```

### Git提交规范

**提交消息格式**:
```
<type>: <subject>

type: feat, fix, docs, style, refactor, test, chore
subject: 简短描述（不超过50字符）
```

**Type类型说明**:
- `feat`: 新功能
- `fix`: Bug修复
- `docs`: 文档更新
- `style`: 代码格式调整（不影响功能）
- `refactor`: 重构（不是新功能也不是修复）
- `test`: 测试相关
- `chore`: 构建/工具链相关

**示例**:
```
feat: 添加约拍服务
fix: 修复登录状态丢失bug
docs: 更新README文档
```

---

## 技能使用指南

### Superpowers技能集

项目使用 `superpowers` 技能集进行开发：

1. **writing-plans** - 制定详细实施计划
   - 使用场景：新功能模块开发前
   - 输出：详细的实施计划文档
   - 文件位置: `docs/superpowers/plans/`

2. **subagent-driven-development** - 执行计划
   - 使用场景：执行已有计划时
   - 特点：独立子代理 + 两个阶段审查
   - 审查阶段：规范符合性 → 代码质量

3. **brainstorming** - 功能设计探索
   - 使用场景：新功能需求讨论时
   - 输出：设计思路和实现方案

### 开发工作流

```
1. [brainstorming] 探索需求
   ↓
2. [writing-plans] 制定详细计划
   ↓
3. [subagent-driven-development] 执行计划
   ↓
4. 代码审查（code-reviewer）
   ↓
5. 提交代码
```

### 任务拆分原则

**Bite-sized任务**（2-5分钟）:
- 创建单个数据模型
- 创建单个服务方法
- 创建单个页面组件
- 提交单个文件

**避免**:
- 单次任务包含多个文件
- 单次任务超过30分钟
- 跨多个职责的操作

---

## 关键技术点

### 1. 状态管理模式

**回调机制**:
所有ViewModel使用回调机制通知UI更新：

```typescript
// ViewModel
onDataChange(callback: () => void): void {
  this.loadCallbacks.push(callback);
}

// Page
viewModel.onDataChange(() => {
  this.data = viewModel.getData();
});
```

**原因**:
- ArkUI的@State是单向数据流
- 避免ViewModel直接依赖UI框架
- 保持ViewModel纯净

### 2. 错误处理策略

**统一模式**:
```typescript
try {
  const result = await Service.method();
  Logger.info('Service', '操作成功');
  return result;
} catch (error) {
  Logger.error('Service', '操作失败');
  throw error;
}
```

**用户提示**:
- Toast显示友好提示
- 空状态显示引导
- 加载状态显示进度

### 3. 分页加载策略

**实现方式**:
- 基于页码的分页（page, pageSize）
- 支持无限滚动（滚动到底自动加载下一页）
- 避免重复数据（page递增）

### 4. 路由配置

**路由文件**: `entry/src/main/resources/base/profile/main_pages.json`

**新增页面步骤**:
1. 创建页面文件
2. 添加到`main_pages.json`的`src`数组
3. 提交变更

---

## 已知问题和限制

### 占位功能

以下功能当前为占位实现：

1. **PhotoPicker集成**（Phase 3, 4）
   - 影响：无法真实上传照片
   - 计划：集成 @ohos.file.photoAccessHelper

2. **日期时间选择器**（Phase 4）
   - 影响：约拍表单需占位实现
   - 计划：集成 DatePicker 和 TimePicker

3. **地图定位**（Phase 4）
   - 影响：约拍地点仅文本输入
   - 计划：集成地图组件

4. **WebSocket实时消息**（Phase 4）
   - 影响：聊天消息依赖手动刷新
   - 计划：集成WebSocket推送

5. **智能推荐算法**（Phase 4）
   - 影响：推荐功能是占位
   - 计划：实现基于位置、风格、评分的算法

### 待优化

1. **测试覆盖**: 缺少自动化测试
2. **性能优化**: 大列表需虚拟滚动
3. **图片缓存**: 需要实现图片懒加载
4. **代码复用**: Builder组件可抽取为公共组件

---

## 开发命令

### 常用Git命令

```bash
# 查看状态
git status

# 查看提交历史
git log --oneline -20

# 查看文件差异
git diff

# 提交更改
git add .
git commit -m "feat: description"

# 创建分支
git checkout -b feature/new-feature

# 合并分支
git checkout master
git merge feature/new-feature
```

### 构建命令

```bash
# 清理构建
hvigorw clean

# 构建HAP
hvigorw assembleHap

# 安装到设备
hdc install entry/build/default/outputs/default/entry-default-signed.hap
```

---

## 下一步计划

### 短期目标
1. 完成 Phase 5: 学习中心模块
2. 完善各阶段占位功能
3. 补充自动化测试

### 中期目标
1. 完成 Phase 6: 拍摄工具箱模块
2. 性能优化（虚拟列表、图片缓存）
3. 安全加固（内容审核、防刷）

### 长期目标
1. 用户体验优化
2. 数据分析和推荐
3. 跨平台适配

---

## 附录

### 关键文档位置

- 总体设计: `docs/plans/2026-03-13-photo-app-design.md`
- Phase 1总结: `docs/plans/phase1-summary.md`
- Phase 2总结: `docs/plans/phase2-summary.md`
- Phase 3总结: `docs/plans/phase3-summary.md`
- Phase 4总结: `docs/plans/phase4-summary.md`
- Phase 3过程: `docs/第三阶段开发过程记录.md`
- Phase 4过程: `docs/第四阶段开发过程记录.md`

### 常用文件路径

```
路由配置: entry/src/main/resources/base/profile/main_pages.json
应用入口: entry/src/main/ets/entryability/EntryAbility.ets
主页面:   entry/src/main/ets/pages/MainPage.ets
启动页:   entry/src/main/ets/pages/SplashPage.ets
```

---

**文档版本**: v1.0
**最后更新**: 2026-03-14
**维护者**: Claude AI + 项目开发者
