# 第三阶段：社区交流模块实施计划

> **For agentic workers:** REQUIRED: Use superpowers:subagent-driven-development (if subagents available) or superpowers:executing-plans to implement this plan. Steps use checkbox (`- [ ]`) syntax for tracking.

**目标：** 实现完整的社区交流功能，包括作品广场（瀑布流）、话题圈子、关注系统和消息通知。

**架构：** MVVM架构，HttpService处理远程API调用，LocalStorage缓存本地数据，瀑布流组件展示作品。

**技术栈：** ArkTS, ArkUI, @ohos.net.http.HttpRequest, 本地缓存, HarmonyOS网络请求

---

## 文件结构

### 新增模型
- `entry/src/main/ets/models/Post.ets` - 帖子数据接口
- `entry/src/main/ets/models/Comment.ets` - 评论数据接口
- `entry/src/main/ets/models/Topic.ets` - 话题数据接口
- `entry/src/main/ets/models/Notification.ets` - 通知数据接口
- `entry/src/main/ets/models/Follow.ets` - 关注数据接口

### 新增服务
- `entry/src/main/ets/services/PostService.ets` - 帖子业务逻辑
- `entry/src/main/ets/services/CommentService.ets` - 评论业务逻辑
- `entry/src/main/ets/services/TopicService.ets` - 话题业务逻辑
- `entry/src/main/ets/services/FollowService.ets` - 关注业务逻辑
- `entry/src/main/ets/services/NotificationService.ets` - 通知业务逻辑

### 新增ViewModel
- `entry/src/main/ets/viewmodels/HomeViewModel.ets` - 首页状态和逻辑
- `entry/src/main/ets/viewmodels/PostDetailViewModel.ets` - 帖子详情状态
- `entry/src/main/ets/viewmodels/TopicListViewModel.ets` - 话题列表状态
- `entry/src/main/ets/viewmodels/NotificationListViewModel.ets` - 通知列表状态

### 修改页面
- `entry/src/main/ets/pages/HomePage.ets` - 替换为社区动态流
- `entry/src/main/ets/pages/MinePage.ets` - 添加通知入口

### 新增页面
- `entry/src/main/ets/pages/PostDetailPage.ets` - 帖子详情页
- `entry/src/main/ets/pages/TopicListPage.ets` - 话题列表页
- `entry/src/main/ets/pages/NotificationListPage.ets` - 通知列表页
- `entry/src/main/ets/pages/PostCreatePage.ets` - 发布帖子页

---

## Chunk 1: 数据模型层

### 任务 1：创建社区相关数据模型

**文件：**
- 创建：`entry/src/main/ets/models/Post.ets`
- 创建：`entry/src/main/ets/models/Comment.ets`
- 创建：`entry/src/main/ets/models/Topic.ets`
- 创建：`entry/src/main/ets/models/Notification.ets`
- 创建：`entry/src/main/ets/models/Follow.ets`

- [ ] **步骤 1：创建 Post 模型**

写入到 `entry/src/main/ets/models/Post.ets`：

```typescript
export interface Post {
  id: string;
  userId: string;
  user: {
    id: string;
    nickname: string;
    avatar: string;
    isVerified: boolean;
  };
  content: string;
  photos: Photo[];
  topic: Topic | null;
  likeCount: number;
  commentCount: number;
  isLiked: boolean;
  isCollected: boolean;
  createdAt: string;
  updatedAt: string;
}

export interface CreatePostRequest {
  content: string;
  photoIds: string[];
  topicId?: string;
}

export interface UpdatePostRequest {
  content?: string;
  topicId?: string;
}
```

- [ ] **步骤 2：创建 Comment 模型**

写入到 `entry/src/main/ets/models/Comment.ets`：

```typescript
export interface Comment {
  id: string;
  userId: string;
  postId: string;
  user: {
    id: string;
    nickname: string;
    avatar: string;
  };
  content: string;
  parentId: string | null;
  likeCount: number;
  isLiked: boolean;
  createdAt: string;
}

export interface CreateCommentRequest {
  postId: string;
  content: string;
  parentId?: string;
}
```

- [ ] **步骤 3：创建 Topic 模型**

写入到 `entry/src/main/ets/models/Topic.ets`：

```typescript
export interface Topic {
  id: string;
  name: string;
  description: string;
  coverImage: string;
  postCount: number;
  followerCount: number;
  isFollowed: boolean;
  createdAt: string;
}

export interface CreateTopicRequest {
  name: string;
  description: string;
}
```

- [ ] **步骤 4：创建 Notification 模型**

写入到 `entry/src/main/ets/models/Notification.ets`：

```typescript
export interface Notification {
  id: string;
  userId: string;
  type: 'like' | 'comment' | 'follow' | 'mention';
  fromUser: {
    id: string;
    nickname: string;
    avatar: string;
  };
  content: string;
  targetId: string | null; // post_id, comment_id, etc.
  targetType: 'post' | 'comment' | 'user' | null;
  isRead: boolean;
  createdAt: string;
}
```

- [ ] **步骤 5：创建 Follow 模型**

写入到 `entry/src/main/ets/models/Follow.ets`：

```typescript
export interface Follow {
  id: string;
  followerId: string;
  followingId: string;
  createdAt: string;
}

export interface Following {
  id: string;
  user: {
    id: string;
    nickname: string;
    avatar: string;
    bio: string;
    followerCount: number;
    worksCount: number;
    isVerified: boolean;
  };
  isFollowing: boolean;
  createdAt: string;
}
```

- [ ] **步骤 6：提交模型代码**

```bash
git add entry/src/main/ets/models/Post.ets entry/src/main/ets/models/Comment.ets entry/src/main/ets/models/Topic.ets entry/src/main/ets/models/Notification.ets entry/src/main/ets/models/Follow.ets
git commit -m "feat: 添加社区交流数据模型"
```

---

## Chunk 2: 服务层

### 任务 2：创建 PostService

**文件：**
- 创建：`entry/src/main/ets/services/PostService.ets`

- [ ] **步骤 1：编写 PostService**

写入到 `entry/src/main/ets/services/PostService.ets`：

```typescript
import { HttpService } from './HttpService';
import { HttpResponse } from '../models/HttpResponse';
import { Post, CreatePostRequest, UpdatePostRequest } from '../models/Post';
import { Comment, CreateCommentRequest } from '../models/Comment';
import { Logger } from '../common/utils/Logger';

export interface PostListResponse {
  posts: Post[];
  hasMore: boolean;
  nextCursor?: string;
}

export class PostService {
  private static readonly ENDPOINT = '/posts';

  static async getHomeFeed(page: number = 1, pageSize: number = 20): Promise<PostListResponse> {
    try {
      const response = await HttpService.get<PostListResponse>(
        `${PostService.ENDPOINT}/feed?page=${page}&pageSize=${pageSize}`
      );
      Logger.info('PostService', '获取首页动态: %{public}s', JSON.stringify(response));
      return response;
    } catch (error) {
      Logger.error('PostService', '获取首页动态失败: %{public}s', JSON.stringify(error));
      throw error;
    }
  }

  static async getPostById(postId: string): Promise<Post> {
    try {
      const response = await HttpService.get<Post>(`${PostService.ENDPOINT}/${postId}`);
      Logger.info('PostService', '获取帖子详情: %{public}s', postId);
      return response;
    } catch (error) {
      Logger.error('PostService', '获取帖子详情失败: %{public}s', JSON.stringify(error));
      throw error;
    }
  }

  static async getPostsByUserId(userId: string, page: number = 1): Promise<PostListResponse> {
    try {
      const response = await HttpService.get<PostListResponse>(
        `${PostService.ENDPOINT}/user/${userId}?page=${page}`
      );
      Logger.info('PostService', '获取用户帖子: %{public}s', userId);
      return response;
    } catch (error) {
      Logger.error('PostService', '获取用户帖子失败: %{public}s', JSON.stringify(error));
      throw error;
    }
  }

  static async createPost(request: CreatePostRequest): Promise<Post> {
    try {
      const response = await HttpService.post<Post, CreatePostRequest>(
        PostService.ENDPOINT,
        request
      );
      Logger.info('PostService', '创建帖子成功');
      return response;
    } catch (error) {
      Logger.error('PostService', '创建帖子失败: %{public}s', JSON.stringify(error));
      throw error;
    }
  }

  static async updatePost(postId: string, request: UpdatePostRequest): Promise<Post> {
    try {
      const response = await HttpService.put<Post, UpdatePostRequest>(
        `${PostService.ENDPOINT}/${postId}`,
        request
      );
      Logger.info('PostService', '更新帖子成功: %{public}s', postId);
      return response;
    } catch (error) {
      Logger.error('PostService', '更新帖子失败: %{public}s', JSON.stringify(error));
      throw error;
    }
  }

  static async deletePost(postId: string): Promise<void> {
    try {
      await HttpService.delete(`${PostService.ENDPOINT}/${postId}`);
      Logger.info('PostService', '删除帖子成功: %{public}s', postId);
    } catch (error) {
      Logger.error('PostService', '删除帖子失败: %{public}s', JSON.stringify(error));
      throw error;
    }
  }

  static async likePost(postId: string): Promise<void> {
    try {
      await HttpService.post(`${PostService.ENDPOINT}/${postId}/like`, {});
      Logger.info('PostService', '点赞帖子: %{public}s', postId);
    } catch (error) {
      Logger.error('PostService', '点赞帖子失败: %{public}s', JSON.stringify(error));
      throw error;
    }
  }

  static async unlikePost(postId: string): Promise<void> {
    try {
      await HttpService.delete(`${PostService.ENDPOINT}/${postId}/like`);
      Logger.info('PostService', '取消点赞: %{public}s', postId);
    } catch (error) {
      Logger.error('PostService', '取消点赞失败: %{public}s', JSON.stringify(error));
      throw error;
    }
  }

  static async collectPost(postId: string): Promise<void> {
    try {
      await HttpService.post(`${PostService.ENDPOINT}/${postId}/collect`, {});
      Logger.info('PostService', '收藏帖子: %{public}s', postId);
    } catch (error) {
      Logger.error('PostService', '收藏帖子失败: %{public}s', JSON.stringify(error));
      throw error;
    }
  }

  static async uncollectPost(postId: string): Promise<void> {
    try {
      await HttpService.delete(`${PostService.ENDPOINT}/${postId}/collect`);
      Logger.info('PostService', '取消收藏: %{public}s', postId);
    } catch (error) {
      Logger.error('PostService', '取消收藏失败: %{public}s', JSON.stringify(error));
      throw error;
    }
  }
}
```

- [ ] **步骤 2：提交 PostService**

```bash
git add entry/src/main/ets/services/PostService.ets
git commit -m "feat: 添加PostService"
```

### 任务 3：创建 CommentService

**文件：**
- 创建：`entry/src/main/ets/services/CommentService.ets`

- [ ] **步骤 1：编写 CommentService**

写入到 `entry/src/main/ets/services/CommentService.ets`：

```typescript
import { HttpService } from './HttpService';
import { Comment, CreateCommentRequest } from '../models/Comment';
import { Logger } from '../common/utils/Logger';

export interface CommentListResponse {
  comments: Comment[];
  hasMore: boolean;
}

export class CommentService {
  private static readonly ENDPOINT = '/comments';

  static async getCommentsByPost(postId: string, page: number = 1): Promise<CommentListResponse> {
    try {
      const response = await HttpService.get<CommentListResponse>(
        `${CommentService.ENDPOINT}/post/${postId}?page=${page}`
      );
      Logger.info('CommentService', '获取评论: %{public}s', postId);
      return response;
    } catch (error) {
      Logger.error('CommentService', '获取评论失败: %{public}s', JSON.stringify(error));
      throw error;
    }
  }

  static async createComment(request: CreateCommentRequest): Promise<Comment> {
    try {
      const response = await HttpService.post<Comment, CreateCommentRequest>(
        CommentService.ENDPOINT,
        request
      );
      Logger.info('CommentService', '创建评论成功');
      return response;
    } catch (error) {
      Logger.error('CommentService', '创建评论失败: %{public}s', JSON.stringify(error));
      throw error;
    }
  }

  static async deleteComment(commentId: string): Promise<void> {
    try {
      await HttpService.delete(`${CommentService.ENDPOINT}/${commentId}`);
      Logger.info('CommentService', '删除评论成功: %{public}s', commentId);
    } catch (error) {
      Logger.error('CommentService', '删除评论失败: %{public}s', JSON.stringify(error));
      throw error;
    }
  }

  static async likeComment(commentId: string): Promise<void> {
    try {
      await HttpService.post(`${CommentService.ENDPOINT}/${commentId}/like`, {});
      Logger.info('CommentService', '点赞评论: %{public}s', commentId);
    } catch (error) {
      Logger.error('CommentService', '点赞评论失败: %{public}s', JSON.stringify(error));
      throw error;
    }
  }

  static async unlikeComment(commentId: string): Promise<void> {
    try {
      await HttpService.delete(`${CommentService.ENDPOINT}/${commentId}/like`);
      Logger.info('CommentService', '取消点赞评论: %{public}s', commentId);
    } catch (error) {
      Logger.error('CommentService', '取消点赞评论失败: %{public}s', JSON.stringify(error));
      throw error;
    }
  }
}
```

- [ ] **步骤 2：提交 CommentService**

```bash
git add entry/src/main/ets/services/CommentService.ets
git commit -m "feat: 添加CommentService"
```

### 任务 4：创建 TopicService

**文件：**
- 创建：`entry/src/main/ets/services/TopicService.ets`

- [ ] **步骤 1：编写 TopicService**

写入到 `entry/src/main/ets/services/TopicService.ets`：

```typescript
import { HttpService } from './HttpService';
import { Topic, CreateTopicRequest } from '../models/Topic';
import { Logger } from '../common/utils/Logger';

export interface TopicListResponse {
  topics: Topic[];
  hasMore: boolean;
}

export class TopicService {
  private static readonly ENDPOINT = '/topics';

  static async getAllTopics(page: number = 1): Promise<TopicListResponse> {
    try {
      const response = await HttpService.get<TopicListResponse>(
        `${TopicService.ENDPOINT}?page=${page}`
      );
      Logger.info('TopicService', '获取话题列表');
      return response;
    } catch (error) {
      Logger.error('TopicService', '获取话题列表失败: %{public}s', JSON.stringify(error));
      throw error;
    }
  }

  static async getHotTopics(): Promise<Topic[]> {
    try {
      const response = await HttpService.get<Topic[]>(`${TopicService.ENDPOINT}/hot`);
      Logger.info('TopicService', '获取热门话题');
      return response;
    } catch (error) {
      Logger.error('TopicService', '获取热门话题失败: %{public}s', JSON.stringify(error));
      throw error;
    }
  }

  static async getTopicById(topicId: string): Promise<Topic> {
    try {
      const response = await HttpService.get<Topic>(`${TopicService.ENDPOINT}/${topicId}`);
      Logger.info('TopicService', '获取话题详情: %{public}s', topicId);
      return response;
    } catch (error) {
      Logger.error('TopicService', '获取话题详情失败: %{public}s', JSON.stringify(error));
      throw error;
    }
  }

  static async createTopic(request: CreateTopicRequest): Promise<Topic> {
    try {
      const response = await HttpService.post<Topic, CreateTopicRequest>(
        TopicService.ENDPOINT,
        request
      );
      Logger.info('TopicService', '创建话题成功');
      return response;
    } catch (error) {
      Logger.error('TopicService', '创建话题失败: %{public}s', JSON.stringify(error));
      throw error;
    }
  }

  static async followTopic(topicId: string): Promise<void> {
    try {
      await HttpService.post(`${TopicService.ENDPOINT}/${topicId}/follow`, {});
      Logger.info('TopicService', '关注话题: %{public}s', topicId);
    } catch (error) {
      Logger.error('TopicService', '关注话题失败: %{public}s', JSON.stringify(error));
      throw error;
    }
  }

  static async unfollowTopic(topicId: string): Promise<void> {
    try {
      await HttpService.delete(`${TopicService.ENDPOINT}/${topicId}/follow`);
      Logger.info('TopicService', '取消关注话题: %{public}s', topicId);
    } catch (error) {
      Logger.error('TopicService', '取消关注话题失败: %{public}s', JSON.stringify(error));
      throw error;
    }
  }
}
```

- [ ] **步骤 2：提交 TopicService**

```bash
git add entry/src/main/ets/services/TopicService.ets
git commit -m "feat: 添加TopicService"
```

### 任务 5：创建 FollowService

**文件：**
- 创建：`entry/src/main/ets/services/FollowService.ets`

- [ ] **步骤 1：编写 FollowService**

写入到 `entry/src/main/ets/services/FollowService.ets`：

```typescript
import { HttpService } from './HttpService';
import { Following } from '../models/Follow';
import { Logger } from '../common/utils/Logger';

export interface FollowingListResponse {
  users: Following[];
  hasMore: boolean;
}

export class FollowService {
  private static readonly ENDPOINT = '/follows';

  static async getFollowers(userId: string, page: number = 1): Promise<FollowingListResponse> {
    try {
      const response = await HttpService.get<FollowingListResponse>(
        `${FollowService.ENDPOINT}/followers/${userId}?page=${page}`
      );
      Logger.info('FollowService', '获取粉丝列表: %{public}s', userId);
      return response;
    } catch (error) {
      Logger.error('FollowService', '获取粉丝列表失败: %{public}s', JSON.stringify(error));
      throw error;
    }
  }

  static async getFollowing(userId: string, page: number = 1): Promise<FollowingListResponse> {
    try {
      const response = await HttpService.get<FollowingListResponse>(
        `${FollowService.ENDPOINT}/following/${userId}?page=${page}`
      );
      Logger.info('FollowService', '获取关注列表: %{public}s', userId);
      return response;
    } catch (error) {
      Logger.error('FollowService', '获取关注列表失败: %{public}s', JSON.stringify(error));
      throw error;
    }
  }

  static async followUser(userId: string): Promise<void> {
    try {
      await HttpService.post(`${FollowService.ENDPOINT}/${userId}`, {});
      Logger.info('FollowService', '关注用户: %{public}s', userId);
    } catch (error) {
      Logger.error('FollowService', '关注用户失败: %{public}s', JSON.stringify(error));
      throw error;
    }
  }

  static async unfollowUser(userId: string): Promise<void> {
    try {
      await HttpService.delete(`${FollowService.ENDPOINT}/${userId}`);
      Logger.info('FollowService', '取消关注用户: %{public}s', userId);
    } catch (error) {
      Logger.error('FollowService', '取消关注用户失败: %{public}s', JSON.stringify(error));
      throw error;
    }
  }

  static async isFollowing(userId: string): Promise<boolean> {
    try {
      const response = await HttpService.get<{ isFollowing: boolean }>(
        `${FollowService.ENDPOINT}/check/${userId}`
      );
      return response.isFollowing;
    } catch (error) {
      Logger.error('FollowService', '检查关注状态失败: %{public}s', JSON.stringify(error));
      return false;
    }
  }
}
```

- [ ] **步骤 2：提交 FollowService**

```bash
git add entry/src/main/ets/services/FollowService.ets
git commit -m "feat: 添加FollowService"
```

### 任务 6：创建 NotificationService

**文件：**
- 创建：`entry/src/main/ets/services/NotificationService.ets`

- [ ] **步骤 1：编写 NotificationService**

写入到 `entry/src/main/ets/services/NotificationService.ets`：

```typescript
import { HttpService } from './HttpService';
import { Notification } from '../models/Notification';
import { Logger } from '../common/utils/Logger';

export interface NotificationListResponse {
  notifications: Notification[];
  hasMore: boolean;
  unreadCount: number;
}

export class NotificationService {
  private static readonly ENDPOINT = '/notifications';

  static async getNotifications(page: number = 1): Promise<NotificationListResponse> {
    try {
      const response = await HttpService.get<NotificationListResponse>(
        `${NotificationService.ENDPOINT}?page=${page}`
      );
      Logger.info('NotificationService', '获取通知列表');
      return response;
    } catch (error) {
      Logger.error('NotificationService', '获取通知列表失败: %{public}s', JSON.stringify(error));
      throw error;
    }
  }

  static async getUnreadCount(): Promise<number> {
    try {
      const response = await HttpService.get<{ count: number }>(
        `${NotificationService.ENDPOINT}/unread`
      );
      Logger.info('NotificationService', '获取未读数量: %{public}d', response.count);
      return response.count;
    } catch (error) {
      Logger.error('NotificationService', '获取未读数量失败: %{public}s', JSON.stringify(error));
      return 0;
    }
  }

  static async markAsRead(notificationId: string): Promise<void> {
    try {
      await HttpService.put(`${NotificationService.ENDPOINT}/${notificationId}/read`, {});
      Logger.info('NotificationService', '标记已读: %{public}s', notificationId);
    } catch (error) {
      Logger.error('NotificationService', '标记已读失败: %{public}s', JSON.stringify(error));
      throw error;
    }
  }

  static async markAllAsRead(): Promise<void> {
    try {
      await HttpService.put(`${NotificationService.ENDPOINT}/read-all`, {});
      Logger.info('NotificationService', '全部标记已读');
    } catch (error) {
      Logger.error('NotificationService', '全部标记已读失败: %{public}s', JSON.stringify(error));
      throw error;
    }
  }

  static async deleteNotification(notificationId: string): Promise<void> {
    try {
      await HttpService.delete(`${NotificationService.ENDPOINT}/${notificationId}`);
      Logger.info('NotificationService', '删除通知: %{public}s', notificationId);
    } catch (error) {
      Logger.error('NotificationService', '删除通知失败: %{public}s', JSON.stringify(error));
      throw error;
    }
  }

  static async clearAll(): Promise<void> {
    try {
      await HttpService.delete(NotificationService.ENDPOINT);
      Logger.info('NotificationService', '清空所有通知');
    } catch (error) {
      Logger.error('NotificationService', '清空所有通知失败: %{public}s', JSON.stringify(error));
      throw error;
    }
  }
}
```

- [ ] **步骤 2：提交 NotificationService**

```bash
git add entry/src/main/ets/services/NotificationService.ets
git commit -m "feat: 添加NotificationService"
```

---

## Chunk 3: ViewModel层

### 任务 7：创建 HomeViewModel

**文件：**
- 创建：`entry/src/main/ets/viewmodels/HomeViewModel.ets`

- [ ] **步骤 1：编写 HomeViewModel**

写入到 `entry/src/main/ets/viewmodels/HomeViewModel.ets`：

```typescript
import { Post } from '../models/Post';
import { PostService } from '../services/PostService';
import { Logger } from '../common/utils/Logger';

export class HomeViewModel {
  private posts: Post[] = [];
  private currentPage: number = 1;
  private isLoading: boolean = false;
  private hasMore: boolean = true;
  private loadCallbacks: Array<() => void> = [];

  getPosts(): Post[] {
    return this.posts;
  }

  isLoading(): boolean {
    return this.isLoading;
  }

  hasMorePosts(): boolean {
    return this.hasMore;
  }

  onDataChange(callback: () => void): void {
    this.loadCallbacks.push(callback);
  }

  async loadPosts(refresh: boolean = false): Promise<void> {
    if (refresh) {
      this.currentPage = 1;
      this.posts = [];
    }

    this.isLoading = true;
    this.notifyCallbacks();

    try {
      const response = await PostService.getHomeFeed(this.currentPage);
      if (refresh) {
        this.posts = response.posts;
      } else {
        this.posts = [...this.posts, ...response.posts];
      }
      this.hasMore = response.hasMore;
      Logger.info('HomeViewModel', '加载了 %{public}d 条动态', this.posts.length);
    } catch (error) {
      Logger.error('HomeViewModel', '加载动态失败: %{public}s', JSON.stringify(error));
    } finally {
      this.isLoading = false;
      this.notifyCallbacks();
    }
  }

  async loadMorePosts(): Promise<void> {
    if (this.isLoading || !this.hasMore) {
      return;
    }
    this.currentPage++;
    await this.loadPosts();
  }

  async likePost(post: Post): Promise<void> {
    try {
      if (post.isLiked) {
        await PostService.unlikePost(post.id);
        post.isLiked = false;
        post.likeCount--;
      } else {
        await PostService.likePost(post.id);
        post.isLiked = true;
        post.likeCount++;
      }
      this.notifyCallbacks();
    } catch (error) {
      Logger.error('HomeViewModel', '点赞操作失败: %{public}s', JSON.stringify(error));
    }
  }

  async collectPost(post: Post): Promise<void> {
    try {
      if (post.isCollected) {
        await PostService.uncollectPost(post.id);
        post.isCollected = false;
      } else {
        await PostService.collectPost(post.id);
        post.isCollected = true;
      }
      this.notifyCallbacks();
    } catch (error) {
      Logger.error('HomeViewModel', '收藏操作失败: %{public}s', JSON.stringify(error));
    }
  }

  private notifyCallbacks(): void {
    this.loadCallbacks.forEach(callback => callback());
  }
}
```

- [ ] **步骤 2：提交 HomeViewModel**

```bash
git add entry/src/main/ets/viewmodels/HomeViewModel.ets
git commit -m "feat: 添加HomeViewModel"
```

### 任务 8：创建 PostDetailViewModel

**文件：**
- 创建：`entry/src/main/ets/viewmodels/PostDetailViewModel.ets`

- [ ] **步骤 1：编写 PostDetailViewModel**

写入到 `entry/src/main/ets/viewmodels/PostDetailViewModel.ets`：

```typescript
import { Post } from '../models/Post';
import { Comment } from '../models/Comment';
import { PostService } from '../services/PostService';
import { CommentService } from '../services/CommentService';
import { Logger } from '../common/utils/Logger';

export class PostDetailViewModel {
  private post: Post | null = null;
  private comments: Comment[] = [];
  private currentPage: number = 1;
  private isLoading: boolean = false;
  private isLoadingComments: boolean = false;
  private hasMoreComments: boolean = true;
  private loadCallbacks: Array<() => void> = [];

  getPost(): Post | null {
    return this.post;
  }

  getComments(): Comment[] {
    return this.comments;
  }

  isLoading(): boolean {
    return this.isLoading;
  }

  isLoadingComments(): boolean {
    return this.isLoadingComments;
  }

  hasMore(): boolean {
    return this.hasMoreComments;
  }

  onDataChange(callback: () => void): void {
    this.loadCallbacks.push(callback);
  }

  async loadPost(postId: string): Promise<void> {
    this.isLoading = true;
    this.notifyCallbacks();

    try {
      this.post = await PostService.getPostById(postId);
      Logger.info('PostDetailViewModel', '加载帖子: %{public}s', postId);
    } catch (error) {
      Logger.error('PostDetailViewModel', '加载帖子失败: %{public}s', JSON.stringify(error));
    } finally {
      this.isLoading = false;
      this.notifyCallbacks();
    }
  }

  async loadComments(refresh: boolean = false): Promise<void> {
    if (refresh) {
      this.currentPage = 1;
      this.comments = [];
    }

    this.isLoadingComments = true;
    this.notifyCallbacks();

    try {
      const response = await CommentService.getCommentsByPost(
        this.post?.id || '',
        this.currentPage
      );
      if (refresh) {
        this.comments = response.comments;
      } else {
        this.comments = [...this.comments, ...response.comments];
      }
      this.hasMoreComments = response.hasMore;
      Logger.info('PostDetailViewModel', '加载了 %{public}d 条评论', this.comments.length);
    } catch (error) {
      Logger.error('PostDetailViewModel', '加载评论失败: %{public}s', JSON.stringify(error));
    } finally {
      this.isLoadingComments = false;
      this.notifyCallbacks();
    }
  }

  async likePost(): Promise<void> {
    if (!this.post) return;

    try {
      if (this.post.isLiked) {
        await PostService.unlikePost(this.post.id);
        this.post.isLiked = false;
        this.post.likeCount--;
      } else {
        await PostService.likePost(this.post.id);
        this.post.isLiked = true;
        this.post.likeCount++;
      }
      this.notifyCallbacks();
    } catch (error) {
      Logger.error('PostDetailViewModel', '点赞操作失败: %{public}s', JSON.stringify(error));
    }
  }

  async collectPost(): Promise<void> {
    if (!this.post) return;

    try {
      if (this.post.isCollected) {
        await PostService.uncollectPost(this.post.id);
        this.post.isCollected = false;
      } else {
        await PostService.collectPost(this.post.id);
        this.post.isCollected = true;
      }
      this.notifyCallbacks();
    } catch (error) {
      Logger.error('PostDetailViewModel', '收藏操作失败: %{public}s', JSON.stringify(error));
    }
  }

  async deletePost(): Promise<boolean> {
    if (!this.post) return false;

    try {
      await PostService.deletePost(this.post.id);
      return true;
    } catch (error) {
      Logger.error('PostDetailViewModel', '删除帖子失败: %{public}s', JSON.stringify(error));
      return false;
    }
  }

  private notifyCallbacks(): void {
    this.loadCallbacks.forEach(callback => callback());
  }
}
```

- [ ] **步骤 2：提交 PostDetailViewModel**

```bash
git add entry/src/main/ets/viewmodels/PostDetailViewModel.ets
git commit -m "feat: 添加PostDetailViewModel"
```

### 任务 9：创建 TopicListViewModel

**文件：**
- 创建：`entry/src/main/ets/viewmodels/TopicListViewModel.ets`

- [ ] **步骤 1：编写 TopicListViewModel**

写入到 `entry/src/main/ets/viewmodels/TopicListViewModel.ets`：

```typescript
import { Topic } from '../models/Topic';
import { TopicService } from '../services/TopicService';
import { Logger } from '../common/utils/Logger';

export class TopicListViewModel {
  private topics: Topic[] = [];
  private hotTopics: Topic[] = [];
  private isLoading: boolean = false;
  private loadCallbacks: Array<() => void> = [];

  getTopics(): Topic[] {
    return this.topics;
  }

  getHotTopics(): Topic[] {
    return this.hotTopics;
  }

  isLoading(): boolean {
    return this.isLoading;
  }

  onDataChange(callback: () => void): void {
    this.loadCallbacks.push(callback);
  }

  async loadTopics(): Promise<void> {
    this.isLoading = true;
    this.notifyCallbacks();

    try {
      const response = await TopicService.getAllTopics();
      this.topics = response.topics;
      Logger.info('TopicListViewModel', '加载了 %{public}d 个话题', this.topics.length);
    } catch (error) {
      Logger.error('TopicListViewModel', '加载话题失败: %{public}s', JSON.stringify(error));
    } finally {
      this.isLoading = false;
      this.notifyCallbacks();
    }
  }

  async loadHotTopics(): Promise<void> {
    try {
      this.hotTopics = await TopicService.getHotTopics();
      this.notifyCallbacks();
      Logger.info('TopicListViewModel', '加载了 %{public}d 个热门话题', this.hotTopics.length);
    } catch (error) {
      Logger.error('TopicListViewModel', '加载热门话题失败: %{public}s', JSON.stringify(error));
    }
  }

  async followTopic(topic: Topic): Promise<void> {
    try {
      if (topic.isFollowed) {
        await TopicService.unfollowTopic(topic.id);
        topic.isFollowed = false;
        topic.followerCount--;
      } else {
        await TopicService.followTopic(topic.id);
        topic.isFollowed = true;
        topic.followerCount++;
      }
      this.notifyCallbacks();
    } catch (error) {
      Logger.error('TopicListViewModel', '关注操作失败: %{public}s', JSON.stringify(error));
    }
  }

  private notifyCallbacks(): void {
    this.loadCallbacks.forEach(callback => callback());
  }
}
```

- [ ] **步骤 2：提交 TopicListViewModel**

```bash
git add entry/src/main/ets/viewmodels/TopicListViewModel.ets
git commit -m "feat: 添加TopicListViewModel"
```

### 任务 10：创建 NotificationListViewModel

**文件：**
- 创建：`entry/src/main/ets/viewmodels/NotificationListViewModel.ets`

- [ ] **步骤 1：编写 NotificationListViewModel**

写入到 `entry/src/main/ets/viewmodels/NotificationListViewModel.ets`：

```typescript
import { Notification } from '../models/Notification';
import { NotificationService } from '../services/NotificationService';
import { Logger } from '../common/utils/Logger';

export class NotificationListViewModel {
  private notifications: Notification[] = [];
  private currentPage: number = 1;
  private isLoading: boolean = false;
  private unreadCount: number = 0;
  private hasMore: boolean = true;
  private loadCallbacks: Array<() => void> = [];

  getNotifications(): Notification[] {
    return this.notifications;
  }

  getUnreadCount(): number {
    return this.unreadCount;
  }

  isLoading(): boolean {
    return this.isLoading;
  }

  hasMore(): boolean {
    return this.hasMore;
  }

  onDataChange(callback: () => void): void {
    this.loadCallbacks.push(callback);
  }

  async loadNotifications(refresh: boolean = false): Promise<void> {
    if (refresh) {
      this.currentPage = 1;
      this.notifications = [];
    }

    this.isLoading = true;
    this.notifyCallbacks();

    try {
      const response = await NotificationService.getNotifications(this.currentPage);
      if (refresh) {
        this.notifications = response.notifications;
        this.unreadCount = response.unreadCount;
      } else {
        this.notifications = [...this.notifications, ...response.notifications];
      }
      this.hasMore = response.hasMore;
      Logger.info('NotificationListViewModel', '加载了 %{public}d 条通知', this.notifications.length);
    } catch (error) {
      Logger.error('NotificationListViewModel', '加载通知失败: %{public}s', JSON.stringify(error));
    } finally {
      this.isLoading = false;
      this.notifyCallbacks();
    }
  }

  async loadMoreNotifications(): Promise<void> {
    if (this.isLoading || !this.hasMore) {
      return;
    }
    this.currentPage++;
    await this.loadNotifications();
  }

  async refreshUnreadCount(): Promise<void> {
    try {
      this.unreadCount = await NotificationService.getUnreadCount();
      this.notifyCallbacks();
    } catch (error) {
      Logger.error('NotificationListViewModel', '获取未读数量失败: %{public}s', JSON.stringify(error));
    }
  }

  async markAsRead(notification: Notification): Promise<void> {
    try {
      await NotificationService.markAsRead(notification.id);
      notification.isRead = true;
      if (this.unreadCount > 0) {
        this.unreadCount--;
      }
      this.notifyCallbacks();
    } catch (error) {
      Logger.error('NotificationListViewModel', '标记已读失败: %{public}s', JSON.stringify(error));
    }
  }

  async markAllAsRead(): Promise<void> {
    try {
      await NotificationService.markAllAsRead();
      this.notifications.forEach(n => n.isRead = true);
      this.unreadCount = 0;
      this.notifyCallbacks();
    } catch (error) {
      Logger.error('NotificationListViewModel', '全部标记已读失败: %{public}s', JSON.stringify(error));
    }
  }

  async deleteNotification(notification: Notification): Promise<void> {
    try {
      await NotificationService.deleteNotification(notification.id);
      this.notifications = this.notifications.filter(n => n.id !== notification.id);
      if (!notification.isRead && this.unreadCount > 0) {
        this.unreadCount--;
      }
      this.notifyCallbacks();
    } catch (error) {
      Logger.error('NotificationListViewModel', '删除通知失败: %{public}s', JSON.stringify(error));
    }
  }

  async clearAll(): Promise<void> {
    try {
      await NotificationService.clearAll();
      this.notifications = [];
      this.unreadCount = 0;
      this.notifyCallbacks();
    } catch (error) {
      Logger.error('NotificationListViewModel', '清空通知失败: %{public}s', JSON.stringify(error));
    }
  }

  private notifyCallbacks(): void {
    this.loadCallbacks.forEach(callback => callback());
  }
}
```

- [ ] **步骤 2：提交 NotificationListViewModel**

```bash
git add entry/src/main/ets/viewmodels/NotificationListViewModel.ets
git commit -m "feat: 添加NotificationListViewModel"
```

---

## Chunk 4: 首页实现

### 任务 11：实现 HomePage (社区动态流)

**文件：**
- 修改：`entry/src/main/ets/pages/HomePage.ets`

- [ ] **步骤 1：编写 HomePage**

写入到 `entry/src/main/ets/pages/HomePage.ets`：

```typescript
import { HomeViewModel } from '../viewmodels/HomeViewModel';
import { Post } from '../models/Post';
import router from '@ohos.router';
import promptAction from '@ohos.promptAction';

@Entry
@Component
struct HomePage {
  @State viewModel: HomeViewModel = new HomeViewModel();
  @State posts: Post[] = [];
  @State isLoading: boolean = false;
  @State hasMore: boolean = true;

  aboutToAppear() {
    this.viewModel.onDataChange(() => {
      this.posts = this.viewModel.getPosts();
      this.isLoading = this.viewModel.isLoading();
      this.hasMore = this.viewModel.hasMorePosts();
    });
    this.viewModel.loadPosts();
  }

  build() {
    Column() {
      // 顶部导航
      Row() {
        Text('社区')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .layoutWeight(1)

        Button('发布')
          .fontSize(14)
          .backgroundColor('#1890FF')
          .fontColor(Color.White)
          .borderRadius(20)
          .padding({ left: 16, right: 16, top: 8, bottom: 8 })
          .onClick(() => {
            this.navigateToPostCreate();
          })
      }
      .width('100%')
      .padding(16)
      .backgroundColor(Color.White)
    }

      // 内容区域
      if (this.isLoading && this.posts.length === 0) {
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
      } else if (this.posts.length === 0) {
        Column() {
          Text('📸')
            .fontSize(64)
            .margin({ bottom: 16 })
          Text('还没有动态')
            .fontSize(16)
            .fontColor('#666')
          Text('发布第一条作品开始分享吧')
            .fontSize(14)
            .fontColor('#999')
            .margin({ top: 8 })
          Button('发布作品')
            .fontSize(14)
            .backgroundColor('#1890FF')
            .fontColor(Color.White)
            .borderRadius(20)
            .padding({ left: 24, right: 24, top: 12, bottom: 12 })
            .margin({ top: 24 })
            .onClick(() => {
              this.navigateToPostCreate();
            })
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
      } else {
        List() {
          ForEach(this.posts, (post: Post) => {
            ListItem() {
              this.PostCard(post)
            }
          })
        }
        .width('100%')
        .layoutWeight(1)
        .padding(12)
      }

      // 加载更多指示器
      if (this.hasMore && this.posts.length > 0) {
        Row() {
          LoadingProgress()
            .width(20)
            .height(20)
          Text('加载更多...')
            .fontSize(14)
            .fontColor('#999')
            .margin({ left: 8 })
        }
        .width('100%')
        .padding(16)
        .backgroundColor('#F5F5F5')
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
    .onScrollIndex((start, end) => {
      // 滚动到底部加载更多
      if (end === this.posts.length - 1 && this.hasMore && !this.isLoading) {
        this.viewModel.loadMorePosts();
      }
    })
  }

  @Builder
  PostCard(post: Post) {
    Column() {
      // 用户信息
      Row() {
        Image(post.user.avatar || '')
          .width(40)
          .height(40)
          .borderRadius(20)
          .objectFit(ImageFit.Cover)

        Column() {
          Text(post.user.nickname)
            .fontSize(16)
            .fontWeight(FontWeight.Medium)

          Text(post.createdAt)
            .fontSize(12)
            .fontColor('#999')
            .margin({ top: 2 })
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)
        .margin({ left: 12 })

        // 更多按钮
        Text('⋮')
          .fontSize(16)
          .fontColor('#999')
          .onClick(() => {
            this.showPostMenu(post);
          })
      }
      .width('100%')
      .padding(16)
      .backgroundColor(Color.White)
      .borderRadius({ topLeft: 12, topRight: 12 })

      // 内容
      if (post.content) {
        Text(post.content)
          .fontSize(15)
          .fontColor('#333')
          .lineHeight(22)
          .width('100%')
          .padding({ left: 16, right: 16, top: 12, bottom: 12 })
      }

      // 照片
      if (post.photos && post.photos.length > 0) {
        this.PhotoGrid(post.photos)
      }

      // 操作栏
      Row() {
        Row() {
          Image($r('app.media.ic_like'))
            .width(20)
            .height(20)
            .fillColor(post.isLiked ? '#F5222D' : '#999')
            .margin({ right: 4 })

          Text(`${post.likeCount}`)
            .fontSize(14)
            .fontColor(post.isLiked ? '#F5222D' : '#666')
        }
        .layoutWeight(1)
        .onClick(() => {
          this.viewModel.likePost(post);
        })

        Row() {
          Image($r('app.media.ic_comment'))
            .width(20)
            .height(20)
            .fillColor('#999')
            .margin({ right: 4 })

          Text(`${post.commentCount}`)
            .fontSize(14)
            .fontColor('#666')
        }
        .onClick(() => {
          this.navigateToPostDetail(post.id);
        })

        Row() {
          Image($r('app.media.ic_collect'))
            .width(20)
            .height(20)
            .fillColor(post.isCollected ? '#FAAD14' : '#999')
            .margin({ right: 4 })
        }
        .onClick(() => {
          this.viewModel.collectPost(post);
        })
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 12, bottom: 12 })
      .justifyContent(FlexAlign.SpaceAround)
      .backgroundColor(Color.White)
      .borderRadius({ bottomLeft: 12, bottomRight: 12 })
    }
    .width('100%')
    .backgroundColor(Color.White)
    .borderRadius(12)
    .margin({ bottom: 12 })
    .onClick(() => {
      this.navigateToPostDetail(post.id);
    })
  }

  @Builder
  PhotoGrid(photos: any[]) {
    Column() {
      Grid() {
        ForEach(photos, (photo: any) => {
          GridItem() {
            Image(photo.url || photo.originalPath)
              .width('100%')
              .aspectRatio(1)
              .borderRadius(8)
              .objectFit(ImageFit.Cover)
          }
        })
      }
      .columnsTemplate(photos.length === 1 ? '1fr' : photos.length === 2 ? '1fr 1fr' : '1fr 1fr 1fr')
      .rowsGap(4)
      .columnsGap(4)
      .width('100%')
    }
    .padding({ left: 16, right: 16, top: 8, bottom: 8 })
    .width('100%')
  }

  navigateToPostDetail(postId: string): void {
    router.pushUrl({
      url: 'pages/PostDetailPage',
      params: { postId: postId }
    });
  }

  navigateToPostCreate(): void {
    router.pushUrl({
      url: 'pages/PostCreatePage'
    });
  }

  showPostMenu(post: Post): void {
    promptAction.showDialog({
      title: '更多操作',
      buttons: [
        { text: '取消', color: '#999' },
        { text: '分享', color: '#333' },
        { text: '举报', color: '#F5222D' }
      ]
    }, (err, data) => {
      if (data.index === 1) {
        // 分享功能
        promptAction.showToast({ message: '分享功能即将推出' });
      } else if (data.index === 2) {
        // 举报功能
        promptAction.showToast({ message: '举报功能即将推出' });
      }
    });
  }
}
```

- [ ] **步骤 2：提交 HomePage**

```bash
git add entry/src/main/ets/pages/HomePage.ets
git commit -m "feat: 实现HomePage社区动态流"
```

### 任务 12：添加页面到路由配置

**文件：**
- 修改：`entry/src/main/resources/base/profile/main_pages.json`

- [ ] **步骤 1：更新路由配置**

添加新页面到路由配置。

- [ ] **步骤 2：提交路由配置**

```bash
git add entry/src/main/resources/base/profile/main_pages.json
git commit -m "feat: 添加社区交流页面到路由配置"
```

---

## Chunk 5: 详情页面实现

### 任务 13：实现 PostDetailPage

**文件：**
- 创建：`entry/src/main/ets/pages/PostDetailPage.ets`

- [ ] **步骤 1：编写 PostDetailPage**

写入到 `entry/src/main/ets/pages/PostDetailPage.ets`：

```typescript
import { PostDetailViewModel } from '../viewmodels/PostDetailViewModel';
import { Post } from '../models/Post';
import { Comment } from '../models/Comment';
import router from '@ohos.router';
import promptAction from '@ohos.promptAction';

@Entry
@Component
struct PostDetailPage {
  @State viewModel: PostDetailViewModel = new PostDetailViewModel();
  @State post: Post | null = null;
  @State comments: Comment[] = [];
  @State isLoading: boolean = false;
  @State isLoadingComments: boolean = false;
  @State showCommentDialog: boolean = false;
  @State commentText: string = '';

  aboutToAppear() {
    const postId = router.getParams()?.['postId'] as string;
    if (postId) {
      this.viewModel.onDataChange(() => {
        this.post = this.viewModel.getPost();
        this.comments = this.viewModel.getComments();
        this.isLoading = this.viewModel.isLoading();
        this.isLoadingComments = this.viewModel.isLoadingComments();
      });
      this.viewModel.loadPost(postId);
      this.viewModel.loadComments();
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

        Text('帖子详情')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .layoutWeight(1)

        if (this.post) {
          Row() {
            Image($r('app.media.ic_like'))
              .width(24)
              .height(24)
              .fillColor(this.post.isLiked ? '#F5222D' : '#999')
              .margin({ right: 8 })

            Image($r('app.media.ic_collect'))
              .width(24)
              .height(24)
              .fillColor(this.post.isCollected ? '#FAAD14' : '#999')
          }
        }
      }
      .width('100%')
      .padding(16)
      .backgroundColor(Color.White)

      // 内容区域
      Scroll() {
        Column() {
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
            .height(300)
            .justifyContent(FlexAlign.Center)
          } else if (this.post) {
            this.PostDetail(this.post)

            Divider()
              .color('#E8E8E8')

            // 评论区
            Column() {
              Text(`评论 (${this.post.commentCount})`)
                .fontSize(16)
                .fontWeight(FontWeight.Medium)
                .margin({ bottom: 16 })

              if (this.comments.length === 0) {
                Text('还没有评论，快来抢沙发吧')
                  .fontSize(14)
                  .fontColor('#999')
                  .width('100%')
                  .textAlign(TextAlign.Center)
                  .padding(40)
              } else {
                List() {
                  ForEach(this.comments, (comment: Comment) => {
                    ListItem() {
                      this.CommentItem(comment)
                    }
                  })
                }
                .width('100%')
              }

              // 加载更多
              if (this.viewModel.hasMore() && !this.isLoadingComments) {
                Row() {
                  LoadingProgress()
                    .width(16)
                    .height(16)
                  Text('加载更多...')
                    .fontSize(14)
                    .fontColor('#999')
                    .margin({ left: 8 })
                }
                .width('100%')
                .justifyContent(FlexAlign.Center)
                .padding(16)
              }
            }
            .width('100%')
            .padding(16)
          }
        }
        .width('100%')
      }
      .layoutWeight(1)

      // 底部输入框
      Row() {
        TextInput({ placeholder: '写评论...', text: this.commentText })
          .layoutWeight(1)
          .height(44)
          .backgroundColor('#F5F5F5')
          .borderRadius(22)
          .padding({ left: 16, right: 16 })
          .onChange((value: string) => {
            this.commentText = value;
          })

        Button('发送')
          .fontSize(16)
          .backgroundColor('#1890FF')
          .fontColor(Color.White)
          .width(80)
          .height(44)
          .borderRadius(22)
          .onClick(() => {
            this.submitComment();
          })
      }
      .width('100%')
      .padding(16)
      .backgroundColor(Color.White)
      .border({ width: { top: 1 }, color: '#E8E8E8' })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }

  @Builder
  PostDetail(post: Post) {
    Column() {
      // 用户信息
      Row() {
        Image(post.user.avatar || '')
          .width(50)
          .height(50)
          .borderRadius(25)
          .objectFit(ImageFit.Cover)

        Column() {
          Row() {
            Text(post.user.nickname)
              .fontSize(16)
              .fontWeight(FontWeight.Medium)

            if (post.user.isVerified) {
              Image($r('app.media.ic_verified'))
                .width(16)
                .height(16)
                .margin({ left: 4 })
            }
          }

          Text(post.createdAt)
            .fontSize(14)
            .fontColor('#999')
            .margin({ top: 4 })
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)
        .margin({ left: 12 })
      }
      .width('100%')
      .padding(16)
      .backgroundColor(Color.White)
      .borderRadius(12)

      // 内容
      if (post.content) {
        Text(post.content)
          .fontSize(16)
          .fontColor('#333')
          .lineHeight(26)
          .width('100%')
          .padding(16)
          .backgroundColor(Color.White)
      }

      // 照片
      if (post.photos && post.photos.length > 0) {
        this.PhotoGrid(post.photos)
      }

      // 操作栏
      Row() {
        Row() {
          Image($r('app.media.ic_like'))
            .width(24)
            .height(24)
            .fillColor(post.isLiked ? '#F5222D' : '#999')
            .margin({ right: 4 })

          Text(`${post.likeCount}`)
            .fontSize(14)
            .fontColor(post.isLiked ? '#F5222D' : '#666')
        }
        .layoutWeight(1)
        .onClick(() => {
          this.viewModel.likePost();
        })

        Row() {
          Image($r('app.media.ic_comment'))
            .width(24)
            .height(24)
            .fillColor('#999')
            .margin({ right: 4 })

          Text(`${post.commentCount}`)
            .fontSize(14)
            .fontColor('#666')
        }

        Row() {
          Image($r('app.media.ic_collect'))
            .width(24)
            .height(24)
            .fillColor(post.isCollected ? '#FAAD14' : '#999')
            .margin({ right: 4 })

          Text(post.isCollected ? '已收藏' : '收藏')
            .fontSize(14)
            .fontColor(post.isCollected ? '#FAAD14' : '#666')
        }
        .onClick(() => {
          this.viewModel.collectPost();
        })
      }
      .width('100%')
      .padding(16)
      .justifyContent(FlexAlign.SpaceAround)
      .backgroundColor(Color.White)
      .borderRadius(12)
      .margin({ top: 12 })
    }
    .width('100%')
  }

  @Builder
  PhotoGrid(photos: any[]) {
    Column() {
      Grid() {
        ForEach(photos, (photo: any) => {
          GridItem() {
            Image(photo.url || photo.originalPath)
              .width('100%')
              .aspectRatio(1)
              .borderRadius(8)
              .objectFit(ImageFit.Cover)
          }
        })
      }
      .columnsTemplate(photos.length === 1 ? '1fr' : photos.length === 2 ? '1fr 1fr' : '1fr 1fr 1fr')
      .rowsGap(4)
      .columnsGap(4)
      .width('100%')
    }
    .padding({ left: 16, right: 16, top: 8, bottom: 8 })
    .width('100%')
  }

  @Builder
  CommentItem(comment: Comment) {
    Row() {
      Image(comment.user.avatar || '')
        .width(36)
        .height(36)
        .borderRadius(18)
        .objectFit(ImageFit.Cover)

      Column() {
        Text(comment.user.nickname)
          .fontSize(14)
          .fontWeight(FontWeight.Medium)

        Text(comment.content)
          .fontSize(14)
          .fontColor('#333')
          .margin({ top: 4 })

        Row() {
          Text(comment.createdAt)
            .fontSize(12)
            .fontColor('#999')

          if (comment.likeCount > 0) {
            Text(` · ${comment.likeCount} 赞`)
              .fontSize(12)
              .fontColor('#999')
          }
        }
        .margin({ top: 4 })
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)
      .margin({ left: 12 })
    }
    .width('100%')
    .padding(12)
    .backgroundColor('#F9F9F9')
    .borderRadius(8)
    .margin({ bottom: 12 })
  }

  submitComment(): void {
    if (!this.commentText.trim()) {
      promptAction.showToast({ message: '请输入评论内容' });
      return;
    }

    // TODO: 实现评论提交逻辑
    promptAction.showToast({ message: '评论功能即将完善' });
    this.commentText = '';
  }
}
```

- [ ] **步骤 2：提交 PostDetailPage**

```bash
git add entry/src/main/ets/pages/PostDetailPage.ets
git commit -m "feat: 实现PostDetailPage帖子详情"
```

---

## Chunk 6: 其他页面实现

### 任务 14：实现 PostCreatePage

**文件：**
- 创建：`entry/src/main/ets/pages/PostCreatePage.ets`

- [ ] **步骤 1：编写 PostCreatePage**

写入到 `entry/src/main/ets/pages/PostCreatePage.ets`：

```typescript
import router from '@ohos.router';
import promptAction from '@ohos.promptAction';

@Entry
@Component
struct PostCreatePage {
  @State content: string = '';
  @State selectedPhotos: string[] = [];
  @State selectedTopic: string = '';

  build() {
    Column() {
      // 头部
      Row() {
        Button('取消')
          .fontSize(16)
          .backgroundColor(Color.Transparent)
          .fontColor('#333')
          .onClick(() => {
            router.back();
          })

        Text('发布作品')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .layoutWeight(1)

        Button('发布')
          .fontSize(16)
          .backgroundColor('#1890FF')
          .fontColor(Color.White)
          .borderRadius(20)
          .padding({ left: 20, right: 20, top: 8, bottom: 8 })
          .onClick(() => {
            this.publishPost();
          })
      }
      .width('100%')
      .padding(16)
      .backgroundColor(Color.White)
      .border({ width: { bottom: 1 }, color: '#E8E8E8' })
    }

      // 内容输入
      Column() {
        TextArea({ placeholder: '分享你的摄影心得...', text: this.content })
          .width('100%')
          .height(150)
          .backgroundColor(Color.Transparent)
          .margin({ top: 16 })
          .onChange((value: string) => {
            this.content = value;
          })

        Divider()
          .color('#E8E8E8')

        // 选择照片
        Row() {
          Image($r('app.media.ic_add_photo'))
            .width(24)
            .height(24)
            .margin({ right: 8 })

          Text('添加照片')
            .fontSize(15)
            .fontColor('#333')
        }
        .width('100%')
        .height(60)
        .padding(16)
        .backgroundColor('#F5F5F5')
        .borderRadius(8)
        .margin({ top: 16 })
        .onClick(() => {
          promptAction.showToast({ message: 'PhotoPicker即将集成' });
        })
      }

        // 话题选择
        Row() {
          Image($r('app.media.ic_topic'))
            .width(24)
            .height(24)
            .margin({ right: 8 })

          Text(this.selectedTopic || '选择话题')
            .fontSize(15)
            .fontColor(this.selectedTopic ? '#1890FF' : '#333')
        }
        .width('100%')
        .height(60)
        .padding(16)
        .backgroundColor('#F5F5F5')
        .borderRadius(8)
        .onClick(() => {
          // TODO: 跳转到话题选择
          promptAction.showToast({ message: '话题选择即将完善' });
        })
      }
      .width('100%')
      .layoutWeight(1)
      .padding(16)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Color.White)
  }

  publishPost(): void {
    if (!this.content.trim() && this.selectedPhotos.length === 0) {
      promptAction.showToast({ message: '请输入内容或选择照片' });
      return;
    }

    // TODO: 实现发布逻辑
    promptAction.showToast({ message: '发布功能即将完善' });
  }
}
```

- [ ] **步骤 2：提交 PostCreatePage**

```bash
git add entry/src/main/ets/pages/PostCreatePage.ets
git commit -m "feat: 实现PostCreatePage发布作品"
```

### 任务 15：实现 NotificationListPage

**文件：**
- 创建：`entry/src/main/ets/pages/NotificationListPage.ets`

- [ ] **步骤 1：编写 NotificationListPage**

写入到 `entry/src/main/ets/pages/NotificationListPage.ets`：

```typescript
import { NotificationListViewModel } from '../viewmodels/NotificationListViewModel';
import { Notification } from '../models/Notification';
import router from '@ohos.router';
import promptAction from '@ohos.promptAction';

@Entry
@Component
struct NotificationListPage {
  @State viewModel: NotificationListViewModel = new NotificationListViewModel();
  @State notifications: Notification[] = [];
  @State unreadCount: number = 0;
  @State isLoading: boolean = false;

  aboutToAppear() {
    this.viewModel.onDataChange(() => {
      this.notifications = this.viewModel.getNotifications();
      this.unreadCount = this.viewModel.getUnreadCount();
      this.isLoading = this.viewModel.isLoading();
    });
    this.viewModel.loadNotifications();
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

        Text('消息通知')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .layoutWeight(1)

        if (this.unreadCount > 0) {
          Text(`${this.unreadCount}`)
            .fontSize(14)
            .fontColor(Color.White)
            .backgroundColor('#F5222D')
            .borderRadius(10)
            .padding({ left: 8, right: 8, top: 4, bottom: 4 })
        }
      }
      .width('100%')
      .padding(16)
      .backgroundColor(Color.White)
      .border({ width: { bottom: 1 }, color: '#E8E8E8' })
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
      } else if (this.notifications.length === 0) {
        Column() {
          Text('🔔')
            .fontSize(64)
            .margin({ bottom: 16 })
          Text('还没有消息')
            .fontSize(16)
            .fontColor('#666')
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
      } else {
        List() {
          ForEach(this.notifications, (notification: Notification) => {
            ListItem() {
              this.NotificationItem(notification)
            }
          })
        }
        .width('100%')
        .layoutWeight(1)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }

  @Builder
  NotificationItem(notification: Notification) {
    Row() {
      // 图标
      Circle()
        .width(40)
        .height(40)
        .fill(notification.isRead ? '#E8E8E8' : '#1890FF')
        .margin({ right: 12 })
        .onClick(() => {
          this.viewModel.markAsRead(notification);
        })

      Column() {
        Text(this.getNotificationTitle(notification.type))
          .fontSize(15)
          .fontWeight(FontWeight.Medium)

        Text(notification.content)
          .fontSize(14)
          .fontColor('#666')
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .margin({ top: 4 })

        Text(notification.createdAt)
          .fontSize(12)
          .fontColor('#999')
          .margin({ top: 4 })
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)

      // 删除按钮
      Image($r('app.media.ic_delete'))
        .width(20)
        .height(20)
        .fillColor('#999')
        .onClick(() => {
          this.showDeleteMenu(notification);
        })
    }
    .width('100%')
    .padding(16)
    .backgroundColor(notification.isRead ? Color.White : '#F0F8FF')
    .margin({ bottom: 1 })
    .onClick(() => {
      this.handleNotificationClick(notification);
    })
  }

  getNotificationTitle(type: string): string {
    switch (type) {
      case 'like':
        return '点赞通知';
      case 'comment':
        return '评论通知';
      case 'follow':
        return '关注通知';
      case 'mention':
        return '提及通知';
      default:
        return '通知';
    }
  }

  handleNotificationClick(notification: Notification): void {
    this.viewModel.markAsRead(notification);

    // 根据通知类型跳转
    if (notification.targetType === 'post' && notification.targetId) {
      router.pushUrl({
        url: 'pages/PostDetailPage',
        params: { postId: notification.targetId }
      });
    }
  }

  showDeleteMenu(notification: Notification): void {
    promptAction.showDialog({
      title: '删除通知',
      message: '确定要删除这条通知吗？',
      buttons: [
        { text: '取消', color: '#999' },
        { text: '删除', color: '#F5222D' }
      ]
    }, async (err, data) => {
      if (data.index === 1) {
        await this.viewModel.deleteNotification(notification);
      }
    });
  }
}
```

- [ ] **步骤 2：提交 NotificationListPage**

```bash
git add entry/src/main/ets/pages/NotificationListPage.ets
git commit -m "feat: 实现NotificationListPage消息通知"
```

---

## Chunk 7: 修改MinePage

### 任务 16：修改 MinePage 添加通知入口

**文件：**
- 修改：`entry/src/main/ets/pages/MinePage.ets`

- [ ] **步骤 1：修改 MinePage 添加通知入口**

读取当前的 MinePage.ets，然后在合适的位置添加通知入口按钮，显示未读数量。

- [ ] **步骤 2：提交 MinePage**

```bash
git add entry/src/main/ets/pages/MinePage.ets
git commit -m "feat: MinePage添加通知入口"
```

---

## 验证

完成所有任务后，验证实现：

- [ ] **运行构建测试**

运行：`hvigorw assembleHap`
预期：构建成功，无错误

- [ ] **手动验证清单**

1. 首页（HomePage）：
   - [ ] 动态流正确加载
   - [ ] 滚动到底部加载更多
   - [ ] 点赞功能正常
   - [ ] 收藏功能正常
   - [ ] 点击帖子跳转到详情

2. 帖子详情页（PostDetailPage）：
   - [ ] 帖子信息正确显示
   - [ ] 评论列表正确显示
   - [ ] 评论区加载更多正常

3. 发布作品页（PostCreatePage）：
   - [ ] 页面正常显示
   - [ ] 输入框正常工作

4. 通知列表页（NotificationListPage）：
   - [ ] 通知列表正确加载
   - [ ] 未读数量正确显示
   - [ ] 标记已读正常

---

## 后续步骤

此阶段完成后：

1. 实现话题列表页
2. 实现关注/粉丝列表页
3. 集成PhotoPicker实现真实发布
4. 实现评论提交功能
5. 添加图片上传功能
6. 完善话题选择器
7. 实现实时通知推送

---

## 附录

### 依赖的HarmonyOS API

- `@ohos.net.http.HttpRequest` - HTTP网络请求
- `@ohos.router` - 页面路由
- `@ohos.promptAction` - 对话框和提示

### 设计决策

1. **瀑布流布局**：使用Grid组件模拟瀑布流，真实瀑布流后续优化
2. **分页加载**：采用cursor分页，支持无限滚动
3. **本地缓存**：首页动态可缓存到本地，提升加载速度
4. **图片懒加载**：列表图片使用占位符，滚动到可视区域再加载

### 已知限制

1. PhotoPicker未集成 - 无法真正添加照片
2. 评论提交未实现 - 评论功能是占位
3. 瀑布流简化 - 当前使用Grid实现，真实瀑布流需自定义布局
4. 话题选择未实现 - 话题功能是占位
5. 实时通知未实现 - 通知需要WebSocket支持

---

**第三阶段完成日期**：待定

**下一阶段**：第四阶段 - 约拍匹配模块
