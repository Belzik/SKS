//
//  ReachabilityManager.swift
//  SKS
//
//  Created by Александр Катрыч on 29/06/2019.
//  Copyright © 2019 Katrych. All rights reserved.
//

import Reachability

enum ReachabilityManagerType {
    case wifi
    case cellular
    case none
}

class ReachabilityManager {
    static let sharedInstance = ReachabilityManager()
    
    private var reachability = Reachability()!
    private var reachabilityManagerType: ReachabilityManagerType = .none
    
    private init() {
        reachabilityManagerTypуChanged(reachability)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(reachabilityChanged),
                                               name: .reachabilityChanged,
                                               object: reachability)
        do {
            try reachability.startNotifier()
        } catch {}
    }
    
    @objc private func reachabilityChanged(note: NSNotification) {
        let reachability = note.object as! Reachability
        reachabilityManagerTypуChanged(reachability)
    }
    
    private func reachabilityManagerTypуChanged(_ reachability: Reachability) {
        switch reachability.connection {
        case .wifi:
            self.reachabilityManagerType = .wifi
        case .cellular:
            self.reachabilityManagerType = .cellular
        case .none:
            self.reachabilityManagerType = .none
        }
    }
}

extension ReachabilityManager {
    func isConnectedToNetwork() -> Bool {
        return reachabilityManagerType != .none
    }
}

