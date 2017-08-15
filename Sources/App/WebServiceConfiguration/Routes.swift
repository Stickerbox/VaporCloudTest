import Foundation
import Vapor

extension Droplet {
    func setupRoutes() throws {
        
        post("test") { request in
            return "hey"
        }

        get("lol") { request in
            return "heyyy"
        }
        
        try resource("posts", PostController.self)
    }
}

public extension Droplet {
    
    func listen(at endpoint: String, completion: @escaping (AlexaRequest) -> (AlexaResponse)) {

        post(endpoint) { request in
            guard let json = request.json else { return self.failureResponse }
            
            do {
                
                let alexaRequest = try AlexaRequest(json: json)
                
                if alexaRequest.session?.applicationId != self.appID {
                    return self.failureResponse
                }
                
                return completion(alexaRequest)
                
            } catch let error {
                
                guard let error = error as? AlexaError else {
                    return self.failureResponse
                }
                
                return self.handle(error: error)
            }
            
        }
        
    }
    
    func handle(error: AlexaError) -> AlexaResponse {
        
        switch error {
            
        case .invalidRequest:
            return AlexaResponse(text: "Sorry, that request was invalid")
            
        case .wrongApplicationId:
            return AlexaResponse(text: "Sorry, the application ID was incorrect", endSession: true)
        }
    }
    
    var failureResponse: AlexaResponse {
        return AlexaResponse(text: "Sorry, I wasn't able to handle your request")
    }
    
    var appID: String {
        get {
            return UserDefaults.standard.string(forKey: "APPID") ?? ""
        }
        
        set {
            UserDefaults.standard.set(appID, forKey: "APPID")
        }
    }
}
