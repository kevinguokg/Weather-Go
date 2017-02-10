//
//  ForecastWeather.swift
//  Weather Go
//
//  Created by Kevin Guo on 2017-02-09.
//  Copyright © 2017 Kevin Guo. All rights reserved.
//

import Foundation

class ForecastWeather: Weather {
    var time: Date?
    
    override init() {
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.time = aDecoder.decodeObject(forKey: "time") as? Date
    }
    
    override func encode(with aCoder: NSCoder) {
        super.encode(with: aCoder)
        aCoder.encode(self.time, forKey: "time")
    }
}
