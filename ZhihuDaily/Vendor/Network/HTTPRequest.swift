//
//  GXBaseRequest.swift
//  iWeeB
//
//  Created by 高翔 on 2017/11/21.
//  Copyright © 2017年 GaoX. All rights reserved.
//

import UIKit
import Alamofire

enum NetworkEnvironment {
    case develop
    case product
    
    func baseUrl() -> String {
        switch self {
        case .develop:
            return "https://news-at.zhihu.com/api"
        default:
            return "https://www.lanqixinxikeji.com/api/public/index.php/api/"
        }
    }
}

class HTTPRequest {

    var requestMethod: HTTPMethod = .get
    var environment: NetworkEnvironment = .develop
    let path: String
    let parameters: [String: Any]?
    let needsCache: Bool
    
    init(path: String,
         parameters: [String: Any]?,
         needsCache: Bool = false) {
        self.path = path
        self.parameters = parameters
        self.needsCache = needsCache
    }

    func startWithCompletionBlock(
        success: @escaping (_ JSONString: String?, _ otherInfo: Any?) -> (),
        failure: @escaping (_ error: Error?, _ otherInfo: String) -> ()) {

        var encoding = URLEncoding.queryString
        if requestMethod == .post {
            encoding = .httpBody
        }

        func configureRequestUrl() -> String {
            var requestUrl = environment.baseUrl()
            if requestUrl.hasSuffix("/") {
                requestUrl.removeLast()
            }
            if !path.isEmpty {
                requestUrl.append("/\(path)")
            }
            return requestUrl.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
        }

        func configureParameters() -> [String: Any]? {
            return parameters
        }
        
        Alamofire.request(
            configureRequestUrl(),
            method: requestMethod,
            parameters: configureParameters(),
            encoding: encoding,
            headers: nil).responseJSON { (response) in
                print("requestUrl:", configureRequestUrl())
                print("parameters:", configureParameters() as Any)
                if response.result.isSuccess {
                    if let value = response.result.value {
                        var JSONString: String?
                        do {
                            if JSONSerialization.isValidJSONObject(value) {
                                let JSONData = try JSONSerialization.data(withJSONObject: value, options: .prettyPrinted)
                                JSONString = String(data: JSONData, encoding: .utf8)
                            }
                        }
                        catch {}
                        success(JSONString, nil)
                    }
                    else {
                        success(nil, response.debugDescription)
                    }
                }
                else {
                    failure(response.result.error, response.debugDescription)
                }
        }
    }

    static func upload(
        images: [UIImage],
        success: @escaping (_ JSONString: String?, _ otherInfo: Any?) -> (),
        failure: @escaping (_ error: Error?) -> ()) {

        Alamofire.upload(
            multipartFormData: { (multipartFormData) in
                images.forEach({
                    let imgData = UIImageJPEGRepresentation($0, 0.9)
                    let imgName = "\(Int(Date().timeIntervalSince1970)).jpg"
                    if let data = imgData {
                        multipartFormData.append(data, withName: "file", fileName: imgName, mimeType: "image/jpeg")
                    }
                })
        },
            to: "http://wuliu.hsrich.cn/index.php/api/Upload/doUpload") { (result) in
            switch result {
            case .success(let uploadRequest, _, _):
                uploadRequest.responseJSON(completionHandler: { (response) in
                    if response.result.isSuccess {
                        if let value = response.result.value {
                            var JSONString: String?
                            do {
                                if JSONSerialization.isValidJSONObject(value) {
                                    let JSONData = try JSONSerialization.data(withJSONObject: value, options: .prettyPrinted)
                                    JSONString = String(data: JSONData, encoding: .utf8)
                                }
                            }
                            catch {}
                            success(JSONString, nil)
                        }
                        else {
                            success(nil, response.debugDescription)
                        }
                    }
                    else {
                        failure(response.result.error)
                    }
                })
            case .failure(let error):
                failure(error)
            }
        }
    }
}

// MARK: - cache
extension HTTPRequest {

    private func checkDirectory(path: String) {
        var isDir: ObjCBool = ObjCBool(false)
        if !FileManager.default.fileExists(atPath: path, isDirectory: &isDir) {
            do {
                try FileManager.default.createDirectory(atPath: path, withIntermediateDirectories: true, attributes: nil)
            } catch {}
        }
        else {
            if !isDir.boolValue {
                do {
                    try FileManager.default.removeItem(atPath: path)
                    do {
                        try FileManager.default.createDirectory(atPath: path, withIntermediateDirectories: true, attributes: nil)
                    } catch  {}
                } catch  {}
            }
        }
    }

    private func cachePath() -> String {
        if let path = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).first {
            let cachePath = "\(path)/GXNetworkRequestCache"
            self.checkDirectory(path: cachePath)
            return cachePath
        }
        return ""
    }

    private func savedFilePath() -> String {

        func savedFileDirectory() -> String {
            let cachePath = self.cachePath()
            let fileDirectory = "\(cachePath)"
            self.checkDirectory(path: fileDirectory)
            return fileDirectory
        }

        func savedFileName() -> String {
            var paramArray = [String]()
            if let params = self.parameters {
                for (key, value) in params {
                    let param = "\(key):\(value)"
                    paramArray.append(param)
                }
            }
            let parameters = paramArray.joined(separator: "_")
            let fileName = "\(self.path)_\(parameters)"
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

    public func saveDataToDisk(data: Any) {
        let filePath = savedFilePath()
        objc_sync_enter(self)
        NSKeyedArchiver.archiveRootObject(data, toFile: filePath)
        objc_sync_exit(self)
    }

    public func cacheData() -> Any? {
        let filePath = savedFilePath()
        guard FileManager.default.fileExists(atPath: filePath) else {
            return nil
        }
        objc_sync_enter(self)
        let data = NSKeyedUnarchiver.unarchiveObject(withFile: filePath)
        objc_sync_exit(self)
        return data
    }

    public func clearCache() {
        let filePath = savedFilePath()
        if FileManager.default.fileExists(atPath: filePath) {
            do {
                try FileManager.default.removeItem(atPath: filePath)
            }
            catch {}
        }
    }

    public func clearAllCache() {
        let cachePath = self.cachePath()
        if FileManager.default.fileExists(atPath: cachePath) {
            do {
                try FileManager.default.removeItem(atPath: cachePath)
            }
            catch {}
        }
    }
}
