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
