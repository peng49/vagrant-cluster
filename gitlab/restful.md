[文档地址](https://docs.gitlab.com/ee/api/users.html)

### 获取用户
```shell
GET http://192.165.34.61/api/v4/users?access_token=J-thifVwqhP7cA3f3-JY&username=user10
```

### 创建用户
```shell
POST http://192.165.34.61/api/v4/users?access_token=J-thifVwqhP7cA3f3-JY
Content-Type: application/json

{
    "email": "user10@t.com",
    "name": "用户10",
    "username": "user10",
    "force_random_password": true,
    "skip_confirmation": true
}
```

### 删除用户
```shell
DELETE http://192.165.34.61/api/v4/users/10?access_token=J-thifVwqhP7cA3f3-JY
```

### 激活用户
```shell
POST http://192.165.34.61/api/v4/users/10/activate?access_token=J-thifVwqhP7cA3f3-JY
```

### 新增用户邮箱
```shell
POST http://192.165.34.61/api/v4/users/10/emails?access_token=J-thifVwqhP7cA3f3-JY
Content-Type: application/json

{
    "id": 10,
    "email": "user101@t.com",
    "skip_confirmation": true
}
```

### 删除指定用户的指定邮箱
```shell
DELETE http://192.165.34.61/api/v4/users/10/emails/9?access_token=J-thifVwqhP7cA3f3-JY
```

### 获取项目的成员
```shell
GET http://192.165.34.61/api/v4/projects/:id/members?access_token=J-thifVwqhP7cA3f3-JY
```

### 指定项目添加成员 access_lavel 10 => Guest 20 => Reporter 30 => Develper 40 => Maintainer
```shell
POST http://192.165.34.61/api/v4/projects/4/members?access_token=J-thifVwqhP7cA3f3-JY
Content-Type: application/json

{
    "user_id": "2",
    "access_level": 30
}
```

