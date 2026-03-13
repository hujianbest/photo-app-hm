import { Booking } from './Booking';

export interface BookingProfile {
  id: string;
  userId: string;
  role: 'photographer' | 'model';
  nickname: string;
  avatar: string;
  bio: string;
  styleTags: string[];
  rating: number;
  reviewCount: number;
  completedBookings: number;
  portfolio: PortfolioItem[];
  location: {
    city: string;
    area?: string;
  };
  availability: Availability;
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
  weekdays: boolean[];
  timeRange: {
    start: string;
    end: string;
  };
  advanceDays: number;
}

export interface ProfileResponse {
  profile: BookingProfile;
  recentBookings: Booking[];
}
