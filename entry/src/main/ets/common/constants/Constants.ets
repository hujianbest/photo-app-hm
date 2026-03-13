export class Constants {
  static readonly APP_NAME = '摄影圈';
  static readonly API_BASE_URL = 'https://api.photoapp.com/v1';
  static readonly PAGE_SIZE = 20;
  static readonly MAX_RETRY_COUNT = 3;
  static readonly TOKEN_KEY = 'user_token';
  static readonly USER_INFO_KEY = 'user_info';
}

export enum UserRole {
  PHOTOGRAPHER = 'photographer',
  MODEL = 'model'
}

export enum BookingStatus {
  PENDING = 'pending',
  ACCEPTED = 'accepted',
  REJECTED = 'rejected',
  COMPLETED = 'completed'
}
