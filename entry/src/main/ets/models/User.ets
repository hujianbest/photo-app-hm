import { UserRole } from '../common/constants/Constants';

export interface User {
  id: string;
  phone?: string;
  email?: string;
  nickname: string;
  avatar: string;
  bio: string;
  role: UserRole;
  styleTags: string[];
  followersCount: number;
  followingCount: number;
  worksCount: number;
  rating: number;
  isVerified: boolean;
  createdAt: string;
  updatedAt: string;
}

export interface LoginRequest {
  phone?: string;
  email?: string;
  password: string;
}

export interface RegisterRequest {
  phone?: string;
  email?: string;
  password: string;
  nickname: string;
  role: UserRole;
}

export interface LoginResponse {
  token: string;
  user: User;
}

export interface UpdateProfileRequest {
  nickname?: string;
  avatar?: string;
  bio?: string;
  styleTags?: string[];
}
