#class/getClassInfo.json
---

## 接口说明
---
| 项 | 值 |
| :------------: |:---------------|
|    URL   | class/getClassInfo.json |
|    描述   |课程详情 |
|    请求方式   | POST |
|    需要登录   | 是  |
|    注意事项   | 无  |
|    其他   | 无  |

## 请求参数
---
```
{
 "classId":1
 "getLesson":true,//true=加载lessons,默认不加载
 "getStudents":true//true=加载students,默认不加载
}
```
 


## 返回结果
---
```
{
    "msg":"succ",
    "code": 0,
    "data": {
    	"classInfo":{
	    	"id":1,
			"name":"xxx班",
			"courseId":1,
			"classTypeId":1,
			"classTypeName":"xxx",
			"subjectLevelId":3,
			"subjectLevelName":"yyy",
			"branchId":11,
			"branchName":"校区",
			"period":2,
			"price":122,//单位:分
			"maxStudents":122,
			"reserveStudents":11,
			"actualStudents":11,
			"classroomId":11,
			"ruleName":"xxxx",
			"lessonTime":"11:00~12:11"
			"year":2012,
			"season":1,
			"lessonCount":11,
			"gradeName":"年级",
			"subjectName":"科目",
			"teachers":[
				{
					"id":1,
					"avatar":"http://...",
					"name":"李老师"
				}
			]
   	},
    	"lessons":[ 
	    	{
	    		"lessonId":1,
	    		"date":11212,//日期
	    		"startTime":"12:00",
	    		"endTime":"13:00",
			   "name":"班级名",
			   "roomName":"教室名",
			   "teacherName":"老师名"
	    	}
    	],
    	"students":[
	    	{
	    		"studentId":1,
	    		"name":"张三",
	    		"avatar":"http://...",
	    		"lessonCount":11,
	    		"signCount":22,
	    		"leftCount":11
	    	}
    	],
    	"node":{
    		"id":1,
    	   "name":"xxx",
    	   "children":[
	    	   {
		    	   "id":2,
		    	   "name":"yyy",
		    	   "children":[...]
    	   		}
    	   ]
    	}
 
    }
```