import { Booking } from '../models/Booking';
import { BookingStatus, BookingFilters } from '../models/Booking';
import { BookingService } from '../services/BookingService';
import { ProfileService } from '../services/ProfileService';
import { Logger } from '../common/utils/Logger';

export class BookingListViewModel {
  private bookings: Booking[] = [];
  private currentPage: number = 1;
  private isLoading: boolean = false;
  private hasMore: boolean = true;
  private currentStatus: BookingStatus | null = null;
  private filters: BookingFilters = {};
  private loadCallbacks: Array<() => void> = [];

  getBookings(): Booking[] {
    return this.bookings;
  }

  isLoading(): boolean {
    return this.isLoading;
  }

  hasMorePages(): boolean {
    return this.hasMore;
  }

  getCurrentStatus(): BookingStatus | null {
    return this.currentStatus;
  }

  onDataChange(callback: () => void): void {
    this.loadCallbacks.push(callback);
  }

  private notifyCallbacks(): void {
    this.loadCallbacks.forEach(callback => callback());
  }

  async loadBookings(status?: BookingStatus, filters?: BookingFilters): Promise<void> {
    this.isLoading = true;
    this.currentStatus = status || null;
    this.filters = filters || {};
    this.currentPage = 1;
    this.bookings = [];
    this.notifyCallbacks();

    try {
      const response = await BookingService.getMyBookings(this.currentStatus || undefined, this.currentPage, 20);
      this.bookings = response.bookings;
      this.hasMore = response.hasMore;
    } catch (error) {
      Logger.error('BookingListViewModel', '加载约拍列表失败');
    } finally {
      this.isLoading = false;
      this.notifyCallbacks();
    }
  }

  async loadMoreBookings(): Promise<void> {
    if (this.isLoading || !this.hasMore) {
      return;
    }

    this.isLoading = true;
    this.currentPage++;
    this.notifyCallbacks();

    try {
      const response = await BookingService.getMyBookings(this.currentStatus || undefined, this.currentPage, 20);
      this.bookings = [...this.bookings, ...response.bookings];
      this.hasMore = response.hasMore;
    } catch (error) {
      Logger.error('BookingListViewModel', '加载更多约拍失败');
      this.currentPage--;
    } finally {
      this.isLoading = false;
      this.notifyCallbacks();
    }
  }

  async acceptBooking(bookingId: string): Promise<void> {
    try {
      await BookingService.acceptBooking(bookingId);
      const booking = this.bookings.find(b => b.id === bookingId);
      if (booking) {
        booking.status = BookingStatus.CONFIRMED;
        this.notifyCallbacks();
      }
    } catch (error) {
      Logger.error('BookingListViewModel', '接受约拍失败');
    }
  }

  async rejectBooking(bookingId: string): Promise<void> {
    try {
      await BookingService.rejectBooking(bookingId);
      const booking = this.bookings.find(b => b.id === bookingId);
      if (booking) {
        booking.status = BookingStatus.REJECTED;
        this.notifyCallbacks();
      }
    } catch (error) {
      Logger.error('BookingListViewModel', '拒绝约拍失败');
    }
  }

  async cancelBooking(bookingId: string): Promise<void> {
    try {
      await BookingService.cancelBooking(bookingId);
      const booking = this.bookings.find(b => b.id === bookingId);
      if (booking) {
        booking.status = BookingStatus.CANCELLED;
        this.notifyCallbacks();
      }
    } catch (error) {
      Logger.error('BookingListViewModel', '取消约拍失败');
    }
  }
}
