export interface Topic {
  id: string;
  name: string;
  description: string;
  coverImage: string;
  postCount: number;
  followerCount: number;
  isFollowed: boolean;
  createdAt: string;
}

export interface CreateTopicRequest {
  name: string;
  description: string;
}
