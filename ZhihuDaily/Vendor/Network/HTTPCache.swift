//
//  HTTPCache.swift
//  ChengTayTong
//
//  Created by GorXion on 2018/3/1.
//  Copyright © 2018年 adinnet. All rights reserved.
//

import Moya

open class HTTPCache {
    
    static let shared = HTTPCache()
    private init() {}
    
    private let memoryCache = NSCache<NSString, AnyObject>()

    /// 存储缓存数据
    ///
    /// - Parameters:
    ///   - data: 缓存数据
    ///   - target: 请求target
    open func storeCachedData(_ data: Data, for target: TargetType) {
        let filePath = savedFilePath(target)
        
        memoryCache.setObject(data as AnyObject, forKey: filePath as NSString)
        
        objc_sync_enter(self)
        NSKeyedArchiver.archiveRootObject(data, toFile: filePath)
        objc_sync_exit(self)
    }
    
    /// 读取缓存数据
    ///
    /// - Parameter target: 请求target
    /// - Returns: 缓存数据
    open func cachedData(for target: TargetType) -> Data? {
        let filePath = savedFilePath(target)
        
        if let memoryCachedData = memoryCache.object(forKey: filePath as NSString) as? Data {
            return memoryCachedData
        }
        
        guard FileManager.default.fileExists(atPath: filePath) else {
            return nil
        }
        objc_sync_enter(self)
        let diskCachedData = NSKeyedUnarchiver.unarchiveObject(withFile: filePath) as? Data
        objc_sync_exit(self)
        return diskCachedData
    }
    
    /// 清除缓存数据
    ///
    /// - Parameter target: 请求target
    open func removeCachedData(for target: TargetType) {
        let filePath = savedFilePath(target)
        removeItem(atPath: filePath)
    }
    
    /// 清除所有缓存数据
    open static func removeAllCachedData() {
        let cachedPath = shared.cachedPath()
        shared.removeItem(atPath: cachedPath)
    }
    
    // MARK: private
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
    
    private func cachedPath() -> String {
        guard let path = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).first else {
            fatalError("Search caches directory fail")
        }
        let cachedPath = "\(path)/GXNetworkRequestCache"
        checkDirectory(path: cachedPath)
        return cachedPath
    }
    
    private func savedFilePath(_ target: TargetType) -> String {
        
        func savedFileDirectory() -> String {
            let cachedPath = self.cachedPath()
            let fileDirectory = "\(cachedPath)"
            self.checkDirectory(path: fileDirectory)
            return fileDirectory
        }
        
        func savedFileName() -> String {
            switch target.task {
            case .requestParameters(let parameters, _):
                let params = parameters.map({
                    "\($0)=\($1)"
                }).joined(separator: "&")
                let fileName = "\(target.baseURL)\(target.path)?\(params)"
                return convertToMD5(string: fileName)
            default:
                break
            }
            let fileName = "\(target.baseURL)\(target.path)"
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
    
    private func removeItem(atPath path: String) {
        if FileManager.default.fileExists(atPath: path) {
            do {
                try FileManager.default.removeItem(atPath: path)
            }
            catch {}
        }
    }
}
