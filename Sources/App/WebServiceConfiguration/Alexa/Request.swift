//
//  Request.swift
//  AlexaSkillExample
//
//  Created by Jordan.Dixon on 14/08/2017.
//

import Vapor
import Foundation

/*
   Represents the user as a unique identifier. May also include
   an access token if this is available.
*/

public struct AlexaUser {
    public let identifier: String
    public let accessToken: String?
    
    init(json: JSON) throws {
        guard let userId = json["userId"]?.string
            else { throw AlexaError.invalidRequest }
        self.identifier = userId
        self.accessToken = json["accessToken"]?.string
    }
}

/*
   Represents the current session. Of particular note are the
   attributes. These are the same as those passed out in the last
   response sent by this skill during the current session. This
   may be nil if this is the first interaction in the session.
*/

public struct AlexaSession {
    public let sessionId: String
    public let applicationId: String
    public let attributes: JSON?
    public let user: AlexaUser
    public let new: Bool
    
    init?(json: JSON) throws {
        guard let sessionId = json["sessionId"]?.string,
            let application = json["application"],
            let applicationId = application["applicationId"]?.string,
            let userJSON = json["user"],
            let new = json["new"]?.bool
            else { throw AlexaError.invalidRequest }
        
        self.sessionId = sessionId
        self.applicationId = applicationId
        self.user = try AlexaUser(json: userJSON)
        self.new = new
        
        self.attributes = json["attributes"]
    }
}

/*
   Represents the state of the audio player, if this is available.
*/

public struct AlexaAudioPlayer {
    public let token: String
    public let offset: TimeInterval
    let activity: AlexaAudioActivity
    
    init (json: JSON) throws {
        guard let token = json["token"]?.string,
            let offset = json["offsetInMilliseconds"]?.int,
            let activityString = json["playerActivity"]?.string,
            let activity = AlexaAudioActivity(string: activityString)
            else { throw AlexaError.invalidRequest }
        
        self.token = token
        self.offset = TimeInterval(offset / 1000)
        self.activity = activity
    }
}

/*
   Represents the current state of the calling device's system.
   Includes what features are available for the skill's use, i.e.
   the audio player.
*/

public struct AlexaSystem {
    let applicationId: String
    let user: AlexaUser
    let supportedInterfaces: [String: JSON]
    
    init(json: JSON) throws {
        
        guard let application = json["application"],
            let appId = application["applicationId"]?.string,
            let userData = json["user"]
            else { throw AlexaError.invalidRequest }
        
        self.applicationId = appId
        self.user = try AlexaUser(json: userData)
        
        var interfaces = [String : JSON]()
        
        if let deviceData = json["device"],
            let allKeys = deviceData.object?.keys,
            !allKeys.isEmpty {
            
            for key in allKeys {
                guard let interfaceData = deviceData[key] else { continue }
                interfaces[key] = interfaceData
            }
        }
        self.supportedInterfaces = interfaces
    }
}

/*
   Optional data representing the current state of the system
   and its audio player.
*/

public struct AlexaContext {
    let audioPlayer: AlexaAudioPlayer?
    let system: AlexaSystem
    
    init(json: JSON) throws {
        guard let systemData = json["system"]
            else { throw AlexaError.invalidRequest }
        
        self.system = try AlexaSystem(json: systemData)
        if let audioData = json["AudioPlayer"] {
            self.audioPlayer = try AlexaAudioPlayer(json: audioData)
        } else {
            self.audioPlayer = nil
        }
    }
}

/*
   Details the basic intent that must be addressed by the
   skill's response. Of particular interest are the Slots,
   which represent variables identified by the skill's utterances
   as being important to what the skill will do. Examples might
   include a date, the name of a book or movie, or any other
   custom list of values that are required to process the request.
*/

public struct AlexaIntent {
    public let name: String
    public let slots: [String: String]
    
    init(json: JSON) throws {
        
        self.name = json["name"]?.string ?? ""
        var newSlots = [String: String]()
        
        if let allItems = json["slots"],
            let allKeys = json["slots"]?.object?.keys {
            
            for key in allKeys {
                // Think this should change - not all intents will have slots, and this guard will throw the init
                guard let itemJSON = allItems[key],
                    let name = itemJSON["name"]?.string,
                    let value = itemJSON["value"]?.string
                    else { throw AlexaError.invalidRequest }
                newSlots[name] = value
            }
        }
        self.slots = newSlots
    }
}

/*
   The basic data for the request, encapsulating type, locale,
   timestamp, request ID and all the data available on the request
   and the current state of the device the request came from.
*/

public struct AlexaRequest {
    let type: AlexaRequestType
    let requestId: String
    let locale: Locale
    let timestamp: Date
    
    public let intent: AlexaIntent
    public let session: AlexaSession?
    
    init(json: JSON) throws {
        guard let requestData = json["request"],
            let intentData = requestData["intent"],
            let typeString = requestData["type"]?.string,
            let type = AlexaRequestType(string: typeString),
            let requestId = requestData["requestId"]?.string,
            let localeString = requestData["locale"]?.string
            else { throw AlexaError.invalidRequest }
        
        self.type = type
        self.requestId = requestId
        self.locale = Locale(identifier: localeString)
        
        if let dateString = requestData["timestamp"]?.string {
            let formatter = DateFormatter()
            formatter.locale = locale
            formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
            timestamp = formatter.date(from: dateString) ?? Date()
        } else {
            throw AlexaError.invalidRequest
        }
        
        intent = try AlexaIntent(json: intentData)
        
        // Optional items
        
        if let sessionData = json["session"] {
            session = try AlexaSession(json: sessionData)
        } else {
            session = nil
        }
    }
    
}

