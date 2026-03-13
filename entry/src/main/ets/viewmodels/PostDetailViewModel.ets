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
