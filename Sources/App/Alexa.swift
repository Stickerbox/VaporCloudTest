import Foundation
import Vapor

extension Droplet {
    
    func setupAlexa() throws {
        
        /*
         This should be the application ID from the Amazon developer portal.
         Used to verify that requests you receive are actually for your
         application. If a request has the incorrect app ID to what you
         specify, an error response will be returned to the Alexa and
         your code won't run
         */
        
        appID = "YOUR-APP-ID-HERE"
        
        /*
         For each endpoint you set up in Amazon's web portal, create a
         new listen(at: "endpoint") function here. This function returns
         an AlexaRequest object and you must return an AlexaResponse
         */
        
        get("test") { _ in return "test received" }
        
        listen(at: "EXAMPLE-ENDPOINT") { request in
            
            /*
             The parameters passed to this endpoint, if there are any.
             These could be things like a date, or film title - you must
             first set these up in Amazon's web portal, as well as what
             type they are.
             */
            
            let _ = request.intent.slots
            
            /*
             Attributes sent with the request. These are the same as those passed out in the last
             response sent by this skill during the current session. This
             may be nil if this is the first interaction in the session.
             */
            
            let _ = request.session?.attributes
            
            /*
             Setting endSession to true ends the current contextual session for the user.
             Defaults to true
             */
            
            return AlexaResponse(text: "This is an example response.", endSession: false)
        }
        
    }
    
}
