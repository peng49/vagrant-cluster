#### 批量使用virtualenv创建虚拟环境

```shell
# 添加一个爬虫指定命令如下
bash -c 'source /usr/local/bin/virtualenvwrapper.sh && mkvirtualenv testEnv && which python && pip install -r requirements.txt'

# 运行选择所有节点即可


```