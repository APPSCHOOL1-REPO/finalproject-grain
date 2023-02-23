//
//  GeocodeRouter.swift
//  Grain
//
//  Created by 지정훈 on 2023/02/01.
//

import Foundation


enum GeocodeRouter {

    case get
    private enum HTTPMethod {
            case get
        
            var value: String {
                switch self {
                case .get: return "GET"
                }
            }
        }
    
    private var method: HTTPMethod {
        switch self {
        case .get :
            return .get
        default:
            return .get
        }
    }

    func asURLRequest(requestAddress: String) throws -> URLRequest {
        // requestAddress -> 주소 검색할 String 값 받아야 합니다
        let queryURL = "https://naveropenapi.apigw.ntruss.com/map-geocode/v2/geocode?query=\(requestAddress)"
        let encodeQueryURL = queryURL.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        
        let clientID = Bundle.main.infoDictionary?["NaverClientID"] ?? ""
        let clientSecret = Bundle.main.infoDictionary?["NaverClientSecret"] ?? ""

        
        var request = URLRequest(url: URL(string: encodeQueryURL)!)
        request.setValue(clientID as! String, forHTTPHeaderField: NaverAPIEnum.naverApI.clientHeaderKeyID)
        request.setValue(clientSecret as! String, forHTTPHeaderField: NaverAPIEnum.naverApI.clientHeaderSecretID)
        request.httpMethod = method.value
        return request
    }
    
}


