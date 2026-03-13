export interface NotificationItem {
  id: string;
  userId: string;
  type: 'like' | 'comment' | 'follow' | 'mention';
  fromUser: {
    id: string;
    nickname: string;
    avatar: string;
  };
  content: string;
  targetId: string | null; // post_id, comment_id, etc.
  targetType: 'post' | 'comment' | 'user' | null;
  isRead: boolean;
  createdAt: string;
}
