// entry/src/main/ets/models/BookingFilters.ets

export interface BookingFilters {
  role?: 'photographer' | 'model';
  style?: string;
  city?: string;
  minRating?: number;
  maxFee?: number;
  sortBy?: 'rating' | 'distance' | 'recent';
  page?: number;
  pageSize?: number;
}

export interface RecommendationParams {
  stylePreferences: string[];
  location: {
    latitude: number;
    longitude: number;
    city: string;
  };
  radius?: number;
}
