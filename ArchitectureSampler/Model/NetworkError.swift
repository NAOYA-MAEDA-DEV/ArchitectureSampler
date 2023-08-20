//
//  NetworkError.swift
//  ArchitectureSampler
//
//  Created by N. M on 2023/08/05.
//

import Foundation

/// リポジトリ検索に失敗した時のエラーの種類
enum NetworkError: Error {
    case invalid // URLが不正
    case network // ネットワークがオフライン
    case parse // レスポンスデータのパースエラー
    
    /// エラー名を表す文字列
    var message: String {
        switch self {
        case .invalid:
            return "Invalid URL Error"
            
        case .network:
            return "Network Error"
            
        case .parse:
            return "Parse Error"
        }
    }
}
