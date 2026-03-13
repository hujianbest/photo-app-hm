export enum MessageType {
  TEXT = 'text',
  IMAGE = 'image',
  BOOKING = 'booking',
  SYSTEM = 'system'
}

export interface Message {
  id: string;
  conversationId: string;
  fromUserId: string;
  toUserId: string;
  type: MessageType;
  content: string;
  imageUrl?: string;
  bookingId?: string;
  isRead: boolean;
  createdAt: string;
}

export interface SendMessageRequest {
  toUserId: string;
  type: MessageType;
  content: string;
  imageUrl?: string;
  bookingId?: string;
}

export interface Conversation {
  id: string;
  userId: string;
  otherUser: {
    id: string;
    nickname: string;
    avatar: string;
    role: string;
  };
  lastMessage: Message;
  unreadCount: number;
  updatedAt: string;
}

export interface MessageListResponse {
  messages: Message[];
  hasMore: boolean;
  nextCursor?: string;
}
