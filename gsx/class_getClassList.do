# /class/getClassList.json
---

## 接口说明
---
| 项 | 值 |
| :------------: |:---------------|
|    URL   | /class/getClassList.json |
|    描述   | 班级列表  |
|    请求方式   | POST |
|    需要登录   | 是  |
|    注意事项   | 无  |
|    其他   | 无  |

## 请求参数 
---
- 以下参数用来过滤列表，如果不传，则不使用。

```
{
 "branchId":1,
 "year":2016,
 "season":1,
 "subjectId":1,
 "gradeId":1,
 "courseId":1,
 "classTypeId":1,
 "teacherUsrIds":[1,2,3]
 "classroomIds":[1,2,3],
 "classIds":[1,2,3],
 "status":1,//上架=0,下架=1
 "notFull":true,//是否已满
 "key":"语文",//关键字
 "pageNum":1,
 "pageSize":20
}
```

## 返回结果
---
```
{
    "msg": "succ",
    "code": 0,
    "data": {
        "list":[{
            "id": 1,//class id
            "name": "2016年暑期一年级数学乐超班",
            "branchName":"街道口校区"，
            "period":1,//1=一期，2=二期
            "ruleName":"07-15 ~ 07-20",
            "lessonTime":"09:00 ~ 11:00",
            "classRoomName":"201",
            "price":12300,//单位分，12300=123元
            "lessonCount":100,//课次
            "teacherNames":["李老师","王老师"],
            "actualStudents":111,//实际招生数目
            "maxStudents":200,//最大招生数目
            "status":1,//上架=0,下架=1
            "createTime":13456543//创建时间
        }]
    },
   "pageDto"{
       "count": 100,//总数
       "curPageCount": 20,//当前页数量
       "pageNum":1, //页号
       "pageSize":20 //每页显示数量
    } 
}
```