# 数据模型草案

## 1. Transaction（账目）
| 字段 | 类型 | 必填 | 说明 |
| --- | --- | --- | --- |
| id | string | 是 | 唯一标识 |
| type | enum(income, expense) | 是 | 收入/支出 |
| amount | number | 是 | 金额，>0 |
| category_id | string | 否 | 分类 |
| note | string | 否 | 备注 |
| occurred_at | datetime | 是 | 发生时间 |
| created_at | datetime | 是 | 创建时间 |
| updated_at | datetime | 是 | 更新时间 |

## 2. JournalEntry（日记）
| 字段 | 类型 | 必填 | 说明 |
| --- | --- | --- | --- |
| id | string | 是 | 唯一标识 |
| title | string | 否 | 标题 |
| content | text | 是 | 正文 |
| mood | string | 否 | 情绪标签 |
| entry_date | date | 是 | 日记日期 |
| created_at | datetime | 是 | 创建时间 |
| updated_at | datetime | 是 | 更新时间 |

## 3. Goal（目标）
| 字段 | 类型 | 必填 | 说明 |
| --- | --- | --- | --- |
| id | string | 是 | 唯一标识 |
| name | string | 是 | 目标名称 |
| target_amount | number | 是 | 目标金额 |
| current_amount | number | 是 | 当前金额 |
| due_date | date | 否 | 截止日期 |
| status | enum(active, completed, archived) | 是 | 状态 |
| created_at | datetime | 是 | 创建时间 |
| updated_at | datetime | 是 | 更新时间 |

## 4. Category（分类）
| 字段 | 类型 | 必填 | 说明 |
| --- | --- | --- | --- |
| id | string | 是 | 唯一标识 |
| name | string | 是 | 分类名称 |
| type | enum(income, expense) | 是 | 适用类型 |
| created_at | datetime | 是 | 创建时间 |
| updated_at | datetime | 是 | 更新时间 |

## 5. 关系说明
- Transaction 可关联 0..1 个 Category
- Goal 与 Transaction 通过统计关联（不做强关联）
