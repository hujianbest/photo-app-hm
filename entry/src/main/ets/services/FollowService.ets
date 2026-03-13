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
