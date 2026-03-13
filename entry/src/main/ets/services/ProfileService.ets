import { HttpService } from './HttpService';
import { HttpResponse } from '../models/HttpResponse';
import { BookingProfile, ProfileResponse, BookingFilters } from '../models/BookingProfile';
import { Logger } from '../common/utils/Logger';

export interface ProfileListResponse {
  profiles: BookingProfile[];
  hasMore: boolean;
  nextCursor?: string;
}

export class ProfileService {
  private static readonly ENDPOINT = '/profiles';

  static async getMyProfile(): Promise<BookingProfile> {
    try {
      const response = await HttpService.get<BookingProfile>(`${ProfileService.ENDPOINT}/my`);
      Logger.info('ProfileService', '获取我的档案');
      return response;
    } catch (error) {
      Logger.error('ProfileService', '获取我的档案失败');
      throw error;
    }
  }

  static async getProfileById(userId: string): Promise<ProfileResponse> {
    try {
      const response = await HttpService.get<ProfileResponse>(`${ProfileService.ENDPOINT}/${userId}`);
      Logger.info('ProfileService', '获取用户档案: %{public}s', userId);
      return response;
    } catch (error) {
      Logger.error('ProfileService', '获取用户档案失败');
      throw error;
    }
  }

  static async searchProfiles(filters: BookingFilters): Promise<ProfileListResponse> {
    try {
      const params = new URLSearchParams();
      if (filters.role) params.append('role', filters.role);
      if (filters.style) params.append('style', filters.style);
      if (filters.city) params.append('city', filters.city);
      if (filters.minRating) params.append('minRating', filters.minRating.toString());
      if (filters.maxFee) params.append('maxFee', filters.maxFee.toString());
      if (filters.sortBy) params.append('sortBy', filters.sortBy);
      params.append('page', (filters.page || 1).toString());
      params.append('pageSize', (filters.pageSize || 20).toString());

      const response = await HttpService.get<ProfileListResponse>(`${ProfileService.ENDPOINT}/search?${params.toString()}`);
      Logger.info('ProfileService', '搜索档案');
      return response;
    } catch (error) {
      Logger.error('ProfileService', '搜索档案失败');
      throw error;
    }
  }

  static async getRecommendations(params: BookingFilters): Promise<ProfileListResponse> {
    try {
      const response = await HttpService.get<ProfileListResponse>(`${ProfileService.ENDPOINT}/recommendations`);
      Logger.info('ProfileService', '获取推荐档案');
      return response;
    } catch (error) {
      Logger.error('ProfileService', '获取推荐档案失败');
      throw error;
    }
  }

  static async updateMyProfile(updates: Partial<BookingProfile>): Promise<BookingProfile> {
    try {
      const response = await HttpService.put<BookingProfile, Partial<BookingProfile>>(`${ProfileService.ENDPOINT}/my`, updates);
      Logger.info('ProfileService', '更新我的档案');
      return response;
    } catch (error) {
      Logger.error('ProfileService', '更新我的档案失败');
      throw error;
    }
  }
}
