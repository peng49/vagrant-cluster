[Install LDAP Server in Centos Step by Step](https://www.unixmen.com/install-ldap-server-in-centos-step-by-step/)

[Install and Configure OpenLDAP Server on CentOS 8](https://computingforgeeks.com/install-configure-openldap-server-centos/)

[Step by Step OpenLDAP Server Configuration on CentOS 7 / RHEL 7](https://www.itzgeek.com/how-tos/linux/centos-how-tos/step-step-openldap-server-configuration-centos-7-rhel-7.html)

[How to Install LDAP on CentOS 7](https://linuxhostsupport.com/blog/how-to-install-ldap-on-centos-7/)

[安全注意事项](https://www.openldap.org/doc/admin24/security.html)

异常处理:

[Why does this ldapadd command quit with an "Invalid syntax" error?](https://serverfault.com/questions/531495/why-does-this-ldapadd-command-quit-with-an-invalid-syntax-error)

[How To Change Account Passwords on an OpenLDAP Server](https://www.digitalocean.com/community/tutorials/how-to-change-account-passwords-on-an-openldap-server)


rootDN: cn=ldapadm,dc=fly-develop,dc=com
pwd: ldap@admin


### php代码生成ldap密码

#### SSHA
```php 
<?php
function ldap_ssha($password) {
    //生成一随机字符串
    $salt = md5(uniqid(time()));

    return "{SSHA}" . base64_encode(pack('H*', sha1($password . $salt)) . $salt);
}
```

#### MD5
```php
'{MD5}' . base64_encode(md5($password, true))
```
或者
```php
'{MD5}' . base64_encode(pack('H*', md5($password)))
```

#### SHA
```php
'{SHA}' . base64_encode(pack('H*', sha1($password))) 
```
