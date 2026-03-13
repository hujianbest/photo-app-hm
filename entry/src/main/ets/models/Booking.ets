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
