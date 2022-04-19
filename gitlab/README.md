#### LDAP认证
```shell
vim 

```

> sudo gitlab-ctl reconfigure

> sudo gitlab-ctl restart 


#### Oauth2 认证 
https://docs.gitlab.com/ee/integration/oauth2_generic.html
```shell
gitlab_rails['omniauth_enabled'] = true
gitlab_rails['omniauth_block_auto_created_users'] = true
gitlab_rails['omniauth_providers'] = [
   {
     'name' => 'oauth2_generic',
     'label' => 'OA',
     'app_id' => '$app id',
     'app_secret' => '$appSecret',
     'args' => {
        'client_options' => {
                'site' => 'http://192.168.168.149:8001',
                # 认证登录url
                'authorize_url' => 'http://192.168.168.149:8001',
                'token_url' => 'http://192.168.168.149:8001/serv/index.php?c=oauth2&a=getTokenByCode',
                'user_info_url' => 'http://192.168.168.149:8001?user_info_url'                                       
        },
        'access_type' => 'offline',
        'approval_prompt' => '',
        'strategy_class' => 'OmniAuth::Strategies::OAuth2Generic'
      }
   }
 ]
```