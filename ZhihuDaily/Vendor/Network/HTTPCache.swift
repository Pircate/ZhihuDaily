//
//  HTTPCache.swift
//  ChengTayTong
//
//  Created by GorXion on 2018/3/1.
//  Copyright © 2018年 adinnet. All rights reserved.
//

import Moya

class HTTPCache {
    
    static let shared = HTTPCache()
    private init() {}
    
    private func checkDirectory(path: String) {
        var isDir: ObjCBool = ObjCBool(false)
        if !FileManager.default.fileExists(atPath: path, isDirectory: &isDir) {
            do {
                try FileManager.default.createDirectory(atPath: path, withIntermediateDirectories: true, attributes: nil)
            } catch {}
        }
        else {
            guard !isDir.boolValue else { return }
            do {
                try FileManager.default.removeItem(atPath: path)
                try FileManager.default.createDirectory(atPath: path, withIntermediateDirectories: true, attributes: nil)
            } catch  {}
        }
    }
    
    private func cachePath() -> String {
        if let path = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).first {
            let cachePath = "\(path)/GXNetworkRequestCache"
            checkDirectory(path: cachePath)
            return cachePath
        }
        return ""
    }
    
    private func savedFilePath<Target: TargetType>(_ target: Target) -> String {
        
        func savedFileDirectory() -> String {
            let cachePath = self.cachePath()
            let fileDirectory = "\(cachePath)"
            self.checkDirectory(path: fileDirectory)
            return fileDirectory
        }
        
        func savedFileName() -> String {
            var params: [String] = []
            switch target.task {
            case .requestParameters(let parameters, _):
                params = parameters.map({ (key, value) -> String in
                    "\(key):\(value)"
                })
            default:
                break
            }
            let parameters = params.joined(separator: "_")
            let fileName = "\(target.path)_\(parameters)"
            return convertToMD5(string: fileName)
        }
        
        func convertToMD5(string: String) -> String {
            let str = string.cString(using: .utf8)
            var digest = [UInt8].init(repeating: 0, count: Int(CC_MD5_DIGEST_LENGTH))
            CC_MD5(str, CC_LONG(strlen(str)), &digest)
            var output = String()
            for i in digest {
                output = output.appendingFormat("%02x", i)
            }
            return output
        }
        
        return "\(savedFileDirectory())/\(savedFileName())"
    }
    
    /// 缓存数据到磁盘
    ///
    /// - Parameter data: 请求数据
    static func saveDataToDisk<Target: TargetType>(_ data: Any, target: Target) {
        HTTPCache.shared.saveDataToDisk(data, target: target)
    }
    
    /// 读取缓存数据
    ///
    /// - Returns: 缓存数据
    static func cacheData<Target: TargetType>(_ target: Target) -> Any? {
        return HTTPCache.shared.cacheData(target)
    }
    
    private func saveDataToDisk<Target: TargetType>(_ data: Any, target: Target) {
        let filePath = savedFilePath(target)
        objc_sync_enter(self)
        NSKeyedArchiver.archiveRootObject(data, toFile: filePath)
        objc_sync_exit(self)
    }
    
    private func cacheData<Target: TargetType>(_ target: Target) -> Any? {
        let filePath = savedFilePath(target)
        guard FileManager.default.fileExists(atPath: filePath) else {
            return nil
        }
        objc_sync_enter(self)
        let data = NSKeyedUnarchiver.unarchiveObject(withFile: filePath)
        objc_sync_exit(self)
        return data
    }
    
    /// 清除当前请求缓存
    func clearCache<Target: TargetType>(_ target: Target) {
        let filePath = savedFilePath(target)
        if FileManager.default.fileExists(atPath: filePath) {
            do {
                try FileManager.default.removeItem(atPath: filePath)
            }
            catch {}
        }
    }
    
    /// 清除所有网络请求缓存
    func clearAllCache() {
        let cachePath = self.cachePath()
        if FileManager.default.fileExists(atPath: cachePath) {
            do {
                try FileManager.default.removeItem(atPath: cachePath)
            }
            catch {}
        }
    }
}
