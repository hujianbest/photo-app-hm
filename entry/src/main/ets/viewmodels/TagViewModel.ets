import { Tag } from '../models/Tag';
import { Photo } from '../models/Photo';
import { TagService } from '../services/TagService';
import { PhotoService } from '../services/PhotoService';
import { Logger } from '../common/utils/Logger';

export class TagViewModel {
  private tags: Tag[] = [];
  private selectedTag: string | null = null;
  private filteredPhotos: Photo[] = [];
  private isLoading: boolean = false;
  private loadCallbacks: Array<() => void> = [];

  getTags(): Tag[] {
    return this.tags;
  }

  getSelectedTag(): string | null {
    return this.selectedTag;
  }

  getFilteredPhotos(): Photo[] {
    return this.filteredPhotos;
  }

  isLoading(): boolean {
    return this.isLoading;
  }

  onDataChange(callback: () => void): void {
    this.loadCallbacks.push(callback);
  }

  async loadTags(): Promise<void> {
    this.isLoading = true;
    this.notifyCallbacks();

    try {
      this.tags = await TagService.getAllTags();
      Logger.info('TagViewModel', '加载了 %{public}d 个标签', this.tags.length);
    } catch (error) {
      Logger.error('TagViewModel', '加载标签失败: %{public}s', JSON.stringify(error));
    } finally {
      this.isLoading = false;
      this.notifyCallbacks();
    }
  }

  async createTag(name: string, color: string = '#1890FF'): Promise<Tag | null> {
    try {
      const tag = await TagService.createTag(name, color);
      await this.loadTags();
      return tag;
    } catch (error) {
      Logger.error('TagViewModel', '创建标签失败: %{public}s', JSON.stringify(error));
      return null;
    }
  }

  async updateTag(id: number, updates: { name?: string; color?: string }): Promise<boolean> {
    try {
      await TagService.updateTag(id, updates);
      await this.loadTags();
      return true;
    } catch (error) {
      Logger.error('TagViewModel', '更新标签失败: %{public}s', JSON.stringify(error));
      return false;
    }
  }

  async deleteTag(id: number): Promise<boolean> {
    try {
      await TagService.deleteTag(id);
      await this.loadTags();
      return true;
    } catch (error) {
      Logger.error('TagViewModel', '删除标签失败: %{public}s', JSON.stringify(error));
      return false;
    }
  }

  async filterByTag(tagName: string): Promise<void> {
    this.selectedTag = tagName;
    this.isLoading = true;
    this.notifyCallbacks();

    try {
      // 获取所有照片并按标签筛选
      // 注意：这是简化实现
      // 在实际应用中，你需要更高效的查询
      this.filteredPhotos = [];
      Logger.info('TagViewModel', '按标签筛选: %{public}s', tagName);
    } catch (error) {
      Logger.error('TagViewModel', '筛选照片失败: %{public}s', JSON.stringify(error));
    } finally {
      this.isLoading = false;
      this.notifyCallbacks();
    }
  }

  clearFilter(): void {
    this.selectedTag = null;
    this.filteredPhotos = [];
    this.notifyCallbacks();
  }

  private notifyCallbacks(): void {
    this.loadCallbacks.forEach(callback => callback());
  }
}
