//
//  PersistanceManager.swift
//  Whats_that_McX
//
//  Created by 夏蓦辰 on 2017/11/27.
//  Copyright © 2017年 GW Mobile 17. All rights reserved.
//

import Foundation

class PersistanceManager {

    let favoritesKey = "favorites"

    func fetchFavorites() -> [Favorite] {
        let userDefaults = UserDefaults.standard
        
        let data = userDefaults.object(forKey: favoritesKey) as? Data
        
        if let data = data {
            //data is not nil
            return NSKeyedUnarchiver.unarchiveObject(with: data) as? [Favorite] ?? [Favorite]()
        } else {
            //data is nil
            return [Favorite]()
        }
    }

    func saveFavorite(_ favorite: Favorite) {
        let userDefaults = UserDefaults.standard
        
        var favorites = fetchFavorites()
        favorites.append(favorite)
        
        let data = NSKeyedArchiver.archivedData(withRootObject: favorites)
        
        userDefaults.set(data, forKey: favoritesKey)
    }
}
