import { BookingStatus } from '../common/constants/Constants';

export interface Booking {
  id: string;
  photographerId: string;
  modelId: string;
  photographer: {
    id: string;
    nickname: string;
    avatar: string;
  };
  model: {
    id: string;
    nickname: string;
    avatar: string;
  };
  status: BookingStatus;
  scheduledDate: string;
  location: string;
  description: string;
  photos: string[];
  createdAt: string;
  updatedAt: string;
}
