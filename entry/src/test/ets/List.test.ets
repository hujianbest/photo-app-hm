import storageServiceTest from './services/StorageService.test';
import httpServiceTest from './services/HttpService.test';
import authServiceTest from './services/AuthService.test';

export default function testsuite() {
  storageServiceTest();
  httpServiceTest();
  authServiceTest();
}
