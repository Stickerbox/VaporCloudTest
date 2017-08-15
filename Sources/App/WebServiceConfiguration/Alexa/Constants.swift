//
//  Constants.swift
//  AlexaSkillExample
//
//  Created by Jordan.Dixon on 14/08/2017.
//

import Vapor
import Foundation

public enum AlexaError: Error {
    case wrongApplicationId
    case invalidRequest
}

enum AlexaRequestType {
    case launch
    case intent
    case sessionEnded
    case audio(AudioPlayerRequestType)
    case playback(PlaybackRequestType)
    
    init?(string: String) {
        let components = string.components(separatedBy: ".")
        guard let component = components.first else { return nil }
        
        switch component {
        case "LaunchRequest": self = .launch
        case "IntentRequest": self = .intent
        case "SessionEndedRequest": self = .sessionEnded
            
        case "AudioPlayer":
            guard let audioComponent = components[safe: 1],
                let apType = AudioPlayerRequestType(string: audioComponent)
                else { return nil }
            self = .audio(apType)
            
        case "PlaybackController" :
            guard let playbackComponent = components[safe: 1],
                let pcType = PlaybackRequestType(string: playbackComponent)
                else { return nil }
            self = .playback(pcType)
            
        default: return nil
        }
    }
}

enum AudioPlayerRequestType {
    case started
    case finished
    case stopped
    case nearlyFinished
    case failed
    
    init?(string: String) {
        switch string {
        case "PlaybackStarted" : self = .started
        case "PlaybackFinished" : self = .finished
        case "PlaybackStopped" : self = .stopped
        case "PlaybackNearlyFinished" : self = .finished
        case "PlaybackFailed" : self = .failed
        default : return nil
        }
    }
    
}

enum PlaybackRequestType {
    case next
    case pause
    case play
    case previous
    
    init?(string: String) {
        switch string {
        case "NextCommandIssued" : self = .next
        case "PauseCommandIssued" : self = .pause
        case "PlayCommandIssued" : self = .play
        case "PreviousCommandIssued" : self = .previous
        default : return nil
        }
    }
    
}

enum AlexaAudioActivity {
    case idle, paused, playing, bufferUnderrun, finished, stopped
    
    init?(string: String) {
        switch string {
        case "IDLE" : self = .idle
        case "PAUSED" : self = .paused
        case "PLAYING" : self = .playing
        case "BUFFER_UNDERRUN" : self = .bufferUnderrun
        case "FINISHED" : self = .finished
        case "STOPPED" : self = .stopped
        default : return nil
        }
    }
}
