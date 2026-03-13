export interface Album {
  id: number;                    // 相册ID（自增主键）
  name: string;                  // 相册名称
  coverPhotoPath: string;        // 封面照片路径
  photoCount: number;            // 照片数量（冗余字段）
  description: string;           // 相册描述
  createdAt: number;             // 创建时间戳
  updatedAt: number;             // 更新时间戳
}

export interface CreateAlbumRequest {
  name: string;
  description?: string;
}

export interface UpdateAlbumRequest {
  name?: string;
  description?: string;
  coverPhotoPath?: string;
}
