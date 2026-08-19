//
//  KeyConstants.swift
//  RxResearch
//
//  Created by Kaiser on 2026/8/10.
//

import Foundation
import Keys

/**
 这个文件没有使用标准的加解密算法，而是采用了一种简单的“混淆”方式来隐藏密钥内容。具体做法如下：

 密钥内容被编码为一组索引，这些索引指向一个很长的字符串（RxResearchKeysData）。
 通过索引取字符，将这些字符拼接成 C 字符串（tEST_KEYCString），最后再转换为 NSString。
 这种方式只是让密钥不直接明文出现在代码中，但并没有加密，只要有源码就能还原出密钥。
 总结：
 这不是加密算法，只是字符串混淆（obfuscation）。
 没有用到如 AES、DES、RSA 等加解密算法。
 这种方式的安全性有限，主要目的是防止密钥被直接搜索到，而不是防止逆向工程。
 
 步骤: Pods -> Podfile文件最后有具体步骤
 */

//使用这样的方式来获取秘钥
let aliapyKey = RxResearchKeys().aliapy_Key
let wechatKey = RxResearchKeys().wechat_Key
let geTuiKey = RxResearchKeys().geTuiAppSecret_Key
let gaodeKey = RxResearchKeys().gaode_Key
