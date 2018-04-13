//
//  NSURLRequest.swift
//  IntelligenceSDK
//
//  Created by Josep Rodriguez on 28/07/2015.
//  Copyright © 2015 Tigerspike. All rights reserved.
//

import Foundation

private let HTTPHeaderAcceptKey = "Accept"
private let HTTPHeaderAuthorizationKey = "Authorization"
private let HTTPHeaderContentTypeKey = "Content-Type"
private let HTTPHeaderApplicationJson = "application/json"
private let HTTPHeaderApplicationFormUrlEncoded = "application/x-www-form-urlencoded"

private let HTTPBodyClientIDKey = "client_id"
private let HTTPBodyClientSecretKey = "client_secret"
private let HTTPBodyRefreshTokenKey = "refresh_token"
private let HTTPBodyUsernameKey = "username"
private let HTTPBodyPasswordKey = "password"

private let HTTPBodyGrantTypeKey = "grant_type"
private let HTTPBodyGrantTypeClientCredentials = "client_credentials"
private let HTTPBodyGrantTypePassword = "password"
private let HTTPBodyGrantTypeRefreshToken = "refresh_token"

enum IdentifierType: Int {
    case email = 1
    case msisdn = 2
    case iOSDeviceToken = 3
    case androidRegistrationID = 4
    case windowsRegistrationID = 5
}

extension Date {

    var  stringValue: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy"
        let dateString = dateFormatter.string(from: self)
        return dateString
    }

    func dateByAddingDays(days: Int) -> Date {
        let interval: TimeInterval = Double(days)*24*60*60
        let date = self.addingTimeInterval(interval)
        return date
    }
}

extension IntelligenceLogger {

    private var daysToKeeplogs: Int {
        return 5
    }

    private var folderPath: String {
        return (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString).appendingPathComponent("Intelligence")
    }

    func filePath(forDate: Date) -> String {
        let filePath = folderPath
        let dateStr =  forDate.stringValue
        let fullPath = (filePath as NSString).appendingPathComponent(dateStr)
        return fullPath
    }

    func clearOldLogFiles() {

        var allNames: [String] = []
        let directoryContents = try? FileManager.default.contentsOfDirectory(at: URL.init(fileURLWithPath: folderPath), includingPropertiesForKeys: nil, options: [])

        if let directoryContents = directoryContents {
            allNames = directoryContents.map { (dirPath) -> String in
                return dirPath.lastPathComponent
            }
        }

        guard  allNames.count > 0  else {
            return
        }

        var recentFiles: [String] = []
        for i in 0..<self.daysToKeeplogs {
            let date = Date().dateByAddingDays(days: -i)
            recentFiles.append(date.stringValue)
        }

        for name in allNames {
            if (!recentFiles.contains(name)) {
                let path = (folderPath as NSString).appendingPathComponent(name)
                if (FileManager.default.fileExists(atPath: path)) {
                    try? FileManager.default.removeItem(atPath: path)
                }
            }
        }
    }

    func createLogFile(forDate: Date) -> String {

        let fileManager = FileManager.default
        var isDir: ObjCBool = false

        if (!fileManager.fileExists(atPath: folderPath, isDirectory: &isDir)) {
            if !isDir.boolValue {
                do {
                    try fileManager.createDirectory(atPath: folderPath, withIntermediateDirectories: true, attributes: nil)
                } catch {
                    print("Failed to create folder")
                }
            }
        }
        return filePath(forDate: forDate)
    }
}

extension NSError {

    func descriptionWith(urlRequest: URLRequest? = nil, response: HTTPURLResponse? = nil) -> String {

        var dict: [String: Any] = [ : ]

        dict["error"] = self.description

        if let urlRequest = urlRequest, let url = urlRequest.url?.absoluteString {
            dict["url"] = url
        }

        var str = String(format: "Response : %@ ---> %@", (urlRequest?.url?.absoluteString) ?? "***", dict)

        guard let response = response else {
            return str
        }

        str = str.appending(response.debugInfo)
        return str
    }
}

extension HTTPURLResponse {

     var debugInfo: String {
        get {

            var dict: [String: Any] = [:]

            let statusCode = self.statusCode
            dict["statusCode"] = statusCode

            if let url = self.url {
                dict["request"] = url.absoluteString
            }

            dict["httpHeaderFields"] = self.allHeaderFields

            let str = String(format: "Response : %@ ---> %@", (url?.absoluteString) ?? "***", dict.description)
            return str
        }
    }
}

// MARK: - OAuth

extension URLRequest {
    fileprivate static func int_HTTPHeaders(bearerOAuth: IntelligenceOAuthProtocol? = nil) -> [String: String] {
        var headers = [String: String]()
        headers[HTTPHeaderAcceptKey] = HTTPHeaderApplicationJson
        if (bearerOAuth != nil && bearerOAuth?.accessToken != nil) {
            headers[HTTPHeaderAuthorizationKey] = "Bearer \(bearerOAuth!.accessToken!)"
        }
        return headers
    }

    fileprivate static func int_HTTPBodyData(body: [String: String]) -> Data {
        return body.map({ "\($0.0)=\($0.1)" }).joined(separator: "&").data(using: .utf8)!
    }

    /// Create a NSURLRequest for validate.
    /// - parameter oauth: The oauth values to use for this request.
    /// - parameter configuration: The configuration values to use for this request.
    /// - parameter network: The network the request will be queued on.
    /// - returns: An NSURLRequest to validate a token.
    static func int_URLRequestForValidate(oauth: IntelligenceOAuthProtocol, configuration: Intelligence.Configuration, network: Network) -> URLRequest {
        let url = URL(module: .authentication, configuration: configuration)!.int_URLByAppendingOAuthValidatePath()
        var request = URLRequest(url: url)

        request.allHTTPHeaderFields = int_HTTPHeaders(bearerOAuth: oauth)
        request.addValue(HTTPHeaderApplicationFormUrlEncoded, forHTTPHeaderField: HTTPHeaderContentTypeKey)

        request.httpMethod = HTTPRequestMethod.get.rawValue

        return request
    }

    /// Create a NSURLRequest for refreshToken.
    /// - parameter oauth: The oauth values to use for this request.
    /// - parameter configuration: The configuration values to use for this request.
    /// - parameter network: The network the request will be queued on.
    /// - returns: An NSURLRequest to refresh a token.
    static func int_URLRequestForRefresh(oauth: IntelligenceOAuthProtocol, configuration: Intelligence.Configuration, network: Network) -> URLRequest {
        assert(oauth.refreshToken != nil)
        let url = URL(module: .authentication, configuration: configuration)!.int_URLByAppendingOAuthTokenPath()
        var request = URLRequest(url: url)

        var body = [String: String]()
        body[HTTPBodyClientIDKey] = configuration.clientID
        body[HTTPBodyClientSecretKey] = configuration.clientSecret
        body[HTTPBodyGrantTypeKey] = HTTPBodyGrantTypeRefreshToken
        body[HTTPBodyRefreshTokenKey] = oauth.refreshToken

        request.allHTTPHeaderFields = int_HTTPHeaders()
        request.addValue(HTTPHeaderApplicationFormUrlEncoded, forHTTPHeaderField: HTTPHeaderContentTypeKey)

        request.httpMethod = HTTPRequestMethod.post.rawValue
        request.httpBody = int_HTTPBodyData(body: body)
        return request
    }

    /// Create a NSURLRequest for login.
    /// - parameter oauth: The oauth values to use for this request.
    /// - parameter configuration: The configuration values to use for this request.
    /// - parameter network: The network the request will be queued on.
    /// - returns: An NSURLRequest to get a token.
    static func int_URLRequestForLogin(oauth: IntelligenceOAuthProtocol, configuration: Intelligence.Configuration, network: Network) -> URLRequest {
        let url = URL(module: .authentication, configuration: configuration)!.int_URLByAppendingOAuthTokenPath()
        var request = URLRequest(url: url)

        var body = [String: String]()
        body[HTTPBodyClientIDKey] = configuration.clientID
        body[HTTPBodyClientSecretKey] = configuration.clientSecret

        if ((configuration.userName == nil || configuration.userPassword == nil) &&
            oauth.tokenType == IntelligenceOAuthTokenType.application) {
            body[HTTPBodyGrantTypeKey] = HTTPBodyGrantTypeClientCredentials
        } else {
            body[HTTPBodyGrantTypeKey] = HTTPBodyGrantTypePassword
            body[HTTPBodyUsernameKey] = oauth.username!
            body[HTTPBodyPasswordKey] = configuration.password_md5 ? MD5(oauth.password!) :  oauth.password
        }

        request.allHTTPHeaderFields = int_HTTPHeaders()
        request.addValue(HTTPHeaderApplicationFormUrlEncoded, forHTTPHeaderField: HTTPHeaderContentTypeKey)

        request.httpMethod = HTTPRequestMethod.post.rawValue
        request.httpBody = int_HTTPBodyData(body: body)
        return request
    }

    var description: String {

        var dict: [String: Any] = [:]

        if let postMethod = self.httpMethod {
            dict["httpMethod"] = postMethod
        }

        if let headerFields = self.allHTTPHeaderFields {
            dict["httpHeaderFields"] = headerFields
        }

        if let urlStr = self.url?.absoluteString {
            dict["request"] = urlStr
        }

        var body: AnyObject? = nil

        if let jsonObj = self.httpBody?.int_jsonDictionary {
            body = jsonObj as AnyObject
        } else if let jsonObj = self.httpBody?.int_jsonArray {
            body = jsonObj as AnyObject
        } else if let jsonObj = self.httpBody?.int_jsonDictionaryArray {
            body = jsonObj as AnyObject
        }

        if let body = body {
            dict["body"] = body
        }

        let str = String(format: "Request : %@ ---> %@", (url?.absoluteString) ?? "***", dict.description)
        return str
    }
}

// MARK: - Identity Module

extension URLRequest {

    /// Create a NSURLRequest for assignRole.
    /// - parameter roleId: The id of the role to assign.
    /// - parameter user: The user whose role we are assigning.
    /// - parameter oauth: The oauth values to use for this request.
    /// - parameter configuration: The configuration values to use for this request.
    /// - parameter network: The network the request will be queued on.
    /// - returns: An NSURLRequest to assign a role to a given user.
    static func int_URLRequestForUserRoleAssignment(roleId: Int, user: Intelligence.User, oauth: IntelligenceOAuthProtocol, configuration: Intelligence.Configuration, network: Network) -> URLRequest {
        let userid = "\(user.userId)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        let roleid = "\(roleId)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!

        let url = URL(module: .identity, configuration: configuration)!
            .int_URLByAppendingProjects(projectID: configuration.projectID)
            .int_URLByAppendingAssignRole()
            .int_URLByAppendingQueryString(queryString: "userid=\(userid)&roleid=\(roleid)")!
        var request = URLRequest(url: url)

        request.allHTTPHeaderFields = int_HTTPHeaders(bearerOAuth: oauth)
        request.addValue(HTTPHeaderApplicationJson, forHTTPHeaderField: HTTPHeaderContentTypeKey)

        request.httpMethod = HTTPRequestMethod.post.rawValue

        return request
    }

    /// Create a NSURLRequest for revokeRole.
    /// - parameter roleId: The id of the role to revoke.
    /// - parameter user: The user whose role we are revoking.
    /// - parameter oauth: The oauth values to use for this request.
    /// - parameter configuration: The configuration values to use for this request.
    /// - parameter network: The network the request will be queued on.
    /// - returns: An NSURLRequest to revoke a role from a given user.
    static func int_URLRequestForUserRoleRevoke(roleId: Int, user: Intelligence.User, oauth: IntelligenceOAuthProtocol, configuration: Intelligence.Configuration, network: Network) -> URLRequest {
        let userid = "\(user.userId)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        let roleid = "\(roleId)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!

        let url = URL(module: .identity, configuration: configuration)!
            .int_URLByAppendingProjects(projectID: configuration.projectID)
            .int_URLByAppendingRevokeRole()
            .int_URLByAppendingQueryString(queryString: "userid=\(userid)&roleid=\(roleid)")!
        var request = URLRequest(url: url)

        request.allHTTPHeaderFields = int_HTTPHeaders(bearerOAuth: oauth)
        request.addValue(HTTPHeaderApplicationJson, forHTTPHeaderField: HTTPHeaderContentTypeKey)

        request.httpMethod = HTTPRequestMethod.delete.rawValue

        return request
    }

    /// Create a NSURLRequest for getUserMe.
    /// - parameter oauth: The oauth values to use for this request.
    /// - parameter configuration: The configuration values to use for this request.
    /// - parameter network: The network the request will be queued on.
    /// - returns: An NSURLRequest to get the user with the used credentials.
    static func int_URLRequestForUserMe(oauth: IntelligenceOAuthProtocol, configuration: Intelligence.Configuration, network: Network) -> URLRequest {
        let url = URL(module: .identity, configuration: configuration)!
            .int_URLByAppendingProviders(providerId: configuration.providerId)
            .int_URLByAppendingUsersMe()
        var request = URLRequest(url: url)

        request.allHTTPHeaderFields = int_HTTPHeaders(bearerOAuth: oauth)
        request.addValue(HTTPHeaderApplicationJson, forHTTPHeaderField: HTTPHeaderContentTypeKey)

        request.httpMethod = HTTPRequestMethod.get.rawValue

        return request
    }

    // MARK: Identifiers

    /// Create a NSURLRequest for createIdentifier.
    /// - parameter tokenString: The identifier we will create.
    /// - parameter oauth: The oauth values to use for this request.
    /// - parameter configuration: The configuration values to use for this request.
    /// - parameter network: The network the request will be queued on.
    /// - returns: An NSURLRequest to create an identifier.
    static func int_URLRequestForIdentifierCreation(tokenString: String, oauth: IntelligenceOAuthProtocol, configuration: Intelligence.Configuration, network: Network) -> URLRequest {
        let url = URL(module: .identity, configuration: configuration)!
            .int_URLByAppendingProjects(projectID: configuration.projectID)
            .int_URLByAppendingIdentifiers()
        var request = URLRequest(url: url)

        let json: [String: Any] = ["ApplicationId": configuration.applicationID,
            "IdentifierTypeId": IdentifierType.iOSDeviceToken.rawValue,
            "IsConfirmed": true,
            "Value": tokenString]

        request.allHTTPHeaderFields = int_HTTPHeaders(bearerOAuth: oauth)
        request.addValue(HTTPHeaderApplicationJson, forHTTPHeaderField: HTTPHeaderContentTypeKey)

        request.httpMethod = HTTPRequestMethod.post.rawValue
        request.httpBody = [json].int_toJSONData()

        return request
    }

    /// Create a NSURLRequest for deleteIdentifier.
    /// - parameter tokenId: The id of the identifier we will delete.
    /// - parameter oauth: The oauth values to use for this request.
    /// - parameter configuration: The configuration values to use for this request.
    /// - parameter network: The network the request will be queued on.
    /// - returns: An NSURLRequest to delete an identifier.
    static func int_URLRequestForIdentifierDeletion(tokenId: Int, oauth: IntelligenceOAuthProtocol, configuration: Intelligence.Configuration, network: Network) -> URLRequest {
        let url = URL(module: .identity, configuration: configuration)!
            .int_URLByAppendingProjects(projectID: configuration.projectID)
            .int_URLByAppendingIdentifiers(tokenID: tokenId)
        var request = URLRequest(url: url)

        request.allHTTPHeaderFields = int_HTTPHeaders(bearerOAuth: oauth)
        request.addValue(HTTPHeaderApplicationJson, forHTTPHeaderField: HTTPHeaderContentTypeKey)

        request.httpMethod = HTTPRequestMethod.delete.rawValue

        return request
    }

    /// Create a NSURLRequest for deleteIdentifierOnBehalf.
    /// - parameter token: The identifier we will delete on behalf.
    /// - parameter oauth: The oauth values to use for this request.
    /// - parameter configuration: The configuration values to use for this request.
    /// - parameter network: The network the request will be queued on.
    /// - returns: An NSURLRequest to delete an identifier on behalf.
    static func int_URLRequestForIdentifierDeletionOnBehalf(token: String, oauth: IntelligenceOAuthProtocol, configuration: Intelligence.Configuration, network: Network) -> URLRequest {
        let applicationId = "\(configuration.applicationID)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        let identifierValue = token.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        let identifierTypeId = "\(IdentifierType.iOSDeviceToken.rawValue)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!

        let url = URL(module: .identity, configuration: configuration)!
            .int_URLByAppendingProjects(projectID: configuration.projectID)
            .int_URLByAppendingIdentifiers()
            .int_URLByAppendingQueryString(queryString: "applicationId=\(applicationId)&identifierValue=\(identifierValue)&identifierTypeId=\(identifierTypeId)")!
        var request = URLRequest(url: url)

        request.allHTTPHeaderFields = int_HTTPHeaders(bearerOAuth: oauth)
        request.addValue(HTTPHeaderApplicationJson, forHTTPHeaderField: HTTPHeaderContentTypeKey)

        request.httpMethod = HTTPRequestMethod.delete.rawValue

        return request
    }

    // MARK: Installation

    /// Create a NSURLRequest for createInstallation.
    /// - parameter installation: The installation we are creating.
    /// - parameter oauth: The oauth values to use for this request.
    /// - parameter configuration: The configuration values to use for this request.
    /// - parameter network: The network the request will be queued on.
    /// - Returns: An NSURLRequest to create a given installation.
    static func int_URLRequestForInstallationCreate(installation: Installation, oauth: IntelligenceOAuthProtocol, configuration: Intelligence.Configuration, network: Network) -> URLRequest {
        let url = URL(module: .identity, configuration: configuration)!
            .int_URLByAppendingProjects(projectID: configuration.projectID)
            .int_URLByAppendingInstallations()
        var request = URLRequest(url: url)

        request.allHTTPHeaderFields = int_HTTPHeaders(bearerOAuth: oauth)
        request.addValue(HTTPHeaderApplicationJson, forHTTPHeaderField: HTTPHeaderContentTypeKey)

        request.httpMethod
            = HTTPRequestMethod.post.rawValue
        request.httpBody = [installation.toJSON()].int_toJSONData()

        return request
    }

    /// Create a NSURLRequest for updateInstallation.
    /// - parameter installation: The installation we are updating.
    /// - parameter oauth: The oauth values to use for this request.
    /// - parameter configuration: The configuration values to use for this request.
    /// - parameter network: The network the request will be queued on.
    /// - returns: An NSURLRequest to update a given installation.
    static func int_URLRequestForInstallationUpdate(installation: Installation, oauth: IntelligenceOAuthProtocol, configuration: Intelligence.Configuration, network: Network) -> URLRequest {
        let url = URL(module: .identity, configuration: configuration)!
            .int_URLByAppendingProjects(projectID: configuration.projectID)
            .int_URLByAppendingInstallations()
        var request = URLRequest(url: url)

        request.allHTTPHeaderFields = int_HTTPHeaders(bearerOAuth: oauth)
        request.addValue(HTTPHeaderApplicationJson, forHTTPHeaderField: HTTPHeaderContentTypeKey)

        request.httpMethod = HTTPRequestMethod.put
            .rawValue
        request.httpBody = [installation.toJSON()].int_toJSONData()

        return request
    }

}

// MARK: - Analytics Module
extension URLRequest {

    /// Create a NSURLRequest for sendEvent.
    /// - parameter json: The details of the event we are sending.
    /// - parameter oauth: The oauth values to use for this request.
    /// - parameter configuration: The configuration values to use for this request.
    /// - parameter network: The network the request will be queued on.
    /// - returns: An NSURLRequest to send an event.
    static func int_URLRequestForAnalytics(json: JSONDictionaryArray, oauth: IntelligenceOAuthProtocol, configuration: Intelligence.Configuration, network: Network) -> URLRequest {
        let url = URL(module: .analytics, configuration: configuration)!
            .int_URLByAppendingProjects(projectID: configuration.projectID)
            .int_URLByAppendingEvents()
        var request = URLRequest(url: url)

        request.allHTTPHeaderFields = int_HTTPHeaders(bearerOAuth: oauth)
        request.addValue(HTTPHeaderApplicationJson, forHTTPHeaderField: HTTPHeaderContentTypeKey)

        request.httpMethod = HTTPRequestMethod.post.rawValue
        request.httpBody = json.int_toJSONData()

        return request
    }

}

// MARK: - Location Module

extension URLRequest {

    /// Create a NSURLRequest for downloadGeofences.
    /// - parameter oauth: The oauth values to use for this request.
    /// - parameter configuration: The configuration values to use for this request.
    /// - parameter network: The network the request will be queued on.
    /// - parameter query: The query to apply to the url.
    /// - returns: An NSURLRequest to download geofences.
    static func int_URLRequestForDownloadGeofences(oauth: IntelligenceOAuthProtocol, configuration: Intelligence.Configuration, network: Network, query: GeofenceQuery) -> URLRequest {
        let url = URL(module: .location, configuration: configuration)!
            .int_URLByAppendingProjects(projectID: configuration.projectID)
            .int_URLByAppendingGeofences()
            .int_URLByAppendingQueryString(queryString: query.urlQueryString())!
        var request = URLRequest(url: url)

        request.allHTTPHeaderFields = int_HTTPHeaders(bearerOAuth: oauth)
        request.addValue(HTTPHeaderApplicationJson, forHTTPHeaderField: HTTPHeaderContentTypeKey)

        request.httpMethod = HTTPRequestMethod.get.rawValue
        // TODO: Add filtering

        return request
    }
}
