import { Photo, UpdatePhotoRequest } from '../models/Photo';
import { PhotoService } from '../services/PhotoService';
import { Logger } from '../common/utils/Logger';

export class PhotoDetailViewModel {
  private photo: Photo | null = null;
  private photoList: Photo[] = [];
  private currentIndex: number = 0;
  private loadCallbacks: Array<() => void> = [];

  getPhoto(): Photo | null {
    return this.photo;
  }

  getCurrentIndex(): number {
    return this.currentIndex;
  }

  getTotalPhotos(): number {
    return this.photoList.length;
  }

  getPhotoList(): Photo[] {
    return this.photoList;
  }

  onDataChange(callback: () => void): void {
    this.loadCallbacks.push(callback);
  }

  async loadPhoto(photoId: number): Promise<void> {
    try {
      this.photo = await PhotoService.getPhotoById(photoId);
      this.notifyCallbacks();
    } catch (error) {
      Logger.error('PhotoDetailViewModel', '加载照片失败: %{public}s', JSON.stringify(error));
    }
  }

  setPhotoList(photos: Photo[], currentIndex: number): void {
    this.photoList = photos;
    this.currentIndex = currentIndex;
    this.notifyCallbacks();
  }

  previousPhoto(): Photo | null {
    if (this.currentIndex > 0) {
      this.currentIndex--;
      this.photo = this.photoList[this.currentIndex];
      this.notifyCallbacks();
    }
    return this.photo;
  }

  nextPhoto(): Photo | null {
    if (this.currentIndex < this.photoList.length - 1) {
      this.currentIndex++;
      this.photo = this.photoList[this.currentIndex];
      this.notifyCallbacks();
    }
    return this.photo;
  }

  async updateTags(tags: string[]): Promise<boolean> {
    if (!this.photo) {
      return false;
    }

    try {
      this.photo = await PhotoService.updatePhoto(this.photo.id, { tags });
      // 更新列表中的照片
      this.photoList[this.currentIndex] = this.photo;
      this.notifyCallbacks();
      return true;
    } catch (error) {
      Logger.error('PhotoDetailViewModel', '更新标签失败: %{public}s', JSON.stringify(error));
      return false;
    }
  }

  async deletePhoto(): Promise<boolean> {
    if (!this.photo) {
      return false;
    }

    try {
      await PhotoService.deletePhoto(this.photo.id);
      return true;
    } catch (error) {
      Logger.error('PhotoDetailViewModel', '删除照片失败: %{public}s', JSON.stringify(error));
      return false;
    }
  }

  async moveToAlbum(albumId: number): Promise<boolean> {
    if (!this.photo) {
      return false;
    }

    try {
      await PhotoService.movePhotos([this.photo.id], albumId);
      return true;
    } catch (error) {
      Logger.error('PhotoDetailViewModel', '移动照片失败: %{public}s', JSON.stringify(error));
      return false;
    }
  }

  getTags(): string[] {
    if (!this.photo || !this.photo.tags) {
      return [];
    }
    try {
      return JSON.parse(this.photo.tags) as string[];
    } catch {
      return [];
    }
  }

  private notifyCallbacks(): void {
    this.loadCallbacks.forEach(callback => callback());
  }
}
