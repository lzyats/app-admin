# Go-Api 鍚庣API鎺ュ彛鏂囨。

> 鏈枃妗ｄ负鎶曡祫鐞嗚储鍚庡彴绯荤粺 APP绔?API姘镐箙鏂囨。
> 鎵€鏈堿PI璇锋眰璺緞銆佸弬鏁拌鏄庛€佽繑鍥炴牸寮忓潎鍦ㄦ鏂囨。涓褰?> **娉ㄦ剰**: 闄ら潪鐗瑰埆璇存槑锛屾墍鏈?`/app/**` 鎺ュ彛鍧囬渶瑕佹惡甯oken璁よ瘉

---

## 涓€銆丄PI鍩虹瑙勮寖

### 1.1 鎺ュ彛鍓嶇紑
- **APP鎺ュ彛**: `/app/**` 鎴?`/app/**`锛堥渶瑕佺櫥褰曡璇侊級
- **鐧诲綍娉ㄥ唽鎺ュ彛**: `/auth/**`锛堟棤闇€璁よ瘉锛岄儴鍒嗘帴鍙ｅ彲鍖垮悕璁块棶锛?- **绯荤粺绠＄悊鎺ュ彛**: `/system/**`锛堝悗鍙扮鐞嗕笓鐢紝闇€瑕佸悗鍙版潈闄愶級
- **楠岃瘉鐮佹帴鍙?*: `/captchaImage`锛堟棤闇€璁よ瘉锛?
### 1.2 璁よ瘉鏂瑰紡
- Header涓惡甯?`Authorization: Bearer {token}`
- 鐧诲綍鎴愬姛鍚庤繑鍥炵殑 `token` 瀛楁

### 1.3 璇锋眰鏍煎紡
- Content-Type: `application/json`
- 璇锋眰浣撲娇鐢↗SON鏍煎紡

### 1.4 杩斿洖鏍煎紡
```json
{
  "code": 200,
  "msg": "鎿嶄綔鎴愬姛",
  "data": {}
}
```

---

## 浜屻€侀獙璇佺爜鎺ュ彛

### 2.1 鑾峰彇楠岃瘉鐮佸浘鐗?```
GET /captchaImage
```

**璇锋眰鍙傛暟**: 鏃?
**杩斿洖鍙傛暟**:
| 鍙傛暟鍚?| 绫诲瀷 | 璇存槑 |
|--------|------|------|
| captchaEnabled | boolean | 楠岃瘉鐮佹槸鍚﹀惎鐢?|
| uuid | string | 楠岃瘉鐮佸敮涓€鏍囪瘑锛堝惎鐢ㄦ椂杩斿洖锛?|
| img | string | 楠岃瘉鐮佸浘鐗嘊ase64缂栫爜锛堝惎鐢ㄦ椂杩斿洖锛?|

**娉ㄦ剰浜嬮」**:
- 楠岃瘉鐮侀粯璁?鍒嗛挓鏈夋晥鏈?- 楠岃瘉鐮佸紑鍏崇敱绯荤粺閰嶇疆 `sys.account.captchaEnabled` 鎺у埗

---

## 涓夈€佽璇佺浉鍏虫帴鍙?
### 3.1 鐢ㄦ埛鐧诲綍
```
POST /login
```
**鏃犻渶璁よ瘉**

**璇锋眰鍙傛暟**:
```json
{
  "username": "鐢ㄦ埛鍚?,
  "password": "瀵嗙爜",
  "code": "楠岃瘉鐮侊紙濡傚惎鐢級",
  "uuid": "楠岃瘉鐮乁UID锛堝鍚敤锛?
}
```

**杩斿洖鍙傛暟**:
```json
{
  "code": 200,
  "msg": "鎿嶄綔鎴愬姛",
  "token": "鐧诲綍鍑瘉"
}
```

---

### 3.2 鐢ㄦ埛娉ㄥ唽
```
POST /register
```
**鏃犻渶璁よ瘉**

**璇锋眰鍙傛暟**:
```json
{
  "username": "鐢ㄦ埛鍚?,
  "password": "瀵嗙爜",
  "nickName": "鏄电О",
  "code": "楠岃瘉鐮侊紙濡傚惎鐢級",
  "uuid": "楠岃瘉鐮乁UID锛堝鍚敤锛?
}
```

**杩斿洖鍙傛暟**:
```json
{
  "code": 200,
  "msg": "娉ㄥ唽鎴愬姛"
}
```

**娉ㄦ剰浜嬮」**:
- 娉ㄥ唽鍔熻兘鐢辩郴缁熼厤缃?`sys.account.registerUser` 鎺у埗
- 鐢ㄦ埛鍚嶅敮涓€鎬ф牎楠?- 瀵嗙爜闀垮害5-20瀛楃

---

### 3.3 鑾峰彇鐢ㄦ埛淇℃伅
```
GET /getInfo
```
**闇€瑕佽璇?*

**杩斿洖鍙傛暟**:
```json
{
  "code": 200,
  "user": {
    "userId": 1000100,
    "userName": "鐢ㄦ埛鍚?,
    "nickName": "鏄电О",
    "avatar": "澶村儚URL",
    "email": "閭",
    "phonenumber": "鎵嬫満鍙?,
    "sex": 0,
  "balance": "5000.00",
  "totalInvest": "0.00",
  "totalProfit": "0.00",
  "level": 1,
  "inviteCode": "ABCDEA",
  "payPasswordSet": 1,
  "usdBalance": "0.00",
  "usdExchangeQuota": "0.00"
  },
  "roles": ["鏅€氱敤鎴?],
  "permissions": []
}
```

---

## 鍥涖€丄PP鐢ㄦ埛鐩稿叧鎺ュ彛

> 鎺ュ彛鍓嶇紑: `/app/user`
> **闇€瑕佽璇?*

### 4.1 妫€鏌ユ敮浠樺瘑鐮佹槸鍚﹁缃?```
GET /app/user/payPwd/check
```

**杩斿洖鍙傛暟**:
```json
{
  "code": 200,
  "data": true
}
```

**娉ㄦ剰浜嬮」**:
- 杩斿洖true琛ㄧず宸茶缃敮浠樺瘑鐮侊紝false琛ㄧず鏈缃?
---

### 4.2 璁剧疆鏀粯瀵嗙爜
```
POST /app/user/payPwd/set
```

**璇锋眰鍙傛暟**:
```json
{
  "password": "123456"
}
```

**杩斿洖鍙傛暟**:
```json
{
  "code": 200,
  "msg": "鎿嶄綔鎴愬姛"
}
```

**娉ㄦ剰浜嬮」**:
- 瀵嗙爜蹇呴』涓?浣嶆暟瀛?- 璁剧疆鎴愬姛鍚庝細鑷姩淇濆瓨鍒版湰鍦扮紦瀛?
---

### 4.3 鏇存柊鏀粯瀵嗙爜
```
PUT /app/user/payPwd/update
```

**璇锋眰鍙傛暟**:
```json
{
  "oldPassword": "123456",
  "newPassword": "654321"
}
```

**杩斿洖鍙傛暟**:
```json
{
  "code": 200,
  "msg": "鎿嶄綔鎴愬姛"
}
```

**閿欒杩斿洖**:
- 鏀粯瀵嗙爜鏈缃? `{"code": 500, "msg": "鏀粯瀵嗙爜鏈缃?}`
- 鍘熷瘑鐮侀敊璇? `{"code": 500, "msg": "鍘熸敮浠樺瘑鐮侀敊璇?}`

---

### 4.4 楠岃瘉鏀粯瀵嗙爜
```
POST /app/user/payPwd/verify
```

**璇锋眰鍙傛暟**:
```json
{
  "password": "123456"
}
```

**杩斿洖鍙傛暟**:
```json
{
  "code": 200,
  "msg": "鎿嶄綔鎴愬姛"
}
```

**閿欒杩斿洖**:
- 鏀粯瀵嗙爜鏈缃? `{"code": 500, "msg": "鏀粯瀵嗙爜鏈缃?}`
- 瀵嗙爜閿欒: `{"code": 500, "msg": "鏀粯瀵嗙爜閿欒"}`

---

---

## 浜斻€丄PP璁よ瘉鎵╁睍鎺ュ彛

> 鎺ュ彛鍓嶇紑: `/app/auth`
> 閮ㄥ垎鎺ュ彛鏃犻渶璁よ瘉

### 5.1 蹇樿瀵嗙爜锛堥€氳繃閭閲嶇疆锛?```
POST /app/auth/forgotPwd
```
**鏃犻渶璁よ瘉**

**璇锋眰鍙傛暟**:
```json
{
  "username": "鐢ㄦ埛鍚?,
  "email": "閭",
  "newPassword": "鏂板瘑鐮?,
  "code": "楠岃瘉鐮侊紙濡傚惎鐢級",
  "uuid": "楠岃瘉鐮乁UID锛堝鍚敤锛?
}
```

**杩斿洖鍙傛暟**:
```json
{
  "code": 200,
  "msg": "瀵嗙爜閲嶇疆鎴愬姛"
}
```

**閿欒杩斿洖**:
- `{"code": 500, "msg": "鐢ㄦ埛鍚嶃€侀偖绠便€佹柊瀵嗙爜涓嶈兘涓虹┖"}`
- `{"code": 500, "msg": "瀵嗙爜闀垮害蹇呴』鍦?鍒?0涓瓧绗︿箣闂?}`
- `{"code": 500, "msg": "鐢ㄦ埛涓嶅瓨鍦?}`
- `{"code": 500, "msg": "鐢ㄦ埛鍚嶄笌閭涓嶅尮閰?}`

---

### 5.2 閫氳繃瀹夊叏闂閲嶇疆瀵嗙爜
```
POST /app/auth/forgotPwdBySecurity
```
**鏃犻渶璁よ瘉**

**璇锋眰鍙傛暟**:
```json
{
  "username": "鐢ㄦ埛鍚?,
  "newPassword": "鏂板瘑鐮?,
  "answers": [
    {"questionId": 1, "answer": "绛旀1"},
    {"questionId": 2, "answer": "绛旀2"}
  ]
}
```

**杩斿洖鍙傛暟**:
```json
{
  "code": 200,
  "msg": "瀵嗙爜閲嶇疆鎴愬姛"
}
```

**娉ㄦ剰浜嬮」**:
- 蹇呴』鍥炵瓟鑷冲皯2涓畨鍏ㄩ棶棰?- 鎵€鏈夐棶棰樼瓟妗堝繀椤诲叏閮ㄦ纭?
---

### 5.3 鑾峰彇鎵€鏈夊畨鍏ㄩ棶棰樺垪琛?```
POST /app/auth/security/questions
```
**鏃犻渶璁よ瘉**

**璇锋眰鍙傛暟**:
```json
{
  "lang": "zh_CN"
}
```

**杩斿洖鍙傛暟**:
```json
{
  "code": 200,
  "data": [
    {"questionId": 1, "questionText": "闂1", "lang": "zh_CN"},
    {"questionId": 2, "questionText": "闂2", "lang": "zh_CN"}
  ]
}
```

---

### 5.4 妫€鏌ョ敤鎴锋槸鍚﹀凡璁剧疆瀹夊叏闂
```
POST /app/auth/security/hasSet
```
**鏃犻渶璁よ瘉**

**璇锋眰鍙傛暟**:
```json
{
  "username": "鐢ㄦ埛鍚?
}
```

**杩斿洖鍙傛暟**:
```json
{
  "code": 200,
  "data": true
}
```

---

### 5.5 鑾峰彇瀹炲悕璁よ瘉鐘舵€?```
POST /app/auth/realName/status
```

**杩斿洖鍙傛暟**:
```json
{
  "code": 200,
  "data": {
    "handheldRequired": false,
    "status": 0,
    "authId": 1,
    "submitTime": "2024-01-01 10:00:00",
    "rejectReason": null
  }
}
```

**status鐘舵€佽鏄?*:
- `-1`: 鏈彁浜ゅ疄鍚嶈璇?- `0`: 寰呭鏍?- `1`: 瀹℃牳閫氳繃
- `2`: 瀹℃牳鎷掔粷

---

### 5.6 鎻愪氦瀹炲悕璁よ瘉
```
POST /app/auth/realName/submit
```

**璇锋眰鍙傛暟**:
```json
{
  "realName": "鐪熷疄濮撳悕",
  "idCardNumber": "韬唤璇佸彿",
  "idCardFront": "韬唤璇佹闈㈢収URL",
  "idCardBack": "韬唤璇佸弽闈㈢収URL",
  "handheldPhoto": "鎵嬫寔韬唤璇佺収URL锛堝彲閫夛級"
}
```

**杩斿洖鍙傛暟**:
```json
{
  "code": 200,
  "msg": "瀹炲悕璁よ瘉鎻愪氦鎴愬姛锛岃绛夊緟瀹℃牳"
}
```

**娉ㄦ剰浜嬮」**:
- 濡傛灉绯荤粺閰嶇疆 `app.feature.realNameHandheldRequired` 涓簍rue锛屽垯蹇呴』涓婁紶鎵嬫寔韬唤璇佺収
- 韬唤璇佸彿鏀寔15浣嶅拰18浣嶆牸寮?- 鍚屼竴鐢ㄦ埛鍙兘鎻愪氦涓€娆″疄鍚嶈璇侊紙寰呭鏍哥姸鎬佷笅涓嶅彲鍐嶆鎻愪氦锛?
---

## 鍏€丄PP閰嶇疆鎺ュ彛

> 鎺ュ彛鍓嶇紑: `/app/config`

### 6.1 鑾峰彇APP寮曞閰嶇疆
```
GET /app/config/bootstrap
```

**璇锋眰鍙傛暟**:
```
items: multiLanguageEnabled,registerEnabled,inviteCodeEnabled,realNameHandheldRequired,usdRate,investCurrencyMode,supportRmbToUsd
```

**杩斿洖鍙傛暟**:
```json
{
  "code": 200,
  "data": {
    "multiLanguageEnabled": true,
    "registerEnabled": true,
    "inviteCodeEnabled": false,
    "realNameHandheldRequired": false,
    "usdRate": 7.0,
    "investCurrencyMode": 1,
    "supportRmbToUsd": false
  }
}
```

**閰嶇疆椤硅鏄?*:
| 閰嶇疆椤?| 绫诲瀷 | 璇存槑 |
|--------|------|------|
| multiLanguageEnabled | boolean | 澶氳瑷€寮€鍏?|
| registerEnabled | boolean | 寮€鏀炬敞鍐屽紑鍏?|
| inviteCodeEnabled | boolean | 閭€璇风爜娉ㄥ唽寮€鍏?|
| realNameHandheldRequired | boolean | 瀹炲悕璁よ瘉闇€鎵嬫寔韬唤璇?|
| usdRate | double | 缇庡厓姹囩巼 |
| investCurrencyMode | int | 投资货币方式（1:单币种，2:双币种） |
| supportRmbToUsd | boolean | 鏀寔浜烘皯甯佸厬鎹㈢編鍏?|

---

### 6.2 鑾峰彇閰嶇疆椤瑰厓鏁版嵁
```
GET /app/config/options
```

**杩斿洖鍙傛暟**:
```json
{
  "code": 200,
  "data": [
    {
      "item": "multiLanguageEnabled",
      "configKey": "app.feature.multiLanguage",
      "name": "澶氳瑷€寮€鍏?,
      "defaultValue": true
    }
  ]
}
```

---

## 涓冦€丄PP鍗囩骇鎺ュ彛

> 鎺ュ彛鍓嶇紑: `/app/upgrade`

### 7.1 鑾峰彇鍗囩骇閰嶇疆
```
GET /app/upgrade/config
```

**杩斿洖鍙傛暟**:
```json
{
  "code": 200,
  "data": {
    "androidVersion": "1.0.0",
    "androidApkUrl": "https://example.com/app.apk",
    "iosVersion": "1.0.0",
    "iosInstallUrl": "https://example.com/ios",
    "forceUpgrade": false,
    "releaseNote": "淇浜嗕竴浜沚ug"
  }
}
```

---

## 鍏€佸悗鍙扮鐞嗘帴鍙ｏ紙闇€瑕佸悗鍙版潈闄愶級

### 8.1 鐢ㄦ埛绠＄悊
```
GET /system/user/list
POST /system/user
PUT /system/user
DELETE /system/user/{userIds}
```

### 8.2 鐢ㄦ埛閽卞寘绠＄悊
```
GET /system/wallet/list
POST /system/wallet
PUT /system/wallet
DELETE /system/wallet/{walletId}
```

### 8.3 閽卞寘娴佹按绠＄悊
```
GET /system/wallet/log/list
POST /system/wallet/log
PUT /system/wallet/log
DELETE /system/wallet/log/{logId}
```

### 8.4 瀹炲悕璁よ瘉绠＄悊
```
GET /system/realNameAuth/list
GET /system/realNameAuth/{authId}
PUT /system/realNameAuth
DELETE /system/realNameAuth/{authIds}
```

---

## 涔濄€佺郴缁熼厤缃」

### 9.1 閰嶇疆椤瑰垪琛?| 閰嶇疆Key | 璇存槑 | 榛樿鍊?|
|---------|------|--------|
| sys.account.registerUser | 寮€鏀炬敞鍐屽紑鍏?| true |
| sys.account.captchaEnabled | 楠岃瘉鐮佸紑鍏?| true |
| sys.account.chrtype | 瀵嗙爜鑷畾涔夎鍒?| 0 |
| sys.account.initPasswordModify | 鍒濆瀵嗙爜寮哄埗淇敼 | 1 |
| sys.account.passwordValidateDays | 瀵嗙爜鏈夋晥鏈?澶? | 0 |
| app.feature.multiLanguage | 澶氳瑷€寮€鍏?| true |
| app.feature.inviteCodeEnabled | 閭€璇风爜娉ㄥ唽寮€鍏?| false |
| app.feature.realNameHandheldRequired | 瀹炲悕璁よ瘉闇€鎵嬫寔韬唤璇?| false |
| app.currency.usdRate | 缇庡厓姹囩巼 | 7.0 |
| app.currency.investMode | 鎶曡祫璐у竵鏂瑰紡 | 1 |
| app.currency.supportRmbToUsd | 鏀寔浜烘皯甯佸厬鎹㈢編鍏?| false |
| app.upgrade.config | APP鍗囩骇閰嶇疆JSON | {} |

---

## 鍗併€佹敞鎰忎簨椤?
### 10.1 瀹夊叏鎬ф敞鎰忎簨椤?1. 鎵€鏈夋晱鎰熸帴鍙ｏ紙鏀粯瀵嗙爜銆佽祫閲戞搷浣滐級蹇呴』楠岃瘉鐢ㄦ埛韬唤
2. 鏀粯瀵嗙爜蹇呴』涓?浣嶆暟瀛楋紝涓嶅緱鍖呭惈瀛楁瘝鎴栫壒娈婂瓧绗?3. 瀵嗙爜淇敼鏃跺繀椤婚獙璇佹棫瀵嗙爜
4. 鐢ㄦ埛鏁版嵁鏉冮檺闅旂锛岀‘淇濈敤鎴峰彧鑳借闂嚜宸辩殑鏁版嵁

### 10.2 鎬ц兘娉ㄦ剰浜嬮」
1. 楠岃瘉鐮佹湁鏁堟湡2鍒嗛挓锛屼娇鐢ㄥ悗绔嬪嵆澶辨晥
2. Token榛樿鏈夋晥鏈熸牴鎹郴缁熼厤缃?`security.token.expireTime` 纭畾
3. 鍒楄〃鏌ヨ寤鸿浣跨敤鍒嗛〉锛岄粯璁や负pageNum=1, pageSize=10

### 10.3 鏁版嵁鏍煎紡娉ㄦ剰浜嬮」
1. 鎵€鏈夐噾棰濆瓧娈典娇鐢⊿tring绫诲瀷锛岄伩鍏嶆诞鐐规暟绮惧害闂
2. 鏃ユ湡鏃堕棿鏍煎紡锛歚yyyy-MM-dd HH:mm:ss`
3. 鏋氫妇鍊间弗鏍兼寜鏂囨。浣跨敤锛屽甯佺锛歚CNY`锛堜汉姘戝竵锛夈€乣USD`锛堢編鍏冿級
4. 鎶曡祫璐у竵鏂瑰紡锛歚1`锛堝崟甯佺锛夈€乣2`锛堝亣鍙屽竵绉嶏級銆乣3`锛堝弻甯佺锛?
### 10.4 双币种业务规则
1. **investCurrencyMode = 1（单币种）**：仅支持人民币，美元相关功能不可用。
2. **investCurrencyMode = 2（双币种）**：用户同时拥有人民币钱包和美元钱包，交易按币种钱包进行，不再提供 APP 端默认币种切换入口。
### 10.5 甯歌閿欒鐮?| code | 璇存槑 |
|------|------|
| 200 | 鎿嶄綔鎴愬姛 |
| 401 | 鏈巿鏉冿紙鏈櫥褰曟垨Token杩囨湡锛?|
| 403 | 鏃犳潈闄愯闂?|
| 500 | 绯荤粺閿欒鎴栦笟鍔￠敊璇?|

---

## 鍗佷竴銆佷慨鏀瑰巻鍙?
| 鏃ユ湡 | 鐗堟湰 | 淇敼鍐呭 | 淇敼浜?|
|------|------|----------|--------|
| 2024-XX-XX | v1.0 | 鍒濆鐗堟湰 | - |

---

## 十二、用户信息缓存契约【永久记忆】
为了避免 APP 首页、个人信息页、后台用户详情页重复直查数据库，系统用户信息统一通过 `ISysUserService` 读取，并在服务层接入 Redis 缓存。

### 12.1 统一读取入口
- `selectUserById(Long userId)`
- `selectUserByUserName(String userName)`
- `selectUserByInviteCode(String inviteCode)`

以上接口必须先读 Redis，命中直接返回；未命中时再查数据库，查到后写回缓存。

### 12.2 缓存 Key 规则
- `cache:app:user:v2:id:{userId}`
- `cache:app:user:v2:name:{userName}`
- `cache:app:user:v2:invite:{inviteCode}`

APP 端“我的 / 个人信息 / 安全中心”页面优先读取本地缓存的用户资料，只有缓存缺失或明确需要刷新时才请求 `getInfo`。

### 12.3 缓存失效规则
所有会修改用户主数据的接口，在数据库更新成功后必须清理缓存，包括但不限于：
- 新增用户
- 用户注册
- 修改用户资料
- 修改头像
- 修改登录信息
- 重置密码
- 修改支付密码
- 修改状态
- 用户币种偏好字段为历史字段，APP 不再提供默认币种切换入口
- 删除用户

### 12.4 接入位置
- 后台登录后获取用户信息：`SysLoginController.getInfo`
- APP 端获取个人资料：`AppUserController`、`AppAuthController`
- 后台用户详情页：`SysUserController`
- 用户资料页：`SysProfileController`

### 12.5 维护要求
- 后续新增用户字段时，如果会影响页面展示或登录态，优先复用这套缓存服务
- 写库成功后再失效缓存，避免写库失败但缓存被提前删除
- 不要在控制器层直接查表，统一走 `ISysUserService`
- `getInfo` 返回的用户基本信息必须与 `sys_user` 字段同步更新，至少要覆盖当前页面依赖的状态字段，例如支付密码是否已设置

### 12.6 `sys_user` 字段同步清单
当 `sys_user` 新增或修改字段时，请同步检查：
1. `SysUser` 实体是否已新增字段和注释
2. `SysUserMapper.xml` 的 `resultMap` 和查询 SQL 是否已补字段
3. `SysLoginController.getInfo` 返回的 `user` 是否已包含该字段或派生状态字段
4. Flutter 的 `AuthUserProfile` 是否已补充字段并完成解析
5. 相关页面是否已切换到新字段，不再依赖旧缓存或旧接口
6. 永久文档中的接口示例、配置说明、维护要求是否已同步更新
7. 支付密码状态以 `getInfo.user.payPasswordSet` 为主，`checkPayPwdSet` 仅作为历史兼容兜底，不应作为首页和安全中心主判断入口

## 十三、登录与会话职责分工【永久记忆】
为了避免后续修改时把用户信息、登录态和 token 刷新逻辑混在一起，登录链路按下面职责划分：

### 13.1 用户加载层
- `UserDetailsServiceImpl`
- 根据用户名加载用户对象
- 底层通过 `ISysUserService` 读取用户信息，命中 Redis 后直接返回

### 13.2 登录校验层
- `SysLoginService`
- 负责验证码校验、登录前置校验、认证结果记录、登录成功后更新登录信息
- 不直接管理 token 以外的会话数据

### 13.3 登录态层
- `TokenService`
- 负责 token 创建、刷新、获取、删除
- 只管理登录态，不承载用户基础资料的读写

### 13.4 用户缓存层
- `SysUserApiServiceImpl`
- 负责用户基础资料的 Redis 缓存读写
- 缓存 key 统一按 `userId / userName / inviteCode` 三种维度组织

### 13.5 用户业务层
- `SysUserServiceImpl`
- 作为统一用户入口
- 读取时委托缓存层，写入成功后失效缓存



## 14. 实名状态与配置缓存约定

### 14.1 实名状态来源
- APP 端实名认证状态统一从 `getInfo.user.realNameStatus` 读取。
- `sys_user.real_name_status` 为主状态字段，含义固定为：
  - `0` 未实名
  - `1` 已提交
  - `2` 驳回
  - `3` 已实名
- 实名表变更时必须同步更新用户表，并同步失效用户缓存。

### 14.2 APP 基础配置缓存
- `/app/config/bootstrap` 是 APP 初始化配置聚合接口。
- 后台 `sys_config` 任意 `app.*` 基础配置发生变化后，必须清空并重建 Redis 配置缓存。
- `insertConfig`、`updateConfig`、`deleteConfigByIds` 成功后必须执行 `resetConfigCache()`。
- 后台 `system/config` 的保存动作也必须刷新缓存，保证 APP 端看到的是最新值。

## 15. ?? / ?? / ?? / ??? ??????????

### 15.1 ???????
- ??????????????????????? `zh-CN.json`?
- `assetsRmb` ???????????????????????RMB??
- ????????????????????????????????????

### 15.2 ?????
- ???? `app.currency.investMode` ?????/????
  - `1`??????????????
  - `2`????????????? USDT ???
- ??????????????????
- ?????????????
  - ???
  - ????
  - ????
  - ????
  - ????
  - ????
  - ????
  - ????
- ???????????????????????????????????

### 15.3 ???
- ????????????????????????
- ??????? / ????????
  - ????????????
  - ???????????? USDT ?????
- ??????????????????????????
- ?????????????????????

### 15.4 ???
- ????????????????????
- ???????????????????????????????????????????
- ??????? / ?????????????????????????

### 15.5 ????
- ???????????????
- ?????????????
- ??????????????? USD ?????
- ??????????????????
- RMB ?????????????? RMB?

### 15.6 ????
- ?????????????????????????????
- ?????????????????????
  - Flutter ??
  - `zh-CN.json`
  - `en-US.json`
  - ?????????
- ????????????????????????
