import { HttpService } from './HttpService';
import { NotificationItem } from '../models/Notification';
import { Logger } from '../common/utils/Logger';

export interface NotificationListResponse {
  notifications: NotificationItem[];
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
