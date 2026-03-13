export interface Comment {
  id: string;
  userId: string;
  postId: string;
  user: {
    id: string;
    nickname: string;
    avatar: string;
  };
  content: string;
  parentId: string | null;
  likeCount: number;
  isLiked: boolean;
  createdAt: string;
}

export interface CreateCommentRequest {
  postId: string;
  content: string;
  parentId?: string;
}
