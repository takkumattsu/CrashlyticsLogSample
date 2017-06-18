//
//  CrashlyticsError.swift
//  CrashlyticsLogSample
//
//  Created by t_matsumura on 2017/06/18.
//  Copyright © 2017年 TakkuMattsu. All rights reserved.
//

import Foundation
import Crashlytics

/// Crashlytics用のコード
/// この辺は適宜拡張してください
enum CrashlyticsErrorCode :Int {
    /// 不明なエラー
    case unknownError = 0
    /// xxxAPIのJson不正
    case xxxApiJsonInvalid = 100
    /// zzzAPIのJson不正
    case zzzApiJsonInvalid = 101
    /// コード値
    var value:Int {
        get {
            return self.rawValue
        }
    }
    /// エラードメイン
    var domain: String {
        get {
            switch self {
            case .unknownError:
                return "Unknown Error."
            case .xxxApiJsonInvalid:
                return "xxx API Json Invalid Error."
            case .zzzApiJsonInvalid:
                return "yyy API Json Invalid Error."
            }
        }
    }
}

/// Crashlytics用のエラー
class CrashlyticsError : NSError {
    
    // この辺も必要なものを適宜作成
    
    let msgKey:String = "概要"
    let requestKey:String = "リクエスト"
    let requestParamKey:String = "リクエストパラメータ"
    let responseKey:String = "レスポンス"
    
    private override init(domain: String, code: Int, userInfo dict: [AnyHashable : Any]? = nil) {
        super.init(domain: domain, code: code, userInfo: dict)
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    /// 初期化
    ///
    /// - Parameters:
    ///   - code: 必須 CrashlyticsErrorCode
    ///   - errMsg: 任意 errMsg
    ///   - debuggableObj: 任意 CrashlyticsDebuggable
    init(code: CrashlyticsErrorCode, errMsg:String? = nil, debuggableObj:CrashlyticsDebuggable? = nil, file:String = #file, line:Int = #line){
        var userInfo:[AnyHashable : Any] = [:]
        userInfo[msgKey] = (errMsg != nil) ? "[\(file):\(line)] \(errMsg!)" : "[\(file):\(line)]"
        if let debuggableObj = debuggableObj {
            // リクエスト
            if let requestMsg = debuggableObj.requestDebugStr {
                userInfo[requestKey] = requestMsg
            }
            // レスポンス
            if let responseStr = debuggableObj.responseDebugStr {
                userInfo[responseKey] = responseStr
            }
        }
        super.init(domain: code.domain, code: code.value, userInfo: userInfo)
    }
    
    /// Crashlyticsへログ送信
    func sendCrashlytics(){
        Crashlytics.sharedInstance().recordError(self)
    }
}
