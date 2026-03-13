export interface Photo {
  id: number;                    // 照片ID（自增主键）
  albumId: number;               // 所属相册ID
  originalPath: string;          // 原始照片路径（系统相册路径）
  thumbnailPath: string;         // 缩略图路径（应用生成）
  width: number;                 // 照片宽度
  height: number;                // 照片高度
  size: number;                  // 文件大小（字节）
  takenAt: number;               // 拍摄时间（从EXIF读取）
  location: string;              // 拍摄地点（从EXIF读取）
  tags: string;                  // 标签（JSON数组字符串）
  createdAt: number;             // 添加时间戳
}

export interface CreatePhotoRequest {
  albumId: number;
  originalPath: string;
  thumbnailPath?: string;
  width?: number;
  height?: number;
  size?: number;
  takenAt?: number;
  location?: string;
  tags?: string[];
}

export interface UpdatePhotoRequest {
  tags?: string[];
  location?: string;
}
