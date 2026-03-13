import dataPreferences from '@ohos.data.preferences';
import common from '@ohos.app.ability.common';
import { Logger } from '../common/utils/Logger';

export class StorageService {
  private static preferences: dataPreferences.Preferences | null = null;
  private static readonly STORE_NAME = 'photo_app_store';

  static async init(context: common.Context): Promise<void> {
    try {
      this.preferences = await dataPreferences.getPreferences(context, this.STORE_NAME);
      Logger.info('StorageService', 'Storage initialized successfully');
    } catch (error) {
      Logger.error('StorageService', 'Failed to init storage: %{public}s', JSON.stringify(error));
      throw error;
    }
  }

  static async putString(key: string, value: string): Promise<void> {
    if (!this.preferences) {
      throw new Error('Storage not initialized');
    }
    await this.preferences.put(key, value);
    await this.preferences.flush();
  }

  static async getString(key: string, defaultValue: string): Promise<string> {
    if (!this.preferences) {
      throw new Error('Storage not initialized');
    }
    return await this.preferences.get(key, defaultValue) as string;
  }

  static async putObject(key: string, value: object): Promise<void> {
    await this.putString(key, JSON.stringify(value));
  }

  static async getObject<T>(key: string, defaultValue: T): Promise<T> {
    const str = await this.getString(key, '');
    if (!str) {
      return defaultValue;
    }
    try {
      return JSON.parse(str) as T;
    } catch (error) {
      Logger.error('StorageService', 'Failed to parse object: %{public}s', JSON.stringify(error));
      return defaultValue;
    }
  }

  static async remove(key: string): Promise<void> {
    if (!this.preferences) {
      throw new Error('Storage not initialized');
    }
    await this.preferences.delete(key);
    await this.preferences.flush();
  }

  static async clear(): Promise<void> {
    if (!this.preferences) {
      throw new Error('Storage not initialized');
    }
    await this.preferences.clear();
    await this.preferences.flush();
  }
}
