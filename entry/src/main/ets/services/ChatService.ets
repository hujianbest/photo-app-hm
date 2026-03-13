import { HttpService } from './HttpService';
import { HttpResponse } from '../models/HttpResponse';
import { Message, SendMessageRequest, Conversation, MessageListResponse, MessageType } from '../models/Message';
import { Logger } from '../common/utils/Logger';

export class ChatService {
  private static readonly ENDPOINT = '/messages';

  static async getConversations(page: number = 1, pageSize: number = 20): Promise<{ conversations: Conversation[]; hasMore: boolean }> {
    try {
      const response = await HttpService.get<{ conversations: Conversation[]; hasMore: boolean }>(`${ChatService.ENDPOINT}/conversations?page=${page}&pageSize=${pageSize}`);
      Logger.info('ChatService', '获取会话列表');
      return response;
    } catch (error) {
      Logger.error('ChatService', '获取会话列表失败');
      throw error;
    }
  }

  static async getMessages(conversationId: string, page: number = 1, pageSize: number = 50): Promise<MessageListResponse> {
    try {
      const response = await HttpService.get<MessageListResponse>(`${ChatService.ENDPOINT}/${conversationId}?page=${page}&pageSize=${pageSize}`);
      Logger.info('ChatService', '获取消息列表');
      return response;
    } catch (error) {
      Logger.error('ChatService', '获取消息列表失败');
      throw error;
    }
  }

  static async sendMessage(request: SendMessageRequest): Promise<Message> {
    try {
      const response = await HttpService.post<Message, SendMessageRequest>(ChatService.ENDPOINT, request);
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
