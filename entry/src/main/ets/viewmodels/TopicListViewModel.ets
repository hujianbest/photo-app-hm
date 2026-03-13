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
