# Phase 4: Booking/Matching Module Implementation Plan

> **For agentic workers:** REQUIRED: Use superpowers:subagent-driven-development (if subagents available) or superpowers:executing-plans to implement this plan. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Implement the booking/matching module for photographers and models, including user profiles, smart recommendations, booking requests, and chat communication.

**Architecture:** MVVM architecture with remote API integration. Services handle HTTP requests, ViewModels manage state with callback mechanism, Pages use ArkUI components for UI rendering.

**Tech Stack:** ArkTS + ArkUI (HarmonyOS native), HttpService for API calls, callback-based state management

---

## File Structure

### Data Models (4 files)
- `entry/src/main/ets/models/Booking.ets` - Booking request and status
- `entry/src/main/ets/models/BookingProfile.ets` - Photographer/Model profile with portfolio
- `entry/src/main/ets/models/Message.ets` - Chat message
- `entry/src/main/ets/models/BookingFilters.ets` - Filter criteria for recommendations

### Services (3 files)
- `entry/src/main/ets/services/BookingService.ets` - Booking CRUD and status management
- `entry/src/main/ets/services/ProfileService.ets` - User profile and portfolio
- `entry/src/main/ets/services/ChatService.ets` - Real-time messaging

### ViewModels (4 files)
- `entry/src/main/ets/viewmodels/BookingListViewModel.ets` - Booking list state with filters
- `entry/src/main/ets/viewmodels/BookingDetailViewModel.ets` - Single booking detail
- `entry/src/main/ets/viewmodels/ProfileViewModel.ets` - User profile state
- `entry/src/main/ets/viewmodels/ChatViewModel.ets` - Chat messages state

### Pages (4 new pages, 1 modified)
- Modify: `entry/src/main/ets/pages/BookingPage.ets` - Replace with booking match list
- Create: `entry/src/main/ets/pages/BookingCreatePage.ets` - Create booking request
- Create: `entry/src/main/ets/pages/BookingDetailPage.ets` - Booking detail page
- Create: `entry/src/main/ets/pages/ProfilePage.ets` - User profile view
- Create: `entry/src/main/ets/pages/ChatPage.ets` - Chat communication page

### Configuration (1 file modified)
- Modify: `entry/src/main/resources/base/profile/main_pages.json` - Add 4 new pages

---

## Chunk 1: Data Models

### Task 1: Create Booking.ets

**Files:**
- Create: `entry/src/main/ets/models/Booking.ets`

- [ ] **Step 1: Write the Booking data model**

```typescript
// entry/src/main/ets/models/Booking.ets

export enum BookingStatus {
  PENDING = 'pending',       // 待确认
  CONFIRMED = 'confirmed',   // 已确认
  IN_PROGRESS = 'in_progress', // 进行中
  COMPLETED = 'completed',   // 已完成
  CANCELLED = 'cancelled',   // 已取消
  REJECTED = 'rejected'      // 已拒绝
}

export interface Booking {
  id: string;
  requesterId: string;        // 请求发起者ID
  requester: {
    id: string;
    nickname: string;
    avatar: string;
    role: string;           // 'photographer' or 'model'
    rating: number;
  };
  targetId: string;          // 目标用户ID
  target: {
    id: string;
    nickname: string;
    avatar: string;
    role: string;
    rating: number;
  };
  title: string;             // 约拍标题
  description: string;       // 详细描述
  style: string;            // 摄影风格（人像/风光/街拍等）
  scheduledTime: string;    // 预约时间 ISO8601
  location: {
    address: string;        // 地址
    latitude?: number;
    longitude?: number;
    city: string;           // 城市
  };
  duration: number;         // 预计时长（小时）
  fee: number;             // 费用
  status: BookingStatus;     // 状态
  createdAt: string;        // 创建时间
  updatedAt: string;       // 更新时间
}

export interface CreateBookingRequest {
  targetId: string;
  title: string;
  description: string;
  style: string;
  scheduledTime: string;
  location: {
    address: string;
    latitude?: number;
    longitude?: number;
    city: string;
  };
  duration: number;
  fee: number;
}

export interface UpdateBookingRequest {
  status?: BookingStatus;
  scheduledTime?: string;
  location?: {
    address?: string;
    latitude?: number;
    longitude?: number;
    city?: string;
  };
  description?: string;
}

export interface BookingListResponse {
  bookings: Booking[];
  hasMore: boolean;
  nextCursor?: string;
}
```

- [ ] **Step 2: Commit**

```bash
git add entry/src/main/ets/models/Booking.ets
git commit -m "feat: 添加约拍数据模型"
```

### Task 2: Create BookingProfile.ets

**Files:**
- Create: `entry/src/main/ets/models/BookingProfile.ets`

- [ ] **Step 1: Write the BookingProfile data model**

```typescript
// entry/src/main/ets/models/BookingProfile.ets

export interface BookingProfile {
  id: string;
  userId: string;
  role: 'photographer' | 'model';  // 角色
  nickname: string;
  avatar: string;
  bio: string;                      // 个人简介
  styleTags: string[];              // 风格标签
  rating: number;                   // 评分
  reviewCount: number;               // 评价数
  completedBookings: number;         // 完成约拍数
  portfolio: PortfolioItem[];        // 作品集
  location: {
    city: string;
    area?: string;
  };
  availability: Availability;         // 可约时间
  priceRange: {
    min: number;
    max: number;
  };
  isVerified: boolean;
  createdAt: string;
  updatedAt: string;
}

export interface PortfolioItem {
  id: string;
  imageUrl: string;
  title?: string;
  description?: string;
  style: string;
  createdAt: string;
}

export interface Availability {
  weekdays: boolean[];              // [周一到周日是否可约]
  timeRange: {
    start: string;                  // HH:mm
    end: string;                    // HH:mm
  };
  advanceDays: number;              // 需提前预约天数
}

export interface ProfileResponse {
  profile: BookingProfile;
  recentBookings: Booking[];
}
```

- [ ] **Step 2: Commit**

```bash
git add entry/src/main/ets/models/BookingProfile.ets
git commit -m "feat: 添加约拍档案数据模型"
```

### Task 3: Create Message.ets

**Files:**
- Create: `entry/src/main/ets/models/Message.ets`

- [ ] **Step 1: Write the Message data model**

```typescript
// entry/src/main/ets/models/Message.ets

export enum MessageType {
  TEXT = 'text',
  IMAGE = 'image',
  BOOKING = 'booking',
  SYSTEM = 'system'
}

export interface Message {
  id: string;
  conversationId: string;          // 会话ID（包含两个用户ID）
  fromUserId: string;
  toUserId: string;
  type: MessageType;
  content: string;                // 消息内容
  imageUrl?: string;              // 图片URL（type为image时）
  bookingId?: string;             // 关联约拍ID（type为booking时）
  isRead: boolean;
  createdAt: string;
}

export interface SendMessageRequest {
  toUserId: string;
  type: MessageType;
  content: string;
  imageUrl?: string;
  bookingId?: string;
}

export interface Conversation {
  id: string;
  userId: string;
  otherUser: {
    id: string;
    nickname: string;
    avatar: string;
    role: string;
  };
  lastMessage: Message;
  unreadCount: number;
  updatedAt: string;
}

export interface MessageListResponse {
  messages: Message[];
  hasMore: boolean;
  nextCursor?: string;
}
```

- [ ] **Step 2: Commit**

```bash
git add entry/src/main/ets/models/Message.ets
git commit -m "feat: 添加消息数据模型"
```

### Task 4: Create BookingFilters.ets

**Files:**
- Create: `entry/src/main/ets/models/BookingFilters.ets`

- [ ] **Step 1: Write the BookingFilters data model**

```typescript
// entry/src/main/ets/models/BookingFilters.ets

export interface BookingFilters {
  role?: 'photographer' | 'model';  // 角色筛选
  style?: string;                   // 风格筛选
  city?: string;                    // 城市筛选
  minRating?: number;               // 最低评分
  maxFee?: number;                 // 最高费用
  sortBy?: 'rating' | 'distance' | 'recent'; // 排序方式
  page?: number;
  pageSize?: number;
}

export interface RecommendationParams {
  stylePreferences: string[];        // 风格偏好
  location: {
    latitude: number;
    longitude: number;
    city: string;
  };
  radius?: number;                 // 搜索半径（公里）
}
```

- [ ] **Step 2: Commit**

```bash
git add entry/src/main/ets/models/BookingFilters.ets
git commit -m "feat: 添加约拍筛选数据模型"
```

---

## Chunk 2: Service Layer

### Task 5: Create BookingService.ets

**Files:**
- Create: `entry/src/main/ets/services/BookingService.ets`

- [ ] **Step 1: Write the BookingService implementation**

```typescript
// entry/src/main/ets/services/BookingService.ets

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
      const response = await HttpService.get<Booking>(
        `${BookingService.ENDPOINT}/${bookingId}`
      );
      Logger.info('BookingService', '获取约拍详情: %{public}s', bookingId);
      return response;
    } catch (error) {
      Logger.error('BookingService', '获取约拍详情失败');
      throw error;
    }
  }

  static async createBooking(
    request: CreateBookingRequest
  ): Promise<Booking> {
    try {
      const response = await HttpService.post<Booking, CreateBookingRequest>(
        BookingService.ENDPOINT,
        request
      );
      Logger.info('BookingService', '创建约拍请求成功');
      return response;
    } catch (error) {
      Logger.error('BookingService', '创建约拍请求失败');
      throw error;
    }
  }

  static async updateBooking(
    bookingId: string,
    request: UpdateBookingRequest
  ): Promise<Booking> {
    try {
      const response = await HttpService.put<Booking, UpdateBookingRequest>(
        `${BookingService.ENDPOINT}/${bookingId}`,
        request
      );
      Logger.info('BookingService', '更新约拍成功: %{public}s', bookingId);
      return response;
    } catch (error) {
      Logger.error('BookingService', '更新约拍失败');
      throw error;
    }
  }

  static async acceptBooking(bookingId: string): Promise<Booking> {
    try {
      const response = await HttpService.post<Booking>(
        `${BookingService.ENDPOINT}/${bookingId}/accept`,
        {}
      );
      Logger.info('BookingService', '接受约拍: %{public}s', bookingId);
      return response;
    } catch (error) {
      Logger.error('BookingService', '接受约拍失败');
      throw error;
    }
  }

  static async rejectBooking(bookingId: string): Promise<Booking> {
    try {
      const response = await HttpService.post<Booking>(
        `${BookingService.ENDPOINT}/${bookingId}/reject`,
        {}
      );
      Logger.info('BookingService', '拒绝约拍: %{public}s', bookingId);
      return response;
    } catch (error) {
      Logger.error('BookingService', '拒绝约拍失败');
      throw error;
    }
  }

  static async cancelBooking(bookingId: string): Promise<Booking> {
    try {
      const response = await HttpService.post<Booking>(
        `${BookingService.ENDPOINT}/${bookingId}/cancel`,
        {}
      );
      Logger.info('BookingService', '取消约拍: %{public}s', bookingId);
      return response;
    } catch (error) {
      Logger.error('BookingService', '取消约拍失败');
      throw error;
    }
  }

  static async completeBooking(bookingId: string): Promise<Booking> {
    try {
      const response = await HttpService.post<Booking>(
        `${BookingService.ENDPOINT}/${bookingId}/complete`,
        {}
      );
      Logger.info('BookingService', '完成约拍: %{public}s', bookingId);
      return response;
    } catch (error) {
      Logger.error('BookingService', '完成约拍失败');
      throw error;
    }
  }
}
```

- [ ] **Step 2: Commit**

```bash
git add entry/src/main/ets/services/BookingService.ets
git commit -m "feat: 添加约拍服务"
```

### Task 6: Create ProfileService.ets

**Files:**
- Create: `entry/src/main/ets/services/ProfileService.ets`

- [ ] **Step 1: Write the ProfileService implementation**

```typescript
// entry/src/main/ets/services/ProfileService.ets

import { HttpService } from './HttpService';
import { HttpResponse } from '../models/HttpResponse';
import {
  BookingProfile,
  ProfileResponse,
  BookingFilters
} from '../models/BookingProfile';
import { Logger } from '../common/utils/Logger';

export interface ProfileListResponse {
  profiles: BookingProfile[];
  hasMore: boolean;
  nextCursor?: string;
}

export class ProfileService {
  private static readonly ENDPOINT = '/profiles';

  static async getMyProfile(): Promise<BookingProfile> {
    try {
      const response = await HttpService.get<BookingProfile>(
        `${ProfileService.ENDPOINT}/my`
      );
      Logger.info('ProfileService', '获取我的档案');
      return response;
    } catch (error) {
      Logger.error('ProfileService', '获取我的档案失败');
      throw error;
    }
  }

  static async getProfileById(userId: string): Promise<ProfileResponse> {
    try {
      const response = await HttpService.get<ProfileResponse>(
        `${ProfileService.ENDPOINT}/${userId}`
      );
      Logger.info('ProfileService', '获取用户档案: %{public}s', userId);
      return response;
    } catch (error) {
      Logger.error('ProfileService', '获取用户档案失败');
      throw error;
    }
  }

  static async searchProfiles(
    filters: BookingFilters
  ): Promise<ProfileListResponse> {
    try {
      const params = new URLSearchParams();
      if (filters.role) params.append('role', filters.role);
      if (filters.style) params.append('style', filters.style);
      if (filters.city) params.append('city', filters.city);
      if (filters.minRating) params.append('minRating', filters.minRating.toString());
      if (filters.maxFee) params.append('maxFee', filters.maxFee.toString());
      if (filters.sortBy) params.append('sortBy', filters.sortBy);
      params.append('page', (filters.page || 1).toString());
      params.append('pageSize', (filters.pageSize || 20).toString());

      const response = await HttpService.get<ProfileListResponse>(
        `${ProfileService.ENDPOINT}/search?${params.toString()}`
      );
      Logger.info('ProfileService', '搜索档案');
      return response;
    } catch (error) {
      Logger.error('ProfileService', '搜索档案失败');
      throw error;
    }
  }

  static async getRecommendations(
    params: BookingFilters
  ): Promise<ProfileListResponse> {
    try {
      const response = await HttpService.get<ProfileListResponse>(
        `${ProfileService.ENDPOINT}/recommendations`
      );
      Logger.info('ProfileService', '获取推荐档案');
      return response;
    } catch (error) {
      Logger.error('ProfileService', '获取推荐档案失败');
      throw error;
    }
  }

  static async updateMyProfile(
    updates: Partial<BookingProfile>
  ): Promise<BookingProfile> {
    try {
      const response = await HttpService.put<BookingProfile, Partial<BookingProfile>>(
        `${ProfileService.ENDPOINT}/my`,
        updates
      );
      Logger.info('ProfileService', '更新我的档案');
      return response;
    } catch (error) {
      Logger.error('ProfileService', '更新我的档案失败');
      throw error;
    }
  }
}
```

- [ ] **Step 2: Commit**

```bash
git add entry/src/main/ets/services/ProfileService.ets
git commit -m "feat: 添加档案服务"
```

### Task 7: Create ChatService.ets

**Files:**
- Create: `entry/src/main/ets/services/ChatService.ets`

- [ ] **Step 1: Write the ChatService implementation**

```typescript
// entry/src/main/ets/services/ChatService.ets

import { HttpService } from './HttpService';
import { HttpResponse } from '../models/HttpResponse';
import {
  Message,
  SendMessageRequest,
  Conversation,
  MessageListResponse,
  MessageType
} from '../models/Message';
import { Logger } from '../common/utils/Logger';

export class ChatService {
  private static readonly ENDPOINT = '/messages';

  static async getConversations(
    page: number = 1,
    pageSize: number = 20
  ): Promise<{ conversations: Conversation[]; hasMore: boolean }> {
    try {
      const response = await HttpService.get<{ conversations: Conversation[]; hasMore: boolean }>(
        `${ChatService.ENDPOINT}/conversations?page=${page}&pageSize=${pageSize}`
      );
      Logger.info('ChatService', '获取会话列表');
      return response;
    } catch (error) {
      Logger.error('ChatService', '获取会话列表失败');
      throw error;
    }
  }

  static async getMessages(
    conversationId: string,
    page: number = 1,
    pageSize: number = 50
  ): Promise<MessageListResponse> {
    try {
      const response = await HttpService.get<MessageListResponse>(
        `${ChatService.ENDPOINT}/${conversationId}?page=${page}&pageSize=${pageSize}`
      );
      Logger.info('ChatService', '获取消息列表');
      return response;
    } catch (error) {
      Logger.error('ChatService', '获取消息列表失败');
      throw error;
    }
  }

  static async sendMessage(
    request: SendMessageRequest
  ): Promise<Message> {
    try {
      const response = await HttpService.post<Message, SendMessageRequest>(
        ChatService.ENDPOINT,
        request
      );
      Logger.info('ChatService', '发送消息成功');
      return response;
    } catch (error) {
      Logger.error('ChatService', '发送消息失败');
      throw error;
    }
  }

  static async markAsRead(conversationId: string): Promise<void> {
    try {
      await HttpService.post(`${ChatService.ENDPOINT}/${conversationId}/read`, {});
      Logger.info('ChatService', '标记已读');
    } catch (error) {
      Logger.error('ChatService', '标记已读失败');
      throw error;
    }
  }

  static async deleteMessage(messageId: string): Promise<void> {
    try {
      await HttpService.delete(`${ChatService.ENDPOINT}/${messageId}`);
      Logger.info('ChatService', '删除消息成功');
    } catch (error) {
      Logger.error('ChatService', '删除消息失败');
      throw error;
    }
  }
}
```

- [ ] **Step 2: Commit**

```bash
git add entry/src/main/ets/services/ChatService.ets
git commit -m "feat: 添加聊天服务"
```

---

## Chunk 3: ViewModel Layer

### Task 8: Create BookingListViewModel.ets

**Files:**
- Create: `entry/src/main/ets/viewmodels/BookingListViewModel.ets`

- [ ] **Step 1: Write the BookingListViewModel implementation**

```typescript
// entry/src/main/ets/viewmodels/BookingListViewModel.ets

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
      const response = await BookingService.getMyBookings(
        this.currentStatus || undefined,
        this.currentPage,
        20
      );
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
      const response = await BookingService.getMyBookings(
        this.currentStatus || undefined,
        this.currentPage,
        20
      );
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
```

- [ ] **Step 2: Commit**

```bash
git add entry/src/main/ets/viewmodels/BookingListViewModel.ets
git commit -m "feat: 添加约拍列表ViewModel"
```

### Task 9: Create BookingDetailViewModel.ets

**Files:**
- Create: `entry/src/main/ets/viewmodels/BookingDetailViewModel.ets`

- [ ] **Step 1: Write the BookingDetailViewModel implementation**

```typescript
// entry/src/main/ets/viewmodels/BookingDetailViewModel.ets

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
```

- [ ] **Step 2: Commit**

```bash
git add entry/src/main/ets/viewmodels/BookingDetailViewModel.ets
git commit -m "feat: 添加约拍详情ViewModel"
```

### Task 10: Create ProfileViewModel.ets

**Files:**
- Create: `entry/src/main/ets/viewmodels/ProfileViewModel.ets`

- [ ] **Step 1: Write the ProfileViewModel implementation**

```typescript
// entry/src/main/ets/viewmodels/ProfileViewModel.ets

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
```

- [ ] **Step 2: Commit**

```bash
git add entry/src/main/ets/viewmodels/ProfileViewModel.ets
git commit -m "feat: 添加档案ViewModel"
```

### Task 11: Create ChatViewModel.ets

**Files:**
- Create: `entry/src/main/ets/viewmodels/ChatViewModel.ets`

- [ ] **Step 1: Write the ChatViewModel implementation**

```typescript
// entry/src/main/ets/viewmodels/ChatViewModel.ets

import { Message, SendMessageRequest, Conversation, MessageType } from '../models/Message';
import { ChatService } from '../services/ChatService';
import { Logger } from '../common/utils/Logger';

export class ChatViewModel {
  private messages: Message[] = [];
  private conversations: Conversation[] = [];
  private currentConversationId: string = '';
  private isLoadingMessages: boolean = false;
  private isLoadingConversations: boolean = false;
  private isSending: boolean = false;
  private hasMoreMessages: boolean = true;
  private currentPage: number = 1;
  private unreadCount: number = 0;
  private loadCallbacks: Array<() => void> = [];

  getMessages(): Message[] {
    return this.messages;
  }

  getConversations(): Conversation[] {
    return this.conversations;
  }

  isLoadingMessages(): boolean {
    return this.isLoadingMessages;
  }

  isLoadingConversations(): boolean {
    return this.isLoadingConversations;
  }

  isSending(): boolean {
    return this.isSending;
  }

  getUnreadCount(): number {
    return this.unreadCount;
  }

  hasMoreMessages(): boolean {
    return this.hasMoreMessages;
  }

  onDataChange(callback: () => void): void {
    this.loadCallbacks.push(callback);
  }

  private notifyCallbacks(): void {
    this.loadCallbacks.forEach(callback => callback());
  }

  async loadConversations(): Promise<void> {
    this.isLoadingConversations = true;
    this.notifyCallbacks();

    try {
      const response = await ChatService.getConversations(1, 20);
      this.conversations = response.conversations;
      this.calculateUnreadCount();
    } catch (error) {
      Logger.error('ChatViewModel', '加载会话列表失败');
    } finally {
      this.isLoadingConversations = false;
      this.notifyCallbacks();
    }
  }

  async loadMessages(conversationId: string): Promise<void> {
    this.currentConversationId = conversationId;
    this.isLoadingMessages = true;
    this.currentPage = 1;
    this.hasMoreMessages = true;
    this.messages = [];
    this.notifyCallbacks();

    try {
      const response = await ChatService.getMessages(conversationId, 1, 50);
      this.messages = response.messages;
      this.hasMoreMessages = response.hasMore;
    } catch (error) {
      Logger.error('ChatViewModel', '加载消息列表失败');
    } finally {
      this.isLoadingMessages = false;
      this.notifyCallbacks();
    }
  }

  async loadMoreMessages(): Promise<void> {
    if (this.isLoadingMessages || !this.hasMoreMessages) {
      return;
    }

    this.isLoadingMessages = true;
    this.currentPage++;
    this.notifyCallbacks();

    try {
      const response = await ChatService.getMessages(
        this.currentConversationId,
        this.currentPage,
        50
      );
      this.messages = [...response.messages, ...this.messages];
      this.hasMoreMessages = response.hasMore;
    } catch (error) {
      Logger.error('ChatViewModel', '加载更多消息失败');
      this.currentPage--;
    } finally {
      this.isLoadingMessages = false;
      this.notifyCallbacks();
    }
  }

  async sendMessage(
    toUserId: string,
    content: string,
    type: MessageType = MessageType.TEXT
  ): Promise<boolean> {
    if (this.isSending || !content.trim()) {
      return false;
    }

    this.isSending = true;
    this.notifyCallbacks();

    try {
      const request: SendMessageRequest = {
        toUserId,
        type,
        content: content.trim()
      };
      const message = await ChatService.sendMessage(request);
      this.messages = [...this.messages, message];
      this.notifyCallbacks();
      return true;
    } catch (error) {
      Logger.error('ChatViewModel', '发送消息失败');
      return false;
    } finally {
      this.isSending = false;
      this.notifyCallbacks();
    }
  }

  async markAsRead(conversationId: string): Promise<void> {
    try {
      await ChatService.markAsRead(conversationId);
      const conversation = this.conversations.find(c => c.id === conversationId);
      if (conversation) {
        conversation.unreadCount = 0;
        this.calculateUnreadCount();
        this.notifyCallbacks();
      }
    } catch (error) {
      Logger.error('ChatViewModel', '标记已读失败');
    }
  }

  private calculateUnreadCount(): void {
    this.unreadCount = this.conversations.reduce(
      (sum, conv) => sum + conv.unreadCount,
      0
    );
  }
}
```

- [ ] **Step 2: Commit**

```bash
git add entry/src/main/ets/viewmodels/ChatViewModel.ets
git commit -m "feat: 添加聊天ViewModel"
```

---

## Chunk 4: Booking Pages

### Task 12: Implement BookingPage (Match List)

**Files:**
- Modify: `entry/src/main/ets/pages/BookingPage.ets`

- [ ] **Step 1: Replace BookingPage with match list implementation**

```typescript
// entry/src/main/ets/pages/BookingPage.ets

import { BookingListViewModel } from '../viewmodels/BookingListViewModel';
import { Booking } from '../models/Booking';
import { BookingStatus } from '../models/Booking';
import router from '@ohos.router';

@Entry
@Component
struct BookingPage {
  @State viewModel: BookingListViewModel = new BookingListViewModel();
  @State bookings: Booking[] = [];
  @State isLoading: boolean = false;
  @State selectedStatus: BookingStatus | null = null;
  @State statusDialogVisible: boolean = false;

  aboutToAppear() {
    this.viewModel.onDataChange(() => {
      this.bookings = this.viewModel.getBookings();
      this.isLoading = this.viewModel.isLoading();
    });
    this.viewModel.loadBookings();
  }

  navigateToDetail(bookingId: string) {
    router.pushUrl({
      url: 'pages/BookingDetailPage',
      params: { bookingId }
    });
  }

  navigateToCreate() {
    router.pushUrl({
      url: 'pages/BookingCreatePage'
    });
  }

  filterByStatus(status: BookingStatus) {
    this.selectedStatus = status;
    this.viewModel.loadBookings(status);
    this.statusDialogVisible = false;
  }

  build() {
    Column() {
      // 头部
      Row() {
        Text('约拍')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .layoutWeight(1)

        Button('发布')
          .fontSize(14)
          .backgroundColor('#1890FF')
          .fontColor(Color.White)
          .borderRadius(15)
          .onClick(() => {
            this.navigateToCreate();
          })

        Button('筛选')
          .fontSize(14)
          .backgroundColor('#F0F0F0')
          .fontColor('#333')
          .borderRadius(15)
          .margin({ left: 8 })
          .onClick(() => {
            this.statusDialogVisible = true;
          })
      }
      .width('100%')
      .padding(16)
      .backgroundColor(Color.White)
    }

    // 状态筛选
    Row({ space: 10 }) {
      this.StatusChip('全部', null)
      this.StatusChip('待确认', BookingStatus.PENDING)
      this.StatusChip('已确认', BookingStatus.CONFIRMED)
      this.StatusChip('进行中', BookingStatus.IN_PROGRESS)
      this.StatusChip('已完成', BookingStatus.COMPLETED)
    }
    .width('100%')
    .padding({ left: 16, right: 16, top: 12, bottom: 12 })
    .backgroundColor(Color.White)
    .margin({ bottom: 8 })

    // 约拍列表
    if (this.isLoading) {
      Column() {
        LoadingProgress()
          .width(40)
          .height(40)
        Text('加载中...')
          .fontSize(14)
          .fontColor('#999')
          .margin({ top: 8 })
      }
      .width('100%')
      .layoutWeight(1)
      .justifyContent(FlexAlign.Center)
    } else if (this.bookings.length === 0) {
      Column() {
        Text('📅')
          .fontSize(64)
          .margin({ bottom: 16 })
        Text('还没有约拍记录')
          .fontSize(16)
          .fontColor('#666')
        Text('发布你的第一个约拍吧')
          .fontSize(14)
          .fontColor('#999')
          .margin({ top: 8 })
      }
      .width('100%')
      .layoutWeight(1)
      .justifyContent(FlexAlign.Center)
    } else {
      List({ space: 8 }) {
        ForEach(this.bookings, (booking: Booking) => {
          ListItem() {
            this.BookingCard(booking)
          }
          .onClick(() => {
            this.navigateToDetail(booking.id);
          })
        })
      }
      .width('100%')
      .layoutWeight(1)
      .padding({ left: 12, right: 12 })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }

  @Builder
  StatusChip(label: string, status: BookingStatus | null) {
    Text(label)
      .fontSize(13)
      .fontColor(
        this.selectedStatus === status ? '#FFFFFF' : '#666666'
      )
      .padding({ left: 12, right: 12, top: 6, bottom: 6 })
      .borderRadius(15)
      .backgroundColor(
        this.selectedStatus === status ? '#1890FF' : '#F5F5F5'
      )
      .onClick(() => {
        this.filterByStatus(status);
      })
  }

  @Builder
  BookingCard(booking: Booking) {
    Row() {
      Column() {
        Image(booking.requester.avatar)
          .width(50)
          .height(50)
          .borderRadius(25)
      }
      .width(50)
      .height(50)

      Column({ space: 6 }) {
        Row() {
          Text(booking.requester.nickname)
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .fontColor('#333')

          Text(this.getStatusText(booking.status))
            .fontSize(12)
            .fontColor('#FFFFFF')
            .padding({ left: 8, right: 8, top: 4, bottom: 4 })
            .borderRadius(10)
            .backgroundColor(this.getStatusColor(booking.status))
        }
        .width('100%')
        .justifyContent(SpaceBetween)

        Text(booking.title)
          .fontSize(15)
          .fontColor('#333')
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })

        Row() {
          Text(booking.style)
            .fontSize(12)
            .fontColor('#1890FF')
            .padding({ left: 6, right: 6, top: 2, bottom: 2 })
            .borderRadius(4)
            .backgroundColor('#E6F7FF')

          Text(`${booking.location.city}`)
            .fontSize(12)
            .fontColor('#666')
            .margin({ left: 8 })

          Text(`${booking.duration}小时`)
            .fontSize(12)
            .fontColor('#666')
            .margin({ left: 8 })

          Text(`¥${booking.fee}`)
            .fontSize(12)
            .fontColor('#FF4D4F')
            .fontWeight(FontWeight.Medium)
            .margin({ left: 8 })
        }
        .width('100%')

        Text(booking.scheduledTime.split('T')[0])
          .fontSize(12)
          .fontColor('#999')
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)
      .margin({ left: 12 })

      Image($r('sys.media.ohos_ic_public_arrow_right'))
        .width(20)
        .height(20)
        .fillColor('#999')
    }
    .width('100%')
    .padding(16)
    .backgroundColor(Color.White)
    .borderRadius(10)
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
```

- [ ] **Step 2: Commit**

```bash
git add entry/src/main/ets/pages/BookingPage.ets
git commit -m "feat: 实现约拍列表页"
```

### Task 13: Create BookingCreatePage.ets

**Files:**
- Create: `entry/src/main/ets/pages/BookingCreatePage.ets`

- [ ] **Step 1: Write the BookingCreatePage implementation**

```typescript
// entry/src/main/ets/pages/BookingCreatePage.ets

import router from '@ohos.router';
import promptAction from '@ohos.promptAction';
import { BookingService } from '../services/BookingService';
import { CreateBookingRequest } from '../models/Booking';

@Entry
@Component
struct BookingCreatePage {
  @State title: string = '';
  @State description: string = '';
  @State style: string = '';
  @State selectedDate: string = '';
  @State selectedTime: string = '';
  @State location: string = '';
  @State city: string = '';
  @State duration: string = '2';
  @State fee: string = '';
  @State isSubmitting: boolean = false;

  navigateBack() {
    router.back();
  }

  async submitBooking() {
    if (!this.title.trim() || !this.location.trim()) {
      promptAction.showToast({ message: '请填写必要信息' });
      return;
    }

    if (!this.style) {
      promptAction.showToast({ message: '请选择拍摄风格' });
      return;
    }

    if (!this.selectedDate || !this.selectedTime) {
      promptAction.showToast({ message: '请选择预约时间' });
      return;
    }

    this.isSubmitting = true;

    try {
      const request: CreateBookingRequest = {
        targetId: '', // TODO: 选择目标用户
        title: this.title.trim(),
        description: this.description.trim(),
        style: this.style,
        scheduledTime: `${this.selectedDate}T${this.selectedTime}:00`,
        location: {
          address: this.location.trim(),
          city: this.city.trim()
        },
        duration: parseInt(this.duration) || 2,
        fee: parseInt(this.fee) || 0
      };

      await BookingService.createBooking(request);
      promptAction.showToast({ message: '约拍请求已发送' });
      router.back();
    } catch (error) {
      promptAction.showToast({ message: '发布失败，请重试' });
    } finally {
      this.isSubmitting = false;
    }
  }

  build() {
    Column() {
      // 头部
      Row() {
        Button('<')
          .fontSize(20)
          .backgroundColor(Color.Transparent)
          .fontColor('#333')
          .onClick(() => {
            this.navigateBack();
          })

        Text('发布约拍')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .layoutWeight(1)

        Button('发布')
          .fontSize(16)
          .backgroundColor('#1890FF')
          .fontColor(Color.White)
          .borderRadius(15)
          .padding({ left: 16, right: 16, top: 8, bottom: 8 })
          .enabled(!this.isSubmitting)
          .onClick(() => {
            this.submitBooking();
          })
      }
      .width('100%')
      .padding(16)
      .backgroundColor(Color.White)
    }

    // 表单内容
    Column({ space: 20 }) {
      // 标题
      Column({ space: 8 }) {
        Text('标题 *')
          .fontSize(14)
          .fontColor('#333')

        TextInput({ placeholder: '请输入约拍标题', text: this.title })
          .width('100%')
          .height(50)
          .backgroundColor('#F5F5F5')
          .borderRadius(8)
          .onChange((value: string) => {
            this.title = value;
          })
      }
      .alignItems(HorizontalAlign.Start)

      // 描述
      Column({ space: 8 }) {
        Text('详细描述')
          .fontSize(14)
          .fontColor('#333')

        TextArea({
          placeholder: '描述你的约拍需求...',
          text: this.description
        })
          .width('100%')
          .height(100)
          .backgroundColor('#F5F5F5')
          .borderRadius(8)
          .onChange((value: string) => {
            this.description = value;
          })
      }
      .alignItems(HorizontalAlign.Start)

      // 风格选择
      Column({ space: 8 }) {
        Text('拍摄风格 *')
          .fontSize(14)
          .fontColor('#333')

        Row({ space: 10 }) {
          this.StyleChip('人像', 'portrait')
          this.StyleChip('风光', 'landscape')
          this.StyleChip('街拍', 'street')
          this.StyleChip('婚纱', 'wedding')
          this.StyleChip('写真', 'artistic')
        }
        .width('100%')
      }
      .alignItems(HorizontalAlign.Start)

      // 时间选择
      Column({ space: 8 }) {
        Text('预约时间 *')
          .fontSize(14)
          .fontColor('#333')

        Row({ space: 10 }) {
          TextInput({
            placeholder: '选择日期',
            text: this.selectedDate
          })
            .width('48%')
            .height(50)
            .backgroundColor('#F5F5F5')
            .borderRadius(8)
            .onClick(() => {
              // TODO: 日期选择器
              promptAction.showToast({ message: '日期选择器即将实现' });
            })

          TextInput({
            placeholder: '选择时间',
            text: this.selectedTime
          })
            .width('48%')
            .height(50)
            .backgroundColor('#F5F5F5')
            .borderRadius(8)
            .onClick(() => {
              // TODO: 时间选择器
              promptAction.showToast({ message: '时间选择器即将实现' });
            })
        }
        .width('100%')
      }
      .alignItems(HorizontalAlign.Start)

      // 地点
      Column({ space: 8 }) {
        Text('拍摄地点 *')
          .fontSize(14)
          .fontColor('#333')

        TextInput({ placeholder: '请输入详细地址', text: this.location })
          .width('100%')
          .height(50)
          .backgroundColor('#F5F5F5')
          .borderRadius(8)
          .onChange((value: string) => {
            this.location = value;
          })
      }
      .alignItems(HorizontalAlign.Start)

      // 城市和时长
      Row({ space: 10 }) {
        Column({ space: 8 }) {
          Text('城市 *')
            .fontSize(14)
            .fontColor('#333')

          TextInput({ placeholder: '城市', text: this.city })
            .width('100%')
            .height(50)
            .backgroundColor('#F5F5F5')
            .borderRadius(8)
            .onChange((value: string) => {
              this.city = value;
            })
        }
        .width('48%')

        Column({ space: 8 }) {
          Text('时长(小时)')
            .fontSize(14)
            .fontColor('#333')

          TextInput({ placeholder: '时长', text: this.duration })
            .width('100%')
            .height(50)
            .backgroundColor('#F5F5F5')
            .borderRadius(8)
            .type(InputType.Number)
            .onChange((value: string) => {
              this.duration = value;
            })
        }
        .width('48%')
      }
      .width('100%')

      // 费用
      Column({ space: 8 }) {
        Text('费用(元)')
          .fontSize(14)
          .fontColor('#333')

        TextInput({ placeholder: '请输入费用', text: this.fee })
          .width('100%')
          .height(50)
          .backgroundColor('#F5F5F5')
          .borderRadius(8)
          .type(InputType.Number)
          .onChange((value: string) => {
            this.fee = value;
          })
      }
      .alignItems(HorizontalAlign.Start)
    }
    .width('100%')
    .layoutWeight(1)
    .padding(16)
    .backgroundColor(Color.White)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }

  @Builder
  StyleChip(label: string, value: string) {
    Text(label)
      .fontSize(14)
      .fontColor(this.style === value ? '#FFFFFF' : '#666666')
      .padding({ left: 12, right: 12, top: 8, bottom: 8 })
      .borderRadius(8)
      .backgroundColor(this.style === value ? '#1890FF' : '#F5F5F5')
      .onClick(() => {
        this.style = value;
      })
  }
}
```

- [ ] **Step 2: Commit**

```bash
git add entry/src/main/ets/pages/BookingCreatePage.ets
git commit -m "feat: 添加发布约拍页面"
```

### Task 14: Create BookingDetailPage.ets

**Files:**
- Create: `entry/src/main/ets/pages/BookingDetailPage.ets`

- [ ] **Step 1: Write the BookingDetailPage implementation**

```typescript
// entry/src/main/ets/pages/BookingDetailPage.ets

import { BookingDetailViewModel } from '../viewmodels/BookingDetailViewModel';
import { Booking, BookingStatus } from '../models/Booking';
import router from '@ohos.router';
import promptAction from '@ohos.promptAction';

@Entry
@Component
struct BookingDetailPage {
  @State viewModel: BookingDetailViewModel = new BookingDetailViewModel();
  @State booking: Booking | null = null;
  @State isLoading: boolean = false;
  private bookingId: string = '';

  aboutToAppear() {
    const params = router.getParams() as Record<string, string>;
    this.bookingId = params?.bookingId || '';

    this.viewModel.onDataChange(() => {
      this.booking = this.viewModel.getBooking();
      this.isLoading = this.viewModel.isLoading();
    });

    if (this.bookingId) {
      this.viewModel.loadBooking(this.bookingId);
    }
  }

  navigateBack() {
    router.back();
  }

  navigateToChat() {
    if (this.booking) {
      router.pushUrl({
        url: 'pages/ChatPage',
        params: {
          userId: this.booking.targetId,
          bookingId: this.bookingId
        }
      });
    }
  }

  async handleAccept() {
    const success = await this.viewModel.acceptBooking();
    if (success) {
      promptAction.showToast({ message: '已接受约拍' });
    }
  }

  async handleReject() {
    promptAction.showDialog({
      title: '确认拒绝',
      message: '确定要拒绝这个约拍请求吗？',
      buttons: [
        { text: '取消', color: '#999' },
        { text: '拒绝', color: '#FF4D4F' }
      ]
    }, async (err, data) => {
      if (data.index === 1) {
        const success = await this.viewModel.rejectBooking();
        if (success) {
          promptAction.showToast({ message: '已拒绝约拍' });
          this.navigateBack();
        }
      }
    });
  }

  async handleCancel() {
    promptAction.showDialog({
      title: '确认取消',
      message: '确定要取消这个约拍吗？',
      buttons: [
        { text: '取消', color: '#999' },
        { text: '确定', color: '#FF4D4F' }
      ]
    }, async (err, data) => {
      if (data.index === 1) {
        const success = await this.viewModel.cancelBooking();
        if (success) {
          promptAction.showToast({ message: '已取消约拍' });
          this.navigateBack();
        }
      }
    });
  }

  async handleComplete() {
    promptAction.showDialog({
      title: '确认完成',
      message: '确认约拍已完成？',
      buttons: [
        { text: '取消', color: '#999' },
        { text: '确认完成', color: '#52C41A' }
      ]
    }, async (err, data) => {
      if (data.index === 1) {
        const success = await this.viewModel.completeBooking();
        if (success) {
          promptAction.showToast({ message: '约拍已完成' });
        }
      }
    });
  }

  build() {
    Column() {
      // 头部
      Row() {
        Button('<')
          .fontSize(20)
          .backgroundColor(Color.Transparent)
          .fontColor('#333')
          .onClick(() => {
            this.navigateBack();
          })

        Text('约拍详情')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .layoutWeight(1)

        if (this.booking) {
          Button('聊天')
            .fontSize(14)
            .backgroundColor('#1890FF')
            .fontColor(Color.White)
            .borderRadius(15)
            .onClick(() => {
              this.navigateToChat();
            })
        }
      }
      .width('100%')
      .padding(16)
      .backgroundColor(Color.White)
    }

    // 内容
    if (this.isLoading) {
      Column() {
        LoadingProgress()
          .width(40)
          .height(40)
        Text('加载中...')
          .fontSize(14)
          .fontColor('#999')
          .margin({ top: 8 })
      }
      .width('100%')
      .layoutWeight(1)
      .justifyContent(FlexAlign.Center)
    } else if (this.booking) {
      Scroll() {
        Column({ space: 16 }) {
          // 状态卡片
          Row() {
            Column() {
              Text(this.viewModel.getStatusText(this.booking.status))
                .fontSize(24)
                .fontWeight(FontWeight.Bold)
                .fontColor(this.viewModel.getStatusColor(this.booking.status))

              Text(this.booking.scheduledTime.split('T')[0])
                .fontSize(14)
                .fontColor('#666')
                .margin({ top: 4 })
            }
            .alignItems(HorizontalAlign.Start)
            .layoutWeight(1)

            this.ActionButtons()
          }
          .width('100%')
          .padding(20)
          .backgroundColor('#F0F8FF')
          .borderRadius(10)

          // 用户信息
          Column({ space: 12 }) {
            Text('对方信息')
              .fontSize(16)
              .fontWeight(FontWeight.Medium)
              .fontColor('#333')

            Row() {
              Image(this.booking.requester.avatar)
                .width(60)
                .height(60)
                .borderRadius(30)

              Column({ space: 4 }) {
                Text(this.booking.requester.nickname)
                  .fontSize(16)
                  .fontWeight(FontWeight.Medium)
                  .fontColor('#333')

                Row({ space: 8 }) {
                  Text(`评分 ${this.booking.requester.rating}`)
                    .fontSize(14)
                    .fontColor('#FFA500')

                  Text(this.booking.requester.role)
                    .fontSize(12)
                    .fontColor('#999')
                }
              }
              .alignItems(HorizontalAlign.Start)
              .margin({ left: 12 })
            }
            .width('100%')
          }
          .width('100%')
          .padding(16)
          .backgroundColor(Color.White)
          .borderRadius(10)

          // 约拍详情
          Column({ space: 12 }) {
            this.DetailItem('标题', this.booking.title)
            this.DetailItem('风格', this.booking.style)
            this.DetailItem('地点', this.booking.location.address)
            this.DetailItem('城市', this.booking.location.city)
            this.DetailItem('时长', `${this.booking.duration} 小时`)
            this.DetailItem('费用', `¥${this.booking.fee}`)
          }
          .width('100%')
          .padding(16)
          .backgroundColor(Color.White)
          .borderRadius(10)

          // 描述
          Column({ space: 8 }) {
            Text('详细描述')
              .fontSize(14)
              .fontColor('#666')

            Text(this.booking.description)
              .fontSize(15)
              .fontColor('#333')
              .lineHeight(24)
          }
          .width('100%')
          .padding(16)
          .backgroundColor(Color.White)
          .borderRadius(10)
        }
        .width('100%')
        .padding(16)
      }
      .layoutWeight(1)
      .scrollBar(BarState.Auto)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }

  @Builder
  ActionButtons() {
    if (this.booking?.status === BookingStatus.PENDING) {
      Row({ space: 10 }) {
        Button('拒绝')
          .fontSize(14)
          .backgroundColor('#FFF1F0')
          .fontColor('#FF4D4F')
          .borderRadius(15)
          .onClick(() => {
            this.handleReject();
          })

        Button('接受')
          .fontSize(14)
          .backgroundColor('#52C41A')
          .fontColor(Color.White)
          .borderRadius(15)
          .onClick(() => {
            this.handleAccept();
          })
      }
    } else if (this.booking?.status === BookingStatus.CONFIRMED) {
      Button('取消约拍')
        .fontSize(14)
        .backgroundColor('#FF4D4F')
        .fontColor(Color.White)
        .borderRadius(15)
        .onClick(() => {
          this.handleCancel();
        })
    } else if (this.booking?.status === BookingStatus.IN_PROGRESS) {
      Button('完成约拍')
        .fontSize(14)
        .backgroundColor('#52C41A')
        .fontColor(Color.White)
        .borderRadius(15)
        .onClick(() => {
          this.handleComplete();
        })
    }
  }

  @Builder
  DetailItem(label: string, value: string) {
    Row() {
      Text(label)
        .fontSize(14)
        .fontColor('#666')
        .width(80)

      Text(value)
        .fontSize(15)
        .fontColor('#333')
        .layoutWeight(1)
    }
    .width('100%')
  }
}
```

- [ ] **Step 2: Commit**

```bash
git add entry/src/main/ets/pages/BookingDetailPage.ets
git commit -m "feat: 添加约拍详情页"
```

### Task 15: Create ProfilePage.ets

**Files:**
- Create: `entry/src/main/ets/pages/ProfilePage.ets`

- [ ] **Step 1: Write the ProfilePage implementation**

```typescript
// entry/src/main/ets/pages/ProfilePage.ets

import { ProfileViewModel } from '../viewmodels/ProfileViewModel';
import { BookingProfile } from '../models/BookingProfile';
import { Booking } from '../models/Booking';
import router from '@ohos.router';

@Entry
@Component
struct ProfilePage {
  @State viewModel: ProfileViewModel = new ProfileViewModel();
  @State profile: BookingProfile | null = null;
  @State isLoading: boolean = false;
  private userId: string = '';

  aboutToAppear() {
    const params = router.getParams() as Record<string, string>;
    this.userId = params?.userId || '';

    this.viewModel.onDataChange(() => {
      this.profile = this.viewModel.getProfile();
      this.isLoading = this.viewModel.isLoading();
    });

    if (this.userId) {
      this.viewModel.loadProfile(this.userId);
    } else {
      this.viewModel.loadMyProfile();
    }
  }

  navigateBack() {
    router.back();
  }

  navigateToBookingDetail(bookingId: string) {
    router.pushUrl({
      url: 'pages/BookingDetailPage',
      params: { bookingId }
    });
  }

  navigateToChat(userId: string) {
    router.pushUrl({
      url: 'pages/ChatPage',
      params: { userId }
    });
  }

  build() {
    Column() {
      // 头部
      Row() {
        Button('<')
          .fontSize(20)
          .backgroundColor(Color.Transparent)
          .fontColor('#333')
          .onClick(() => {
            this.navigateBack();
          })

        Text('个人档案')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .layoutWeight(1)

        if (this.profile) {
          Button('聊天')
            .fontSize(14)
            .backgroundColor('#1890FF')
            .fontColor(Color.White)
            .borderRadius(15)
            .onClick(() => {
              this.navigateToChat(this.profile.userId);
            })
        }
      }
      .width('100%')
      .padding(16)
      .backgroundColor(Color.White)
    }

    // 内容
    if (this.isLoading) {
      Column() {
        LoadingProgress()
          .width(40)
          .height(40)
        Text('加载中...')
          .fontSize(14)
          .fontColor('#999')
          .margin({ top: 8 })
      }
      .width('100%')
      .layoutWeight(1)
      .justifyContent(FlexAlign.Center)
    } else if (this.profile) {
      Scroll() {
        Column({ space: 16 }) {
          // 用户信息卡片
          Column({ space: 12 }) {
            Row() {
              Image(this.profile.avatar)
                .width(80)
                .height(80)
                .borderRadius(40)

              Column({ space: 6 }) {
                Row() {
                  Text(this.profile.nickname)
                    .fontSize(20)
                    .fontWeight(FontWeight.Bold)
                    .fontColor('#333')

                  if (this.profile.isVerified) {
                    Image($r('app.media.ic_verified'))
                      .width(20)
                      .height(20)
                      .margin({ left: 4 })
                  }
                }

                Text(this.profile.role === 'photographer' ? '摄影师' : '模特')
                  .fontSize(14)
                  .fontColor('#1890FF')
                  .padding({ left: 8, right: 8, top: 4, bottom: 4 })
                  .borderRadius(10)
                  .backgroundColor('#E6F7FF')
              }
              .alignItems(HorizontalAlign.Start)
              .layoutWeight(1)
            }
            .width('100%')

            Row({ space: 20 }) {
              this.StatItem('评分', this.profile.rating)
              this.StatItem('评价', this.profile.reviewCount)
              this.StatItem('约拍', this.profile.completedBookings)
            }
            .width('100%')
            .justifyContent(FlexAlign.SpaceAround)
            .margin({ top: 12 })

            Text(this.profile.bio)
              .fontSize(14)
              .fontColor('#666')
              .lineHeight(22)

            // 风格标签
            if (this.profile.styleTags.length > 0) {
              Row({ space: 8 }) {
                ForEach(this.profile.styleTags, (tag: string) => {
                  Text(tag)
                    .fontSize(13)
                    .fontColor('#1890FF')
                    .padding({ left: 10, right: 10, top: 6, bottom: 6 })
                    .borderRadius(15)
                    .backgroundColor('#E6F7FF')
                })
              }
              .width('100%')
              .margin({ top: 12 })
            }
          }
          .width('100%')
          .padding(20)
          .backgroundColor(Color.White)
          .borderRadius(10)

          // 地点和价格
          Row({ space: 10 }) {
            this.InfoCard(
              $r('app.media.ic_location'),
              this.profile.location.city,
              '服务地区'
            )

            if (this.profile.priceRange) {
              this.InfoCard(
                $r('app.media.ic_price'),
                `¥${this.profile.priceRange.min}-${this.profile.priceRange.max}`,
                '价格范围'
              )
            }
          }
          .width('100%')

          // 作品集
          Column({ space: 12 }) {
            Text('作品集')
              .fontSize(16)
              .fontWeight(FontWeight.Medium)
              .fontColor('#333')

            Grid() {
              ForEach(this.profile.portfolio, (item) => {
                GridItem() {
                  Image(item.imageUrl)
                    .width('100%')
                    .aspectRatio(1)
                    .objectFit(ImageFit.Cover)
                    .borderRadius(8)
                }
              })
            }
            .columnsTemplate('1fr 1fr 1fr')
            .columnsGap(8)
            .rowsGap(8)
          }
          .width('100%')
          .padding(16)
          .backgroundColor(Color.White)
          .borderRadius(10)

          // 可约时间
          Column({ space: 8 }) {
            Text('可约时间')
              .fontSize(14)
              .fontColor('#666')

            Row({ space: 12 }) {
              ForEach(['周一', '周二', '周三', '周四', '周五', '周六', '周日'], (day, index) => {
                Text(day)
                  .fontSize(12)
                  .fontColor(this.profile.availability.weekdays[index] ? '#FFFFFF' : '#999')
                  .width(36)
                  .height(36)
                  .borderRadius(18)
                  .textAlign(TextAlign.Center)
                  .backgroundColor(this.profile.availability.weekdays[index] ? '#1890FF' : '#F5F5F5')
              })
            }
            .width('100%')
            .justifyContent(FlexAlign.SpaceBetween)

            Text(`${this.profile.availability.timeRange.start} - ${this.profile.availability.timeRange.end}`)
              .fontSize(14)
              .fontColor('#333')
              .margin({ top: 8 })
          }
          .width('100%')
          .padding(16)
          .backgroundColor(Color.White)
          .borderRadius(10)
        }
        .width('100%')
        .padding(16)
      }
      .layoutWeight(1)
      .scrollBar(BarState.Auto)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }

  @Builder
  StatItem(label: string, value: number) {
    Column() {
      Text(value.toString())
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor('#333')

      Text(label)
        .fontSize(12)
        .fontColor('#999')
        .margin({ top: 4 })
    }
    .alignItems(HorizontalAlign.Center)
  }

  @Builder
  InfoCard(icon: Resource, value: string, label: string) {
    Row() {
      Image(icon)
        .width(24)
        .height(24)
        .margin({ right: 8 })

      Column({ space: 4 }) {
        Text(value)
          .fontSize(15)
          .fontWeight(FontWeight.Medium)
          .fontColor('#333')

        Text(label)
          .fontSize(12)
          .fontColor('#999')
      }
      .alignItems(HorizontalAlign.Start)
    }
    .width('48%')
    .padding(16)
    .backgroundColor(Color.White)
    .borderRadius(10)
  }
}
```

- [ ] **Step 2: Commit**

```bash
git add entry/src/main/ets/pages/ProfilePage.ets
git commit -m "feat: 添加个人档案页"
```

### Task 16: Create ChatPage.ets

**Files:**
- Create: `entry/src/main/ets/pages/ChatPage.ets`

- [ ] **Step 1: Write the ChatPage implementation**

```typescript
// entry/src/main/ets/pages/ChatPage.ets

import { ChatViewModel } from '../viewmodels/ChatViewModel';
import { Message, MessageType } from '../models/Message';
import router from '@ohos.router';

@Entry
@Component
struct ChatPage {
  @State viewModel: ChatViewModel = new ChatViewModel();
  @State messages: Message[] = [];
  @State inputText: string = '';
  @State isLoading: boolean = false;
  @State isSending: boolean = false;
  private userId: string = '';
  private bookingId: string = '';

  aboutToAppear() {
    const params = router.getParams() as Record<string, string>;
    this.userId = params?.userId || '';
    this.bookingId = params?.bookingId || '';

    this.viewModel.onDataChange(() => {
      this.messages = this.viewModel.getMessages();
      this.isLoading = this.viewModel.isLoadingMessages();
      this.isSending = this.viewModel.isSending();
    });

    // 生成会话ID（模拟）
    const conversationId = this.generateConversationId(this.userId);
    this.viewModel.loadMessages(conversationId);
  }

  navigateBack() {
    router.back();
  }

  generateConversationId(userId: string): string {
    // 实际应该从服务器获取或生成
    const myId = 'current_user_id'; // TODO: 获取当前用户ID
    return [myId, userId].sort().join('_');
  }

  async sendMessage() {
    if (!this.inputText.trim()) {
      return;
    }

    const success = await this.viewModel.sendMessage(
      this.userId,
      this.inputText,
      MessageType.TEXT
    );

    if (success) {
      this.inputText = '';
    }
  }

  isMyMessage(message: Message): boolean {
    // TODO: 判断是否是自己的消息
    return true;
  }

  build() {
    Column() {
      // 头部
      Row() {
        Button('<')
          .fontSize(20)
          .backgroundColor(Color.Transparent)
          .fontColor('#333')
          .onClick(() => {
            this.navigateBack();
          })

        Text('聊天')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .layoutWeight(1)
      }
      .width('100%')
      .padding(16)
      .backgroundColor(Color.White)
      .border({ width: { bottom: 1 }, color: '#E8E8E8' })
    }

    // 消息列表
    if (this.isLoading) {
      Column() {
        LoadingProgress()
          .width(40)
          .height(40)
        Text('加载中...')
          .fontSize(14)
          .fontColor('#999')
          .margin({ top: 8 })
      }
      .width('100%')
      .layoutWeight(1)
      .justifyContent(FlexAlign.Center)
    } else {
      List({ space: 12 }) {
        ForEach(this.messages, (message: Message) => {
          ListItem() {
            this.MessageBubble(message)
          }
        })
      }
      .width('100%')
      .layoutWeight(1)
      .padding({ left: 12, right: 12, top: 12 })
      .backgroundColor('#F5F5F5')
      .alignListItem(LIST_ALIGN_CENTER)
    }

    // 输入框
    Row({ space: 8 }) {
      Button('+')
        .fontSize(24)
        .width(44)
        .height(44)
        .backgroundColor('#F5F5F5')
        .fontColor('#666')
        .borderRadius(22)
        .onClick(() => {
          // TODO: 选择图片
        })

      TextInput({
        placeholder: '输入消息...',
        text: this.inputText
      })
        .layoutWeight(1)
        .height(44)
        .backgroundColor('#F5F5F5')
        .borderRadius(22)
        .onChange((value: string) => {
          this.inputText = value;
        })

      Button('发送')
        .fontSize(15)
        .width(60)
        .height(44)
        .backgroundColor(this.inputText.trim() ? '#1890FF' : '#B8B8B8')
        .fontColor(Color.White)
        .borderRadius(22)
        .enabled(!this.isSending && this.inputText.trim())
        .onClick(() => {
          this.sendMessage();
        })
    }
    .width('100%')
    .padding(12)
    .backgroundColor(Color.White)
  }

  @Builder
  MessageBubble(message: Message) {
    Row() {
      if (!this.isMyMessage(message)) {
        Image($r('app.media.default_avatar'))
          .width(40)
          .height(40)
          .borderRadius(20)
          .margin({ right: 8 })
      }

      Column() {
        Text(message.content)
          .fontSize(15)
          .fontColor(this.isMyMessage(message) ? '#FFFFFF' : '#333333')
          .padding(12)
          .borderRadius(8)
          .backgroundColor(this.isMyMessage(message) ? '#1890FF' : '#FFFFFF')

        Text(message.createdAt.split('T')[1]?.substring(0, 5) || '')
          .fontSize(11)
          .fontColor('#999')
          .margin({ top: 4 })
      }
      .alignItems(this.isMyMessage(message) ? HorizontalAlign.End : HorizontalAlign.Start)
      .layoutWeight(1)

      if (this.isMyMessage(message)) {
        Image($r('app.media.my_avatar'))
          .width(40)
          .height(40)
          .borderRadius(20)
          .margin({ left: 8 })
      }
    }
    .width('100%')
    .justifyContent(this.isMyMessage(message) ? FlexAlign.End : FlexAlign.Start)
  }
}
```

- [ ] **Step 2: Commit**

```bash
git add entry/src/main/ets/pages/ChatPage.ets
git commit -m "feat: 添加聊天页面"
```

---

## Chunk 5: Final Integration

### Task 17: Update Route Configuration

**Files:**
- Modify: `entry/src/main/resources/base/profile/main_pages.json`

- [ ] **Step 1: Add new pages to route config**

```json
{
  "src": [
    "pages/SplashPage",
    "pages/LoginPage",
    "pages/RegisterPage",
    "pages/MainPage",
    "pages/HomePage",
    "pages/PhotoPage",
    "pages/BookingPage",
    "pages/LearnPage",
    "pages/MinePage",
    "pages/AlbumDetailPage",
    "pages/PhotoDetailPage",
    "pages/TagManagementPage",
    "pages/PostDetailPage",
    "pages/PostCreatePage",
    "pages/NotificationListPage",
    "pages/BookingCreatePage",
    "pages/BookingDetailPage",
    "pages/ProfilePage",
    "pages/ChatPage"
  ]
}
```

- [ ] **Step 2: Commit**

```bash
git add entry/src/main/resources/base/profile/main_pages.json
git commit -m "feat: 添加约拍模块页面到路由配置"
```

---

## Completion Checklist

- [ ] All data models created (4 files)
- [ ] All services created (3 files)
- [ ] All ViewModels created (4 files)
- [ ] All pages created (4 new + 1 modified)
- [ ] Route configuration updated
- [ ] All changes committed

---

**Plan complete and saved to `docs/superpowers/plans/2026-03-14-phase4-booking.md`. Ready to execute?**
