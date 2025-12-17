//
//  ReachabilityManager.swift
//  RHVoiceApp
//
//  Created by Ihor Shevchuk on 03.01.2023.
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

import Combine
import Network

enum NetworkType {
    case wifi
    case cellular
    case loopBack
    case wired
    case other
    
    var isExpensive: Bool {
        return self == .cellular
    }
}

class ReachabilityManager: ObservableObject, @unchecked Sendable {
    
    struct NetworkInfo {
        var isNetworkAvailable: Bool?
        var isExpensive: Bool?
        var isConstrained: Bool?
        var networkType: NetworkType?
        
        var canBeUsedForUpdates: Bool {
            return isExpensive == false && isConstrained == false && networkType?.isExpensive == false
        }
    }
    
    @Published var networkInfo: NetworkInfo?
    
    private let monitor = NWPathMonitor()
    private let queue = {
        return DispatchQueue(label: "\(ReachabilityManager.self)Queue", qos: .userInitiated)
    }()
    private var observation: AnyCancellable?
    private var continuation: CheckedContinuation<Void, Never>?
    private var resumeContinuationLock = NSLock()
    
    init() {
        setUp()
    }

    deinit {
        monitor.cancel()
    }
    
    func getInfo() async -> NetworkInfo? {
        
        if let networkInfo {
            return networkInfo
        }
        
        var result: NetworkInfo?

        await withCheckedContinuation { [weak self] continuation in
            guard let self else {
                return
            }
            self.continuation = continuation
            self.observation = self.$networkInfo
                .receive(on: self.queue)
                .sink { [weak self] info in
                if let info {
                    result = info
                    self?.resumeAndRemoveContinuation()
                }
            }
            
            self.queue.asyncAfter(deadline: .now() + 1) { [weak self] in
                self?.resumeAndRemoveContinuation()
            }
        }
        self.observation = nil
        
        return result
    }
}

private extension ReachabilityManager {
    
    func setUp() {
        
        monitor.pathUpdateHandler = { [weak self] path in
            self?.networkInfo = NetworkInfo(isNetworkAvailable: path.isNetworkAvailable,
                                            isExpensive: path.isExpensive,
                                            isConstrained: path.isConstrained,
                                            networkType: path.networkType)
        }

        monitor.start(queue: queue)
    }
    
    private func resumeAndRemoveContinuation() {
        resumeContinuationLock.lock()
        defer {
            resumeContinuationLock.unlock()
        }
        continuation?.resume()
        continuation = nil
    }
}

fileprivate extension NWPath {
    var networkType: NetworkType? {
        
        if usesInterfaceType(.wifi) {
            return .wifi
        }
        
        if usesInterfaceType(.cellular) {
            return .cellular
        }
        
        if usesInterfaceType(.loopback) {
            return .loopBack
        }
        
        if usesInterfaceType(.wiredEthernet) {
            return .wired
        }
        
        if usesInterfaceType(.other) {
            return .other
        }
        
        Log.error("Network path(\(self)) uses some unknown interface type. Returning nil.")
        return nil
    }
    
    var isNetworkAvailable: Bool {
        switch status {
        case .satisfied:
            Log.debug("satisfied")
            return true
        case .unsatisfied, .requiresConnection:
            return false
        @unknown default:
            return false
        }
    }
}
