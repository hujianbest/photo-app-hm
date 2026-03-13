import { BookingProfile, ProfileResponse } from '../models/BookingProfile';
import { ProfileService } from '../services/ProfileService';
import { Logger } from '../common/utils/Logger';

export class ProfileViewModel {
  private profile: BookingProfile | null = null;
  private isLoading: boolean = false;
  private isEditing: boolean = false;
  private recentBookings: ProfileResponse['recentBookings'] = [];
  private loadCallbacks: Array<() => void> = [];

  getProfile(): BookingProfile | null {
    return this.profile;
  }

  isLoading(): boolean {
    return this.isLoading;
  }

  isEditing(): boolean {
    return this.isEditing;
  }

  getRecentBookings(): ProfileResponse['recentBookings'] {
    return this.recentBookings;
  }

  onDataChange(callback: () => void): void {
    this.loadCallbacks.push(callback);
  }

  private notifyCallbacks(): void {
    this.loadCallbacks.forEach(callback => callback());
  }

  async loadMyProfile(): Promise<void> {
    this.isLoading = true;
    this.notifyCallbacks();

    try {
      this.profile = await ProfileService.getMyProfile();
    } catch (error) {
      Logger.error('ProfileViewModel', '加载我的档案失败');
    } finally {
      this.isLoading = false;
      this.notifyCallbacks();
    }
  }

  async loadProfile(userId: string): Promise<void> {
    this.isLoading = true;
    this.notifyCallbacks();

    try {
      const response = await ProfileService.getProfileById(userId);
      this.profile = response.profile;
      this.recentBookings = response.recentBookings;
    } catch (error) {
      Logger.error('ProfileViewModel', '加载用户档案失败');
    } finally {
      this.isLoading = false;
      this.notifyCallbacks();
    }
  }

  async updateProfile(updates: Partial<BookingProfile>): Promise<boolean> {
    if (!this.profile || this.isEditing) {
      return false;
    }

    this.isEditing = true;
    this.notifyCallbacks();

    try {
      this.profile = await ProfileService.updateMyProfile(updates);
      this.notifyCallbacks();
      return true;
    } catch (error) {
      Logger.error('ProfileViewModel', '更新档案失败');
      return false;
    } finally {
      this.isEditing = false;
      this.notifyCallbacks();
    }
  }
}
