import relationalStore from '@ohos.data.relationalStore';
import { Tag, CreateTagRequest, UpdateTagRequest } from '../models/Tag';
import { DatabaseService } from './DatabaseService';
import { Logger } from '../common/utils/Logger';

export class TagService {
  static async getAllTags(): Promise<Tag[]> {
    try {
      const resultSet = await DatabaseService.query(
        'SELECT * FROM tags ORDER BY photoCount DESC, id ASC',
        []
      );
      const tags: Tag[] = [];
      if (resultSet.rowCount > 0) {
        resultSet.goToFirstRow();
        do {
          tags.push(TagService.mapResultSetToTag(resultSet));
        } while (resultSet.goToNextRow());
      }
      resultSet.close();
      return tags;
    } catch (error) {
      Logger.error('TagService', '获取所有标签失败: %{public}s', JSON.stringify(error));
      throw error;
    }
  }

  static async createTag(name: string, color: string = '#1890FF'): Promise<Tag> {
    const values: relationalStore.ValuesBucket = {
      name: name,
      color: color,
      photoCount: 0
    };

    try {
      const rowId = await DatabaseService.insert('tags', values);
      const tag = await TagService.getTagById(rowId);
      if (!tag) {
        throw new Error('创建标签失败');
      }
      Logger.info('TagService', '标签创建成功: %{public}s', name);
      return tag;
    } catch (error) {
      Logger.error('TagService', '创建标签失败: %{public}s', JSON.stringify(error));
      throw error;
    }
  }

  static async updateTag(id: number, updates: Partial<UpdateTagRequest>): Promise<Tag> {
    const values: relationalStore.ValuesBucket = {};

    if (updates.name !== undefined) {
      values['name'] = updates.name;
    }
    if (updates.color !== undefined) {
      values['color'] = updates.color;
    }

    try {
      const predicates = new relationalStore.RdbPredicates('tags');
      predicates.equalTo('id', id);
      const rowsAffected = await DatabaseService.update('tags', values, predicates);
      if (rowsAffected === 0) {
        throw new Error('标签未找到');
      }
      const tag = await TagService.getTagById(id);
      if (!tag) {
        throw new Error('更新标签失败');
      }
      Logger.info('TagService', '标签更新成功: %{public}d', id);
      return tag;
    } catch (error) {
      Logger.error('TagService', '更新标签失败: %{public}s', JSON.stringify(error));
      throw error;
    }
  }

  static async deleteTag(id: number): Promise<void> {
    try {
      const predicates = new relationalStore.RdbPredicates('tags');
      predicates.equalTo('id', id);
      const rowsAffected = await DatabaseService.delete('tags', predicates);
      if (rowsAffected === 0) {
        throw new Error('标签未找到');
      }
      Logger.info('TagService', '标签删除成功: %{public}d', id);
    } catch (error) {
      Logger.error('TagService', '删除标签失败: %{public}s', JSON.stringify(error));
      throw error;
    }
  }

  static async getTagById(id: number): Promise<Tag | null> {
    try {
      const resultSet = await DatabaseService.query(
        'SELECT * FROM tags WHERE id = ?',
        [id]
      );
      if (resultSet.rowCount === 0) {
        resultSet.close();
        return null;
      }
      resultSet.goToFirstRow();
      const tag = TagService.mapResultSetToTag(resultSet);
      resultSet.close();
      return tag;
    } catch (error) {
      Logger.error('TagService', '获取标签失败: %{public}s', JSON.stringify(error));
      throw error;
    }
  }

  private static mapResultSetToTag(resultSet: relationalStore.ResultSet): Tag {
    return {
      id: resultSet.getLong(resultSet.getColumnIndex('id')),
      name: resultSet.getString(resultSet.getColumnIndex('name')),
      color: resultSet.getString(resultSet.getColumnIndex('color')),
      photoCount: resultSet.getLong(resultSet.getColumnIndex('photoCount'))
    };
  }
}
