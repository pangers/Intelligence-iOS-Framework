//
//  PhoenixOAuthTestCase.swift
//  PhoenixSDK
//
//  Created by Chris Nevin on 05/10/2015.
//  Copyright © 2015 Tigerspike. All rights reserved.
//

import Foundation

let validLogin = "{\n  \"access_token\": \"ZG1iY3dydWJudHYzY3FodHQ2cTdxdmhicWpoZDh1ODQ=\",\n  \"token_type\": \"bearer\",\n  \"expires_in\": 7200,\n  \"refresh_token\": \"rkdrdbyuh3awnsybvqvpgfvf4ymc8f5tmtbsbrfg7uppmnpxj7ggxjmapxnepmm3\"\n}"

let validRefresh = "{\n  \"access_token\": \"dmdhdGc4MjZhZWdtczl1ZmFudDJ5bXc0ODI0ZDUydGs=\",\n  \"token_type\": \"bearer\",\n  \"expires_in\": 7200,\n  \"refresh_token\": \"9nr6dwgb7c8h3yhf5852tk3bm7kf5m29mwd6gp3d7gunec28hnawvssnkfj7a27k\"\n}"

let validValidate = "{\n  \"access_token\": \"dmdhdGc4MjZhZWdtczl1ZmFudDJ5bXc0ODI0ZDUydGs=\",\n  \"token_type\": \"bearer\",\n  \"expires_in\": 7172\n}"

let invalidToken = "{\n  \"error\": \"invalid_grant\",\n  \"error_description\": \"Invalid authorization grant request: 'refresh_token not valid'.\"\n}"

class PhoenixOAuthTestCase: PhoenixBaseTestCase {
    
    func mockClientCredentialsLoginPassed() {
        
        
        
    }
    
    
    func testFirstLogin() {
        
        
        
        
        
    }
    
    
    
}
