//
//  ViewController.swift
//  CrashlyticsLogSample
//
//  Created by t_matsumura on 2017/06/18.
//  Copyright © 2017年 TakkuMattsu. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        dummyRequestMethod(success: nil) { [weak self] (error) in
            // エラーダイアログ
            let alertController = UIAlertController(title: "エラー!", message: "エラーが発生しました。", preferredStyle: .alert)
            let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alertController.addAction(defaultAction)
            self?.present(alertController, animated: true, completion: nil)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    /// failureブロックがオプショナルだったりしているのはサンプルだからです。本来はオプショナルではない方がいいはず
    private func dummyRequestMethod(success:(()->())?, failure:((Error?)->())?){
        // 例えばリクエストして失敗した
        let url = URL(string:"https://jsonplaceholder.typicode.com/posts/hello")! // 404が返る
        let request = URLRequest(url: url)
        let configuration = URLSessionConfiguration.default
        let session = URLSession(configuration: configuration, delegate:nil, delegateQueue:OperationQueue.main)
        
        let task = session.dataTask(with: request, completionHandler: {
            (data, response, error) -> Void in
            if let res = response as? HTTPURLResponse, 400...499 ~= res.statusCode {
                // 今回のコードはここを通ることを期待しています
                
                // エラーをCrashlyticsに送信
                let debugInfo = XXXAPIDebugInfo(request: request, response: response, data: data)
                CrashlyticsError.init(code: .xxxApiJsonInvalid, errMsg: "リクエストが400-499を返した", debuggableObj:debugInfo).sendCrashlytics()
                // 開発時は落ちる、本番はスルー
                assertionFailure("リクエストが400-499を返した")
                // failureの呼び出し側でエラーダイアログ等を出す
                failure?(error)
                return
            }
            success?()
            return
        })
        task.resume()
    }
    
    // MARK: - XXXAPIDebugInfo
    /// XXXAPI用のデバッグクラス
    struct XXXAPIDebugInfo: CrashlyticsDebuggable {
        
        let request: URLRequest?
        let response: URLResponse?
        let data:Any?
        
        // MARK: - CrashlyticsDebuggable
        /// Request文字列
        var requestDebugStr: String? {
            get {
                guard let url = request?.url, let method = request?.httpMethod else {
                    return nil;
                }
                // GET -> https://jsonplaceholder.typicode.com/posts/hello
                return "\(method) -> \(url)"
            }
        }
        /// レスポンス文字列
        var responseDebugStr :String? {
            get {
                guard let res = response as? HTTPURLResponse, let data = data as? Data else {
                    return nil
                }
                guard let resStr = String(data: data, encoding: .utf8) else {
                    return nil
                }
                // 400 <- ""
                return "\(res.statusCode) <- \(resStr)"
            }
        }
    }
}

