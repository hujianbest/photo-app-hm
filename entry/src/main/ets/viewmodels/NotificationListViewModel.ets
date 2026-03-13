import { NotificationItem } from '../models/Notification';
import { NotificationService } from '../services/NotificationService';
import { Logger } from '../common/utils/Logger';

export class NotificationListViewModel {
  private notifications: NotificationItem[] = [];
  private currentPage: number = 1;
  private isLoading: boolean = false;
  private unreadCount: number = 0;
  private hasMore: boolean = true;
  private loadCallbacks: Array<() => void> = [];

  getNotifications(): NotificationItem[] {
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

  async markAsRead(notification: NotificationItem): Promise<void> {
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

  async deleteNotification(notification: NotificationItem): Promise<void> {
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
