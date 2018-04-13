//
//  IntelligenceOAuthValidateOperation.swift
//  IntelligenceSDK
//
//  Created by Chris Nevin on 01/10/2015.
//  Copyright © 2015 Tigerspike. All rights reserved.
//

import Foundation

class IntelligenceOAuthValidateOperation: IntelligenceOAuthOperation {

    override func main() {
        super.main()
        assert(oauth != nil && network != nil && configuration != nil)
        if (oauth?.accessToken == nil) {
            print("\(oauth!.tokenType) Validate Token Skipped")
            return
        }
        let request = URLRequest.int_URLRequestForValidate(oauth: oauth!, configuration: configuration!, network: network!)
        sharedIntelligenceLogger.logger?.debug(request.description)

        output = session?.int_executeSynchronousDataTask(with: request)

        if handleError() {

            let str = "\(oauth!.tokenType) Validate Failed \(String(describing: output?.error))"
            sharedIntelligenceLogger.logger?.error(str)

            return
        }

        // Assumption: 200 status code means our token is valid, otherwise invalid.
        guard let httpResponse = output?.response as? HTTPURLResponse, httpResponse.statusCode == HTTPStatusCode.success.rawValue &&
                output?.data?.int_jsonDictionary?[OAuthAccessTokenKey] != nil else {
            if output?.error == nil {
                output?.error = NSError(code: RequestError.parseError.rawValue)
            }

            let str = String(format: "Validate Token Failed -- %@", (output?.error?.description)!)
            sharedIntelligenceLogger.logger?.error(str)

            self.shouldBreak = true
            return
        }
        self.shouldBreak = true
        sharedIntelligenceLogger.logger?.debug(httpResponse.debugInfo)

    }

}
