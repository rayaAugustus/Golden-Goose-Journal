# 数据模型草案

## 1. Transaction（账目）
| 字段 | 类型（SQLite） | 必填 | 说明 |
| --- | --- | --- | --- |
| id | TEXT | 是 | 唯一标识（UUID） |
| type | TEXT | 是 | 收入/支出（income/expense） |
| amount | REAL | 是 | 金额，>0 |
| category_id | TEXT | 否 | 分类 |
| note | TEXT | 否 | 备注 |
| occurred_at | TEXT | 是 | 发生时间（ISO 8601） |
| created_at | TEXT | 是 | 创建时间（ISO 8601） |
| updated_at | TEXT | 是 | 更新时间（ISO 8601） |

## 2. JournalEntry（日记）
| 字段 | 类型（SQLite） | 必填 | 说明 |
| --- | --- | --- | --- |
| id | TEXT | 是 | 唯一标识（UUID） |
| title | TEXT | 否 | 标题 |
| content | TEXT | 是 | 正文 |
| mood | TEXT | 否 | 情绪标签 |
| entry_date | TEXT | 是 | 日记日期（YYYY-MM-DD） |
| created_at | TEXT | 是 | 创建时间（ISO 8601） |
| updated_at | TEXT | 是 | 更新时间（ISO 8601） |

## 3. Goal（目标）
| 字段 | 类型（SQLite） | 必填 | 说明 |
| --- | --- | --- | --- |
| id | TEXT | 是 | 唯一标识（UUID） |
| name | TEXT | 是 | 目标名称 |
| target_amount | REAL | 是 | 目标金额 |
| current_amount | REAL | 是 | 当前金额 |
| due_date | TEXT | 否 | 截止日期（YYYY-MM-DD） |
| status | TEXT | 是 | 状态（active/completed/archived） |
| created_at | TEXT | 是 | 创建时间（ISO 8601） |
| updated_at | TEXT | 是 | 更新时间（ISO 8601） |

## 4. Category（分类）
| 字段 | 类型（SQLite） | 必填 | 说明 |
| --- | --- | --- | --- |
| id | TEXT | 是 | 唯一标识（UUID） |
| name | TEXT | 是 | 分类名称 |
| type | TEXT | 是 | 适用类型（income/expense） |
| created_at | TEXT | 是 | 创建时间（ISO 8601） |
| updated_at | TEXT | 是 | 更新时间（ISO 8601） |

## 5. 关系说明
- Transaction 可关联 0..1 个 Category
- Goal 与 Transaction 通过统计关联（不做强关联）
