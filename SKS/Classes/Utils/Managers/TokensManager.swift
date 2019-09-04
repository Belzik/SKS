//
//  TokensManager.swift
//  SKS
//
//  Created by Александр Катрыч on 28/08/2019.
//  Copyright © 2019 Katrych. All rights reserved.
//

import Foundation

class TokensManager {
    private init() {}
    static let shared = TokensManager()
    
    func startTimer() {
        getTokens()
        Timer.scheduledTimer(timeInterval: 60, target: self, selector: #selector(getTokens), userInfo: nil, repeats: true)
    }
    
    @objc func getTokens() {
        guard let user = UserData.loadSaved(),
               let refreshToken = user.refreshToken else { return }
        
        NetworkManager.shared.refreshToken(refreshToken: refreshToken) { response in
            if let refreshToken = response.result.value?.tokens?.refreshToken,
                let accessToken = response.result.value?.tokens?.accessToken {
                user.refreshToken = refreshToken
                user.accessToken = accessToken
            }
        }
    }
}
