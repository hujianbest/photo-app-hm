import { Album } from '../models/Album';
import { AlbumService } from '../services/AlbumService';
import { Logger } from '../common/utils/Logger';

export class AlbumListViewModel {
  private albums: Album[] = [];
  private isLoading: boolean = false;
  private viewMode: 'grid' | 'list' = 'grid';
  private loadCallbacks: Array<() => void> = [];

  getAlbums(): Album[] {
    return this.albums;
  }

  isLoading(): boolean {
    return this.isLoading;
  }

  getViewMode(): 'grid' | 'list' {
    return this.viewMode;
  }

  onAlbumsChange(callback: () => void): void {
    this.loadCallbacks.push(callback);
  }

  async loadAlbums(): Promise<void> {
    this.isLoading = true;
    this.notifyCallbacks();

    try {
      this.albums = await AlbumService.getAllAlbums();
      Logger.info('AlbumListViewModel', '加载了 %{public}d 个相册', this.albums.length);
    } catch (error) {
      Logger.error('AlbumListViewModel', '加载相册失败: %{public}s', JSON.stringify(error));
    } finally {
      this.isLoading = false;
      this.notifyCallbacks();
    }
  }

  toggleViewMode(): void {
    this.viewMode = this.viewMode === 'grid' ? 'list' : 'grid';
    this.notifyCallbacks();
  }

  async createAlbum(name: string, description?: string): Promise<Album | null> {
    try {
      const album = await AlbumService.createAlbum(name, description || '');
      await this.loadAlbums();
      return album;
    } catch (error) {
      Logger.error('AlbumListViewModel', '创建相册失败: %{public}s', JSON.stringify(error));
      return null;
    }
  }

  async deleteAlbum(albumId: number): Promise<boolean> {
    try {
      await AlbumService.deleteAlbum(albumId);
      await this.loadAlbums();
      return true;
    } catch (error) {
      Logger.error('AlbumListViewModel', '删除相册失败: %{public}s', JSON.stringify(error));
      return false;
    }
  }

  async refresh(): Promise<void> {
    await this.loadAlbums();
  }

  private notifyCallbacks(): void {
    this.loadCallbacks.forEach(callback => callback());
  }
}
