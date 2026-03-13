import http from '@ohos.net.http';
import { Constants } from '../common/constants/Constants';
import { Logger } from '../common/utils/Logger';
import { HttpResponse } from '../models/HttpResponse';

export class HttpService {
  private static token: string = '';

  static setToken(token: string): void {
    this.token = token;
  }

  static getToken(): string {
    return this.token;
  }

  static getHeaders(): Record<string, string> {
    const headers: Record<string, string> = {
      'Content-Type': 'application/json',
      'Accept': 'application/json'
    };
    
    if (this.token) {
      headers['Authorization'] = `Bearer ${this.token}`;
    }
    
    return headers;
  }

  static async get<T>(path: string, params?: Record<string, any>): Promise<HttpResponse<T>> {
    let url = `${Constants.API_BASE_URL}${path}`;
    
    if (params) {
      const queryString = Object.keys(params)
        .map(key => `${encodeURIComponent(key)}=${encodeURIComponent(params[key])}`)
        .join('&');
      url += `?${queryString}`;
    }

    return this.request<T>('GET', url);
  }

  static async post<T>(path: string, body?: any): Promise<HttpResponse<T>> {
    const url = `${Constants.API_BASE_URL}${path}`;
    return this.request<T>('POST', url, body);
  }

  static async put<T>(path: string, body?: any): Promise<HttpResponse<T>> {
    const url = `${Constants.API_BASE_URL}${path}`;
    return this.request<T>('PUT', url, body);
  }

  static async delete<T>(path: string): Promise<HttpResponse<T>> {
    const url = `${Constants.API_BASE_URL}${path}`;
    return this.request<T>('DELETE', url);
  }

  private static async request<T>(
    method: http.RequestMethod,
    url: string,
    body?: any
  ): Promise<HttpResponse<T>> {
    const httpRequest = http.createHttp();
    
    try {
      Logger.info('HttpService', `${method} ${url}`);
      
      const options: http.HttpRequestOptions = {
        method: method,
        header: this.getHeaders(),
        readTimeout: 30000,
        connectTimeout: 30000
      };

      if (body) {
        options.extraData = JSON.stringify(body);
      }

      const response = await httpRequest.request(url, options);
      
      Logger.info('HttpService', `Response: ${response.responseCode}`);
      
      if (response.responseCode === 200 || response.responseCode === 201) {
        return JSON.parse(response.result as string) as HttpResponse<T>;
      } else {
        throw new Error(`HTTP Error: ${response.responseCode}`);
      }
    } catch (error) {
      Logger.error('HttpService', 'Request failed: %{public}s', JSON.stringify(error));
      throw error;
    } finally {
      httpRequest.destroy();
    }
  }
}
