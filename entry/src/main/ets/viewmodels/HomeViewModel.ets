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
