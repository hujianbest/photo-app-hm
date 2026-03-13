import { Message, SendMessageRequest, Conversation, MessageType } from '../models/Message';
import { ChatService } from '../services/ChatService';
import { Logger } from '../common/utils/Logger';

export class ChatViewModel {
  private messages: Message[] = [];
  private conversations: Conversation[] = [];
  private currentConversationId: string = '';
  private isLoadingMessages: boolean = false;
  private isLoadingConversations: boolean = false;
  private isSending: boolean = false;
  private hasMoreMessages: boolean = true;
  private currentPage: number = 1;
  private unreadCount: number = 0;
  private loadCallbacks: Array<() => void> = [];

  getMessages(): Message[] {
    return this.messages;
  }

  getConversations(): Conversation[] {
    return this.conversations;
  }

  isLoadingMessages(): boolean {
    return this.isLoadingMessages;
  }

  isLoadingConversations(): boolean {
    return this.isLoadingConversations;
  }

  isSending(): boolean {
    return this.isSending;
  }

  getUnreadCount(): number {
    return this.unreadCount;
  }

  hasMoreMessages(): boolean {
    return this.hasMoreMessages;
  }

  onDataChange(callback: () => void): void {
    this.loadCallbacks.push(callback);
  }

  private notifyCallbacks(): void {
    this.loadCallbacks.forEach(callback => callback());
  }

  async loadConversations(): Promise<void> {
    this.isLoadingConversations = true;
    this.notifyCallbacks();

    try {
      const response = await ChatService.getConversations(1, 20);
      this.conversations = response.conversations;
      this.calculateUnreadCount();
    } catch (error) {
      Logger.error('ChatViewModel', '加载会话列表失败');
    } finally {
      this.isLoadingConversations = false;
      this.notifyCallbacks();
    }
  }

  async loadMessages(conversationId: string): Promise<void> {
    this.currentConversationId = conversationId;
    this.isLoadingMessages = true;
    this.currentPage = 1;
    this.hasMoreMessages = true;
    this.messages = [];
    this.notifyCallbacks();

    try {
      const response = await ChatService.getMessages(conversationId, 1, 50);
      this.messages = response.messages;
      this.hasMoreMessages = response.hasMore;
    } catch (error) {
      Logger.error('ChatViewModel', '加载消息列表失败');
    } finally {
      this.isLoadingMessages = false;
      this.notifyCallbacks();
    }
  }

  async loadMoreMessages(): Promise<void> {
    if (this.isLoadingMessages || !this.hasMoreMessages) {
      return;
    }

    this.isLoadingMessages = true;
    this.currentPage++;
    this.notifyCallbacks();

    try {
      const response = await ChatService.getMessages(this.currentConversationId, this.currentPage, 50);
      this.messages = [...response.messages, ...this.messages];
      this.hasMoreMessages = response.hasMore;
    } catch (error) {
      Logger.error('ChatViewModel', '加载更多消息失败');
      this.currentPage--;
    } finally {
      this.isLoadingMessages = false;
      this.notifyCallbacks();
    }
  }

  async sendMessage(toUserId: string, content: string, type: MessageType = MessageType.TEXT): Promise<boolean> {
    if (this.isSending || !content.trim()) {
      return false;
    }

    this.isSending = true;
    this.notifyCallbacks();

    try {
      const request: SendMessageRequest = {
        toUserId,
        type,
        content: content.trim()
      };
      const message = await ChatService.sendMessage(request);
      this.messages = [...this.messages, message];
      this.notifyCallbacks();
      return true;
    } catch (error) {
      Logger.error('ChatViewModel', '发送消息失败');
      return false;
    } finally {
      this.isSending = false;
      this.notifyCallbacks();
    }
  }

  async markAsRead(conversationId: string): Promise<void> {
    try {
      await ChatService.markAsRead(conversationId);
      const conversation = this.conversations.find(c => c.id === conversationId);
      if (conversation) {
        conversation.unreadCount = 0;
        this.calculateUnreadCount();
        this.notifyCallbacks();
      }
    } catch (error) {
      Logger.error('ChatViewModel', '标记已读失败');
    }
  }

  private calculateUnreadCount(): void {
    this.unreadCount = this.conversations.reduce(
      (sum, conv) => sum + conv.unreadCount,
      0
    );
  }
}
