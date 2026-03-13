import { HttpService } from './HttpService';
import { StorageService } from './StorageService';
import { Constants } from '../common/constants/Constants';
import { Logger } from '../common/utils/Logger';
import { User, LoginRequest, RegisterRequest, LoginResponse, UpdateProfileRequest } from '../models/User';

export class AuthService {
  static async register(request: RegisterRequest): Promise<LoginResponse> {
    try {
      const response = await HttpService.post<LoginResponse>('/auth/register', request);
      
      await this.saveAuthData(response.data.token, response.data.user);
      
      return response.data;
    } catch (error) {
      Logger.error('AuthService', 'Register failed: %{public}s', JSON.stringify(error));
      throw error;
    }
  }

  static async login(request: LoginRequest): Promise<LoginResponse> {
    try {
      const response = await HttpService.post<LoginResponse>('/auth/login', request);
      
      await this.saveAuthData(response.data.token, response.data.user);
      
      return response.data;
    } catch (error) {
      Logger.error('AuthService', 'Login failed: %{public}s', JSON.stringify(error));
      throw error;
    }
  }

  static async logout(): Promise<void> {
    try {
      await HttpService.post<void>('/auth/logout');
    } catch (error) {
      Logger.warn('AuthService', 'Logout API call failed, clearing local data anyway');
    } finally {
      await StorageService.remove(Constants.TOKEN_KEY);
      await StorageService.remove(Constants.USER_INFO_KEY);
      HttpService.setToken('');
    }
  }

  static async getCurrentUser(): Promise<User | null> {
    return await StorageService.getObject<User>(Constants.USER_INFO_KEY, null);
  }

  static async getToken(): Promise<string | null> {
    return await StorageService.getString(Constants.TOKEN_KEY, '');
  }

  static async updateProfile(request: UpdateProfileRequest): Promise<User> {
    try {
      const response = await HttpService.put<User>('/users/profile', request);
      
      await StorageService.putObject(Constants.USER_INFO_KEY, response.data);
      
      return response.data;
    } catch (error) {
      Logger.error('AuthService', 'Update profile failed: %{public}s', JSON.stringify(error));
      throw error;
    }
  }

  static async isLoggedIn(): Promise<boolean> {
    const token = await this.getToken();
    return !!token;
  }

  private static async saveAuthData(token: string, user: User): Promise<void> {
    HttpService.setToken(token);
    await StorageService.putString(Constants.TOKEN_KEY, token);
    await StorageService.putObject(Constants.USER_INFO_KEY, user);
  }
}
