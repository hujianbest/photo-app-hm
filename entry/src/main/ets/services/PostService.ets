import { HttpService } from './HttpService';
import { HttpResponse } from '../models/HttpResponse';
import { Post, CreatePostRequest, UpdatePostRequest } from '../models/Post';
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
