# 摄影爱好者APP (HarmonyOS版)

> 一个专为摄影爱好者打造的全功能摄影平台，采用HarmonyOS原生技术开发。

## 项目简介

本项目是一个综合性摄影平台APP，为摄影爱好者提供从作品管理、社区交流、摄影师约拍到学习成长的完整生态体验。

### 核心功能

- **用户管理**：注册登录、个人资料、角色切换（摄影师/模特）
- **照片管理**：相册管理、智能分类、云端同步、批量操作
- **社区交流**：作品广场、话题圈子、关注系统、消息通知
- **约拍匹配**：用户档案、智能推荐、约拍发布、实时聊天
- **学习中心**（计划中）：视频教程、技巧文章、作品赏析
- **拍摄工具箱**（计划中）：参数计算、构图辅助、光线提醒

## 开发进度

| 阶段 | 模块 | 状态 | 完成日期 |
|------|------|------|----------|
| Phase 1 | 用户管理 | ✅ 完成 | 2026-03-12 |
| Phase 2 | 照片管理 | ✅ 完成 | 2026-03-13 |
| Phase 3 | 社区交流 | ✅ 完成 | 2026-03-14 |
| Phase 4 | 约拍匹配 | ✅ 完成 | 2026-03-14 |
| Phase 5 | 学习中心 | ⏳ 计划中 | - |
| Phase 6 | 拍摄工具箱 | ⏳ 计划中 | - |

**当前进度：4/6 (67%)**

## 技术栈

- **框架**：ArkTS + ArkUI (HarmonyOS原生)
- **架构**：MVVM (Model-View-ViewModel)
- **本地存储**：RDB (关系型数据库) + Preferences
- **网络通信**：@ohos.net.http.HttpRequest
- **路由**：@ohos.router
- **UI组件**：ArkUI 原生组件

## 项目结构

```
photo-app/
├── entry/                    # 主模块
│   ├── src/
│   │   ├── main/
│   │   │   ├── ets/          # ArkTS源码
│   │   │   │   ├── common/   # 公共组件、工具类
│   │   │   │   ├── models/   # 数据模型
│   │   │   │   ├── viewmodels/ # 视图模型
│   │   │   │   ├── services/ # 业务服务
│   │   │   │   ├── pages/    # 页面
│   │   │   │   └── entryability/
│   │   │   └── resources/    # 资源文件
│   │   └── test/             # 测试代码
├── docs/                     # 文档
│   └── plans/                # 设计文档和阶段总结
└── build-profile.json5       # 构建配置
```

## 功能详解

### Phase 1: 用户管理 ✅
- 手机号/邮箱注册登录
- 华为账号一键登录
- 个人资料编辑（头像、昵称、简介）
- 摄影师/模特角色切换
- 登录状态保持

### Phase 2: 照片管理 ✅
- 相册CRUD（创建、编辑、删除）
- 照片导入到本地相册
- 照片详情查看（EXIF信息）
- 标签管理系统
- 批量移动、删除照片
- RDB数据库本地存储

### Phase 3: 社区交流 ✅
- 瀑布流作品广场
- 帖子发布（文本+照片+话题）
- 点赞、评论、收藏
- 话题圈子关注
- 用户关注系统
- 消息通知（点赞、评论、关注）
- 分页加载、下拉刷新

### Phase 4: 约拍匹配 ✅
- 摄影师/模特用户档案展示
- 作品集展示
- 评分和评价系统
- 可约时间管理
- 约拍发布表单
- 约拍状态管理（待确认/已确认/进行中/已完成/已取消/已拒绝）
- 接受/拒绝/取消/完成约拍操作
- 实时聊天功能（基础版）
- 消息列表和会话管理

### Phase 5: 学习中心（计划中）
- 分类视频教程
- 技巧文章
- 作品赏析
- 学习进度跟踪

### Phase 6: 拍摄工具箱（计划中）
- 景深计算器
- 曝光计算
- 超焦距计算
- 构图辅助（九宫格、黄金螺旋）
- 光线提醒（黄金时段、蓝调时刻）

## 开发文档

项目详细文档位于 `docs/` 目录：

- **设计文档**：`docs/plans/2026-03-13-photo-app-design.md` - 整体设计文档
- **阶段总结**：
  - `docs/plans/phase1-summary.md` - 第一阶段总结
  - `docs/plans/phase2-summary.md` - 第二阶段总结
  - `docs/plans/phase3-summary.md` - 第三阶段总结
  - `docs/plans/phase4-summary.md` - 第四阶段总结
- **开发过程记录**：
  - `docs/第三阶段开发过程记录.md` - 第三阶段详细开发记录
  - `docs/第四阶段开发过程记录.md` - 第四阶段详细开发记录

## 开发规范

### 代码规范
- 使用 TypeScript 严格模式
- 遵循 MVVM 架构模式
- 类名使用大驼峰 (PascalCase)
- 方法名使用小驼峰 (camelCase)
- 私有变量使用下划线前缀

### 文件命名
- Models: `*.ets` (如 User.ets, Booking.ets)
- Services: `*Service.ets` (如 UserService.ets)
- ViewModels: `*ViewModel.ets` (如 HomeViewModel.ets)
- Pages: `*Page.ets` (如 HomePage.ets)

### 提交规范
- 使用约定式提交：`feat:`, `fix:`, `docs:`, `refactor:`
- 提交信息清晰描述变更内容
- 单一功能单次提交

### 状态管理
- 使用回调机制 (`onDataChange`)
- ViewModel 管理业务状态
- Page 通过 `@State` 装饰器响应式更新

## 快速开始

### 环境要求
- DevEco Studio 4.0+
- HarmonyOS SDK API 9+
- Node.js 14+

### 安装依赖
```bash
npm install
```

### 构建项目
```bash
hvigorw assembleHap
```

### 运行项目
在 DevEco Studio 中点击 Run 按钮或使用命令：
```bash
hvigorw installHap
```

## 架构设计

### MVVM 架构
```
┌─────────────────────────────────┐
│         Page (View Layer)     │
│  - UI组件和页面布局           │
└─────────────┬───────────────┘
              │ onDataChange
              ↓
┌─────────────────────────────────┐
│      ViewModel (Logic Layer)   │
│  - 业务逻辑和状态管理          │
└─────────────┬───────────────┘
              │
              ↓
┌─────────────────────────────────┐
│       Service (Data Layer)      │
│  - API调用和数据处理          │
└─────────────┬───────────────┘
              │
              ↓
┌─────────────────────────────────┐
│       Model (Data Interface)     │
│  - 数据结构定义               │
└─────────────────────────────────┘
```

### 数据流转
```
用户交互
    ↓
Page (UI层)
    ↓
ViewModel (业务层)
    ↓
Service (数据层)
    ↓
HttpService (网络层)
    ↓
Remote API
    ↓
ViewModel (状态更新)
    ↓
Page (UI刷新)
```

## 关键特性

### 状态机管理
约拍模块实现了完整的状态机：
- PENDING (待确认) → CONFIRMED (已确认) → IN_PROGRESS (进行中) → COMPLETED (已完成)
- 可中断: CANCELLED (已取消), REJECTED (已拒绝)

### 回调机制
所有 ViewModel 提供 onDataChange 回调：
```typescript
viewModel.onDataChange(() => {
  this.data = viewModel.getData();
  this.isLoading = viewModel.isLoading();
});
```

### 分页加载
列表页面支持无限滚动分页：
- 每页20条数据
- 滚动到底自动加载更多
- 首次加载显示加载状态

### 错误处理
统一的错误处理策略：
- try-catch 捕获异常
- Logger 记录错误日志
- Toast 提示用户友好信息

## 贡献指南

### 开发流程
1. 使用 `superpowers:writing-plans` 技能制定详细计划
2. 使用 `superpowers:subagent-driven-development` 技能执行计划
3. 遵循项目现有架构和代码风格
4. 频繁提交，每个提交清晰可理解

### 测试
- 目前测试覆盖不足
- 后续需要补充单元测试和集成测试
- 建议使用 HarmonyOS 测试框架

### 文档
- 代码修改需要更新相关文档
- 新功能需要添加到 README
- 阶段完成需要更新总结文档

## 已知问题

### 占位功能
以下功能当前为占位实现，待后续完善：
- PhotoPicker 集成（真实照片上传）
- 日期时间选择器
- 地图位置选择
- WebSocket 实时消息推送
- 图片消息发送
- 智能推荐算法

### 待优化
- 缺少自动化测试
- 图片加载性能优化
- 虚拟列表（长列表性能）
- 离线缓存策略

## 版本历史

### v0.1.0 (2026-03-14)
- ✅ Phase 1: 用户管理
- ✅ Phase 2: 照片管理
- ✅ Phase 3: 社区交流
- ✅ Phase 4: 约拍匹配

### 计划中
- 🔄 Phase 5: 学习中心
- 🔄 Phase 6: 拍摄工具箱

## 许可证

[待定]

## 联系方式

- 项目地址: [待添加]
- 问题反馈: [待添加]

---

**最后更新**: 2026-03-14
