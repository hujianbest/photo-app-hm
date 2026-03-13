export interface ExifInfo {
  make: string;                  // 相机品牌
  model: string;                 // 相机型号
  dateTime: string;              // 拍摄时间
  exposureTime: string;          // 曝光时间
  fNumber: string;               // 光圈值
  iso: number;                   // ISO感光度
  focalLength: string;           // 焦距
  gpsLatitude: string;           // 纬度
  gpsLongitude: string;          // 经度
}
