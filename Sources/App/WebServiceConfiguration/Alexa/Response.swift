//
//  Response.swift
//  AlexaSkillExample
//
//  Created by Jordan.Dixon on 14/08/2017.
//

import Vapor
import Foundation

protocol NodeConvertible: ResponseRepresentable {
    var node: Node { get }
}

extension NodeConvertible {
    
    public func makeResponse() throws -> Response {
        return try Response(status: .ok, json: try JSON(node: [node]))
    }
}

protocol AlexaDirective: NodeConvertible {}

/*
   Constructs a suitable response that will make Alexa speak a certain
   phrase. If endSession is false, the contents of attributes will be
   available in the next request's Context.
*/

enum AlexaSpeech: NodeConvertible {
    case plainText(String)
    case ssml(String)
    
    var node: Node {
        get {
            switch self {
            case .plainText(let text) :
                return [
                    "type" : "PlainText",
                    "text" : Node(text)
                ]
            case .ssml(let text) :
                return [
                    "type" : "SSML",
                    "ssml" : Node("<speak>\(text)</speak>")
                ]
            }
        }
    }

}

/*
   Determines what is displayed in the Alexa mobile app's history screen.
   Note that each card type has its own JSON structure and variables, and
   is thus represented by a separate object.
*/
 
protocol AlexaCardable: NodeConvertible {}

/*
   A card that allows the user to link their Alexa account to the skill.
*/

struct AlexaLinkAccountCard: AlexaCardable {
    
    var node: Node {
        return ["type": "LinkAccount"]
    }
}

/*
   A card with a simple title / text output.
*/

struct AlexaSimpleCard: AlexaCardable {
    
    var title: String
    var content: String
    
    var node: Node {
        return [
            "type": "Simple",
            "title": Node(title),
            "content": Node(content)
        ]
    }

}

/*
   A card with title, text and optional images for display on large or
   small screen interfaces. Images are passed as URLs.
*/

struct AlexaStandardCard: AlexaCardable {
    var title: String
    var text: String
    var largeImageURL: String?
    var smallImageURL: String?
    
    var node: Node {
        var newNode: Node = [
            "type": "Standard",
            "title": Node(title),
            "text": Node(text)
        ]
        
        if let imageNode = imageNode {
            newNode["image"] = imageNode
        }
        
        return newNode
    }
    
    private var imageNode: Node? {
        if largeImageURL == nil && smallImageURL == nil { return nil }
        var imageNode: Node = Node([:])
        if let largeImageURL = largeImageURL {
            imageNode["largeImageUrl"] = Node(largeImageURL)
        }
        if let smallImageURL = smallImageURL {
            imageNode["smallImageUrl"] = Node(smallImageURL)
        }
        return imageNode
    }
    
}

/*
   The response structure itself. The node is converted to JSON and
   passed as the return value to the caller.
*/

public struct AlexaResponse: NodeConvertible {
    
    var speech: AlexaSpeech?
    var reprompt: AlexaSpeech?
    var card: AlexaCardable?
    var attributes: Node?
    var endSession: Bool
    var directives: [AlexaDirective]?
    
    init(text: String, card: AlexaCardable? = nil, attributes: Node? = nil, endSession: Bool = true) {
        self.speech = AlexaSpeech.plainText(text)
        self.reprompt = nil
        self.card = card
        self.attributes = attributes
        self.endSession = endSession
    }
    
    init(ssml: String, card: AlexaCardable? = nil, attributes: Node? = nil, endSession: Bool = true) {
        self.speech = AlexaSpeech.ssml(ssml)
        self.reprompt = nil
        self.card = card
        self.attributes = attributes
        self.endSession = endSession
    }
    
    var node: Node {
        get {
            var responseDict: Node = ["endSession" : Node(endSession)]
            
            if let speech = speech {
                responseDict["outputSpeech"] = speech.node
            }
            
            if let card = card {
                responseDict["card"] = card.node
            }
            
            if let directives = directives, directives.count > 0 {
                let directiveNodes = directives.map { $0.node }
                responseDict["directives"] = Node(directiveNodes)
            }
            
            return [
                "version" : "1.0",
                "response" : Node(responseDict),
                "sessionAttributes" : attributes ?? [:]
            ]
        }
    }
    
}
