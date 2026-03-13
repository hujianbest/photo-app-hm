export interface Post {
  id: string;
  userId: string;
  user: {
    id: string;
    nickname: string;
    avatar: string;
    isVerified: boolean;
  };
  content: string;
  photos: any[];
  topic: Topic | null;
  likeCount: number;
  commentCount: number;
  isLiked: boolean;
  isCollected: boolean;
  createdAt: string;
  updatedAt: string;
}

export interface CreatePostRequest {
  content: string;
  photoIds: string[];
  topicId?: string;
}

export interface UpdatePostRequest {
  content?: string;
  topicId?: string;
}
