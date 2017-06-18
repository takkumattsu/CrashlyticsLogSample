//
//  CrashlyticsDebuggable.swift
//  CrashlyticsLogSample
//
//  Created by t_matsumura on 2017/06/18.
//  Copyright © 2017年 TakkuMattsu. All rights reserved.
//

import Foundation

/// エラーログ用の拡張
protocol CrashlyticsDebuggable {
    /// Request文字列
    var requestDebugStr: String? { get }
    /// レスポンス文字列
    var responseDebugStr :String? { get }
}
