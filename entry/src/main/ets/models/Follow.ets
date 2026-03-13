export interface Follow {
  id: string;
  followerId: string;
  followingId: string;
  createdAt: string;
}

export interface Following {
  id: string;
  user: {
    id: string;
    nickname: string;
    avatar: string;
    bio: string;
    followerCount: number;
    worksCount: number;
    isVerified: boolean;
  };
  isFollowing: boolean;
  createdAt: string;
}
