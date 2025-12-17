//
//  BaseHostModel.swift
//  RHVoiceApp
//
//  Created by Ihor Shevchuk on 07.06.2025.
//
//  Copyright (C) 2025  Non-Routine LLC (contact@nonroutine.com)

import Foundation
import Combine

class BaseHostModel: ObservableObject {
    
    func publishUpdate() {
        updateObjectInMainThread()
    }
    
    private func updateObjectInMainThread() {
        if Thread.isMainThread {
            objectWillChange.send()
            return
        }

        DispatchQueue.main.async { [weak self] in
            self?.updateObjectInMainThread()
        }
    }
}
