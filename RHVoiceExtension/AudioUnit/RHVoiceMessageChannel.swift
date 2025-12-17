//
//  RHVoiceMessageChannel.swift
//  RHVoice
//
//  Created by Ihor Shevchuk on 6/28/25.
//
//  Copyright (C) 2022–2024 Ihor Shevchuk
//  Copyright (C) 2025 Non-Routine LLC
//  Contact: contact@nonroutine.com
//
//  SPDX-License-Identifier: GPL-3.0-or-later
//
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with this program.  If not, see <https://www.gnu.org/licenses/>.
//
import Foundation
import AudioToolbox

protocol RHVoiceMessageChannelDelegate: AnyObject, MessageHandlerDelegate {
    
}

class RHVoiceMessageChannel: AUMessageChannel {
    weak var delegate: RHVoiceMessageChannelDelegate?
    init(delegate: RHVoiceMessageChannelDelegate? = nil) {
        self.delegate = delegate
    }
    
    func callAudioUnit(_ message: [AnyHashable: Any]) -> [AnyHashable: Any] {
        guard let delegate else {
            Log.error("No delegate. Message won't be processed")
            return [:]
        }
        
        guard let messageJson = message[Message.key] as? String else {
            Log.error("No message json")
            return [:]
        }
        
        guard let jsonData = messageJson.data(using: .utf8) else {
            Log.error("Can't convert message json to data")
            return [:]
        }
        
        let jsonDecoder = JSONDecoder()
        guard let message = try? jsonDecoder.decode(Message.self, from: jsonData) else {
            Log.error("Failed to decode message json to Message.")
            return [:]
        }
        
        guard let object = message.object else {
            Log.error("No object in message")
            return [:]
        }

        let messageResponse = MessageResponse(type: message.type,
                                              json: object.handle(delegate: delegate))
        
        let jsonEncoder = JSONEncoder()
        guard let data = try? jsonEncoder.encode(messageResponse) else {
            Log.error("Failed to encode response message to Data.")
            return [:]
        }
        
        guard let jsonString = String(data: data, encoding: .utf8) else {
            Log.error( "Failed to convert Data to String. Can't have nil string response")
            return [:]
        }
        return [MessageResponse.key: jsonString]
    }
    
    var callHostBlock: CallHostBlock?
}
