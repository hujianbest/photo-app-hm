export interface Tag {
  id: number;                    // 标签ID
  name: string;                  // 标签名称
  color: string;                 // 标签颜色（HEX格式）
  photoCount: number;            // 关联照片数量
}

export interface CreateTagRequest {
  name: string;
  color?: string;
}

export interface UpdateTagRequest {
  name?: string;
  color?: string;
}
