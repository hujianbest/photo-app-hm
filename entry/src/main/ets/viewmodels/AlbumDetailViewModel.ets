import { Album, UpdateAlbumRequest } from '../models/Album';
import { Photo } from '../models/Photo';
import { AlbumService } from '../services/AlbumService';
import { PhotoService } from '../services/PhotoService';
import { Logger } from '../common/utils/Logger';

export class AlbumDetailViewModel {
  private album: Album | null = null;
  private photos: Photo[] = [];
  private selectedPhotos: Set<number> = new Set();
  private isMultiSelectMode: boolean = false;
  private isLoading: boolean = false;
  private loadCallbacks: Array<() => void> = [];

  getAlbum(): Album | null {
    return this.album;
  }

  getPhotos(): Photo[] {
    return this.photos;
  }

  getSelectedPhotos(): Set<number> {
    return this.selectedPhotos;
  }

  isMultiSelectModeEnabled(): boolean {
    return this.isMultiSelectMode;
  }

  isLoading(): boolean {
    return this.isLoading;
  }

  onDataChange(callback: () => void): void {
    this.loadCallbacks.push(callback);
  }

  async loadAlbum(albumId: number): Promise<void> {
    this.isLoading = true;
    this.notifyCallbacks();

    try {
      this.album = await AlbumService.getAlbumById(albumId);
      this.photos = await PhotoService.getPhotosByAlbum(albumId);
      Logger.info('AlbumDetailViewModel', '加载了相册，包含 %{public}d 张照片', this.photos.length);
    } catch (error) {
      Logger.error('AlbumDetailViewModel', '加载相册失败: %{public}s', JSON.stringify(error));
    } finally {
      this.isLoading = false;
      this.notifyCallbacks();
    }
  }

  async addPhotos(photoUris: string[]): Promise<boolean> {
    if (!this.album) {
      return false;
    }

    try {
      await PhotoService.addPhotosToAlbum(this.album.id, photoUris);
      await this.loadAlbum(this.album.id);
      return true;
    } catch (error) {
      Logger.error('AlbumDetailViewModel', '添加照片失败: %{public}s', JSON.stringify(error));
      return false;
    }
  }

  toggleMultiSelectMode(): void {
    this.isMultiSelectMode = !this.isMultiSelectMode;
    if (!this.isMultiSelectMode) {
      this.selectedPhotos.clear();
    }
    this.notifyCallbacks();
  }

  togglePhotoSelection(photoId: number): void {
    if (this.selectedPhotos.has(photoId)) {
      this.selectedPhotos.delete(photoId);
    } else {
      this.selectedPhotos.add(photoId);
    }
    this.notifyCallbacks();
  }

  selectAll(): void {
    this.photos.forEach(photo => this.selectedPhotos.add(photo.id));
    this.notifyCallbacks();
  }

  deselectAll(): void {
    this.selectedPhotos.clear();
    this.notifyCallbacks();
  }

  async deleteSelected(): Promise<boolean> {
    if (!this.album) {
      return false;
    }

    try {
      await PhotoService.deletePhotos(Array.from(this.selectedPhotos));
      this.selectedPhotos.clear();
      this.isMultiSelectMode = false;
      await this.loadAlbum(this.album.id);
      return true;
    } catch (error) {
      Logger.error('AlbumDetailViewModel', '删除照片失败: %{public}s', JSON.stringify(error));
      return false;
    }
  }

  async moveSelectedToAlbum(targetAlbumId: number): Promise<boolean> {
    if (!this.album) {
      return false;
    }

    try {
      await PhotoService.movePhotos(Array.from(this.selectedPhotos), targetAlbumId);
      this.selectedPhotos.clear();
      this.isMultiSelectMode = false;
      await this.loadAlbum(this.album.id);
      return true;
    } catch (error) {
      Logger.error('AlbumDetailViewModel', '移动照片失败: %{public}s', JSON.stringify(error));
      return false;
    }
  }

  async addTagsToSelected(tags: string[]): Promise<boolean> {
    try {
      await PhotoService.addTagsToPhotos(Array.from(this.selectedPhotos), tags);
      await this.loadAlbum(this.photos[0]?.albumId || 0);
      return true;
    } catch (error) {
      Logger.error('AlbumDetailViewModel', '添加标签失败: %{public}s', JSON.stringify(error));
      return false;
    }
  }

  async updateAlbumInfo(updates: Partial<UpdateAlbumRequest>): Promise<boolean> {
    if (!this.album) {
      return false;
    }

    try {
      this.album = await AlbumService.updateAlbum(this.album.id, updates);
      this.notifyCallbacks();
      return true;
    } catch (error) {
      Logger.error('AlbumDetailViewModel', '更新相册信息失败: %{public}s', JSON.stringify(error));
      return false;
    }
  }

  private notifyCallbacks(): void {
    this.loadCallbacks.forEach(callback => callback());
  }
}
