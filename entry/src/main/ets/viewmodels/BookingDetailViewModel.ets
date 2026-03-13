import { Booking, BookingStatus } from '../models/Booking';
import { BookingService } from '../services/BookingService';
import { Logger } from '../common/utils/Logger';

export class BookingDetailViewModel {
  private booking: Booking | null = null;
  private isLoading: boolean = false;
  private isProcessing: boolean = false;
  private loadCallbacks: Array<() => void> = [];

  getBooking(): Booking | null {
    return this.booking;
  }

  isLoading(): boolean {
    return this.isLoading;
  }

  isProcessing(): boolean {
    return this.isProcessing;
  }

  onDataChange(callback: () => void): void {
    this.loadCallbacks.push(callback);
  }

  private notifyCallbacks(): void {
    this.loadCallbacks.forEach(callback => callback());
  }

  async loadBooking(bookingId: string): Promise<void> {
    this.isLoading = true;
    this.notifyCallbacks();

    try {
      this.booking = await BookingService.getBookingById(bookingId);
    } catch (error) {
      Logger.error('BookingDetailViewModel', '加载约拍详情失败');
    } finally {
      this.isLoading = false;
      this.notifyCallbacks();
    }
  }

  async acceptBooking(): Promise<boolean> {
    if (!this.booking || this.isProcessing) {
      return false;
    }

    this.isProcessing = true;
    this.notifyCallbacks();

    try {
      this.booking = await BookingService.acceptBooking(this.booking.id);
      this.notifyCallbacks();
      return true;
    } catch (error) {
      Logger.error('BookingDetailViewModel', '接受约拍失败');
      return false;
    } finally {
      this.isProcessing = false;
      this.notifyCallbacks();
    }
  }

  async rejectBooking(): Promise<boolean> {
    if (!this.booking || this.isProcessing) {
      return false;
    }

    this.isProcessing = true;
    this.notifyCallbacks();

    try {
      this.booking = await BookingService.rejectBooking(this.booking.id);
      this.notifyCallbacks();
      return true;
    } catch (error) {
      Logger.error('BookingDetailViewModel', '拒绝约拍失败');
      return false;
    } finally {
      this.isProcessing = false;
      this.notifyCallbacks();
    }
  }

  async cancelBooking(): Promise<boolean> {
    if (!this.booking || this.isProcessing) {
      return false;
    }

    this.isProcessing = true;
    this.notifyCallbacks();

    try {
      this.booking = await BookingService.cancelBooking(this.booking.id);
      this.notifyCallbacks();
      return true;
    } catch (error) {
      Logger.error('BookingDetailViewModel', '取消约拍失败');
      return false;
    } finally {
      this.isProcessing = false;
      this.notifyCallbacks();
    }
  }

  async completeBooking(): Promise<boolean> {
    if (!this.booking || this.isProcessing) {
      return false;
    }

    this.isProcessing = true;
    this.notifyCallbacks();

    try {
      this.booking = await BookingService.completeBooking(this.booking.id);
      this.notifyCallbacks();
      return true;
    } catch (error) {
      Logger.error('BookingDetailViewModel', '完成约拍失败');
      return false;
    } finally {
      this.isProcessing = false;
      this.notifyCallbacks();
    }
  }

  getStatusText(status: BookingStatus): string {
    switch (status) {
      case BookingStatus.PENDING:
        return '待确认';
      case BookingStatus.CONFIRMED:
        return '已确认';
      case BookingStatus.IN_PROGRESS:
        return '进行中';
      case BookingStatus.COMPLETED:
        return '已完成';
      case BookingStatus.CANCELLED:
        return '已取消';
      case BookingStatus.REJECTED:
        return '已拒绝';
      default:
        return '未知';
    }
  }

  getStatusColor(status: BookingStatus): string {
    switch (status) {
      case BookingStatus.PENDING:
        return '#FFA500';
      case BookingStatus.CONFIRMED:
        return '#52C41A';
      case BookingStatus.IN_PROGRESS:
        return '#1890FF';
      case BookingStatus.COMPLETED:
        return '#722ED1';
      case BookingStatus.CANCELLED:
        return '#999999';
      case BookingStatus.REJECTED:
        return '#FF4D4F';
      default:
        return '#999999';
    }
  }
}
