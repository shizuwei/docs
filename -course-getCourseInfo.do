# /course/getCourseInfo.do
---

## 接口说明
---
| 项 | 值 |
| :------------: |:---------------|
|    URL   | /course/getCourseInfo.json |
|    描述   | 课程信息 |
|    请求方式   | POST |
|    需要登录   | 是  |
|    注意事项   | 无  |
|    其他   | 无  |

## 请求参数
---
| 参数名 | 必选  | 类型 | 说明 |
| :------------: |:---------------:| :-----:| :----- |
|id|是 |int|课程id|
 

## 返回结果
---
```
{
    "msg": "succ",
    "code":0,
    "data": {
     "id":1,
     "name":"2016春季一年级数学",
     "courseTypeId":11,
     "courseTypeName":"小学长期班",
     "year":2016,
     "season":1,
     "price":1111,//分
     "lessonCount":11,//上课次数
     "gradeId":1,
     "gradeName":"一年级",
     "subjectId":1,
     "subjectName":"数学",
     "continueTimeStart":1234,//续报
     "continueTimeEnd":1234,
     "transTimeStart":1234,//转班&老生报名期
     "transTimeEnd":1222,
     "allTimeStart":212,//统一报名期
     "allTimeEnd":1232,
     "createTime":123123,
     "updateTime":123123,
    }
}

```