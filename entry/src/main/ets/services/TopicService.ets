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
