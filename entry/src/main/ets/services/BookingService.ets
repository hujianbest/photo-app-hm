import { HttpService } from './HttpService';
import { HttpResponse } from '../models/HttpResponse';
import {
  Booking,
  CreateBookingRequest,
  UpdateBookingRequest,
  BookingListResponse,
  BookingStatus
} from '../models/Booking';
import { Logger } from '../common/utils/Logger';

export class BookingService {
  private static readonly ENDPOINT = '/bookings';

  static async getMyBookings(
    status?: BookingStatus,
    page: number = 1,
    pageSize: number = 20
  ): Promise<BookingListResponse> {
    try {
      let url = `${BookingService.ENDPOINT}/my?page=${page}&pageSize=${pageSize}`;
      if (status) {
        url += `&status=${status}`;
      }
      const response = await HttpService.get<BookingListResponse>(url);
      Logger.info('BookingService', '获取我的约拍列表');
      return response;
    } catch (error) {
      Logger.error('BookingService', '获取我的约拍列表失败');
      throw error;
    }
  }

  static async getBookingById(bookingId: string): Promise<Booking> {
    try {
      const response = await HttpService.get<Booking>(`${BookingService.ENDPOINT}/${bookingId}`);
      Logger.info('BookingService', '获取约拍详情: %{public}s', bookingId);
      return response;
    } catch (error) {
      Logger.error('BookingService', '获取约拍详情失败');
      throw error;
    }
  }

  static async createBooking(request: CreateBookingRequest): Promise<Booking> {
    try {
      const response = await HttpService.post<Booking, CreateBookingRequest>(BookingService.ENDPOINT, request);
      Logger.info('BookingService', '创建约拍请求成功');
      return response;
    } catch (error) {
      Logger.error('BookingService', '创建约拍请求失败');
      throw error;
    }
  }

  static async updateBooking(bookingId: string, request: UpdateBookingRequest): Promise<Booking> {
    try {
      const response = await HttpService.put<Booking, UpdateBookingRequest>(`${BookingService.ENDPOINT}/${bookingId}`, request);
      Logger.info('BookingService', '更新约拍成功: %{public}s', bookingId);
      return response;
    } catch (error) {
      Logger.error('BookingService', '更新约拍失败');
      throw error;
    }
  }

  static async acceptBooking(bookingId: string): Promise<Booking> {
    try {
      const response = await HttpService.post<Booking>(`${BookingService.ENDPOINT}/${bookingId}/accept`, {});
      Logger.info('BookingService', '接受约拍: %{public}s', bookingId);
      return response;
    } catch (error) {
      Logger.error('BookingService', '接受约拍失败');
      throw error;
    }
  }

  static async rejectBooking(bookingId: string): Promise<Booking> {
    try {
      const response = await HttpService.post<Booking>(`${BookingService.ENDPOINT}/${bookingId}/reject`, {});
      Logger.info('BookingService', '拒绝约拍: %{public}s', bookingId);
      return response;
    } catch (error) {
      Logger.error('BookingService', '拒绝约拍失败');
      throw error;
    }
  }

  static async cancelBooking(bookingId: string): Promise<Booking> {
    try {
      const response = await HttpService.post<Booking>(`${BookingService.ENDPOINT}/${bookingId}/cancel`, {});
      Logger.info('BookingService', '取消约拍: %{public}s', bookingId);
      return response;
    } catch (error) {
      Logger.error('BookingService', '取消约拍失败');
      throw error;
    }
  }

  static async completeBooking(bookingId: string): Promise<Booking> {
    try {
      const response = await HttpService.post<Booking>(`${BookingService.ENDPOINT}/${bookingId}/complete`, {});
      Logger.info('BookingService', '完成约拍: %{public}s', bookingId);
      return response;
    } catch (error) {
      Logger.error('BookingService', '完成约拍失败');
      throw error;
    }
  }
}
