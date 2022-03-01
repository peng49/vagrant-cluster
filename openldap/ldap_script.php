<?php
function sync_user_to_ldap($user) {

}

function sync_department_to_ldap($department) {

}

$departments = [
    [
        'id' => 1,
        'name' => '技术部'
    ],
    [
        'id' => 2,
        'name' => '业务部'
    ],
    [
        'id' => 3,
        'name' => '运营部'
    ],
];

$users = [
    [
        'id' => 1,
        'username' => 'user01',
        'mail' => 'user01@t.com',
        'name' => '用户01',
        'department_id' => 1,
        'password' => '123456'
    ],
    [
        'id' => 2,
        'username' => 'user02',
        'name' => '用户02',
        'department_id' => 1,
        'password' => '123456'
    ],
    [
        'id' => 3,
        'username' => 'user03',
        'name' => '用户03',
        'department_id' => 1,
        'password' => '123456'
    ],
    [
        'id' => 4,
        'username' => 'user04',
        'name' => '用户04',
        'department_id' => 2,
        'password' => '123456'
    ],
    [
        'id' => 5,
        'username' => 'user05',
        'name' => '用户05',
        'department_id' => 2,
        'password' => '123456'
    ],
    [
        'id' => 6,
        'username' => 'user06',
        'name' => '用户06',
        'department_id' => 2,
        'password' => '123456'
    ],
    [
        'id' => 7,
        'username' => 'user07',
        'name' => '用户07',
        'department_id' => 2,
        'password' => '123456'
    ],
    [
        'id' => 8,
        'username' => 'user08',
        'name' => '用户08',
        'department_id' => 3,
        'password' => '123456'
    ],
    [
        'id' => 9,
        'username' => 'user09',
        'name' => '用户09',
        'department_id' => 3,
        'password' => '123456'
    ],
    [
        'id' => 10,
        'username' => 'user10',
        'name' => '用户10',
        'department_id' => 3,
        'password' => '123456'
    ]
];

$ldap = @ldap_connect("ldap://192.165.33.41:389");
ldap_set_option($ldap, LDAP_OPT_PROTOCOL_VERSION, 3);
ldap_set_option($ldap, LDAP_OPT_REFERRALS, 0);
$res = ldap_bind($ldap, "cn=ldapadm,dc=fly-develop,dc=com", "ldap@admin");

foreach ($departments as $department) {
    $attribute = [
        'description' => $department['name'],
        'objectClass' => ['top', 'organizationalUnit']
    ];

    $res = ldap_search($ldap, 'dc=fly-develop,dc=com', "(&(objectClass=organizationalUnit)(ou={$department['id']}))", ['dn']);

    $entries = ldap_get_entries($ldap, $res);
    if ($entries && $entries['count'] > 0) {
        //已存在
        var_dump($entries[0]['dn']);
    } else {
        $res = ldap_add($ldap, "ou={$department['id']},dc=fly-develop,dc=com", $attribute);
        var_dump($res);
    }

    //todo 查询部门下对应的人员
    $res = ldap_list($ldap,"ou={$department['id']},dc=fly-develop,dc=com","(objectClass=inetOrgPerson)",['dn']);
    $entries = ldap_get_entries($ldap,$res);

    $members = array_column($entries, 'dn');

    //部门对应的组设置
    $group = [
        'description' => $department['name'],
        'objectClass' => ['top', 'groupOfNames'],
        'member' => $members
    ];

    $groupDn = "CN={$department['id']},ou={$department['id']},dc=fly-develop,dc=com";

    $res = ldap_get_entries($ldap,ldap_search($ldap,$groupDn,"objectClass=groupOfNames",['dn']));
    if (isset($res['count']) && $res['count'] > 0) {
        // update
        $r = ldap_modify($ldap, $groupDn, $group);
    } else {
        $r = ldap_add($ldap, $groupDn, $group);
    }
    var_dump('group',$r);
}

function ldap_ssha($password) {
    //生成一随机字符串
    $salt = md5(uniqid(time()));

    return "{SSHA}" . base64_encode(pack('H*', sha1($password . $salt)) . $salt);
}

foreach ($users as $user) {
    $attribute = [
        'sn' => 'sn001', //必填,根据需要设值
        'description' => $user['name'],
        'mail' => $user['mail']??"{$user['username']}@t.com",
        'objectClass' => ['top', 'organizationalPerson', 'inetOrgPerson'],
        //'{SHA}' . base64_encode(pack('H*', sha1($user['password'])))
        //'{MD5}' . base64_encode(md5($user['password'], true))
        //'{MD5}' . base64_encode(pack('H*', md5($user['password'])))
        'userPassword' => ldap_ssha($user['password']),
    ];

    $res = ldap_search($ldap, 'dc=fly-develop,dc=com', "(&(objectClass=inetOrgPerson)(cn={$user['username']}))", ['dn','member']);

    $entries = ldap_get_entries($ldap, $res);
    if ($entries && $entries['count'] > 0) {
        var_dump($entries);
        //已存在
        var_dump($entries[0]['dn']);
        //PHP Warning:  ldap_modify(): Modify: Cannot modify object class
        //注意: ldap_modify不能修改objectClass
        $res = ldap_modify($ldap, $entries[0]['dn'], $attribute);
        var_dump('modify:', $res);
    } else {
        $res = ldap_add($ldap, "cn={$user['username']},ou={$user['department_id']},dc=fly-develop,dc=com", $attribute);
        var_dump($res);
    }
}
