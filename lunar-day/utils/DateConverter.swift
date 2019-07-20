//
//  DateConverter.swift
//  lunar-day
//
//  Created by Lực Nguyễn 18/07/2019.
//  Copyright © 2019 Luc Nguyen All rights reserved.
//

import Foundation

class DateConverter: NSObject {
  class func convertDateToJuliusDays(_ day: Int,
                                     month: Int,
                                     year: Int,
                                     calendarType: CalendarTypesEnum = .gregoryCal) -> Int {
    let convertedMonth = (14 - month) / 12
    let convertedYear = year + 4800 - convertedMonth
    let convertedDay = month + 12*convertedMonth - 3
    
    var juliusDay = -1
    
    if calendarType == .gregoryCal {
      juliusDay = day + (153*convertedDay+2)/5 + 365*convertedYear + convertedYear/4 - convertedYear/100 + convertedYear/400 - 32045
    } else if calendarType == .juliusCal {
      juliusDay = day + (153*convertedDay+2)/5 + 365*convertedYear + convertedYear/4 - 32083
    }
    
    return juliusDay
  }
  
  class func convertJuliusDaysToDate(_ juliusDays: Int, calendarType: CalendarTypesEnum = .gregoryCal) -> (Int, Int, Int) {
    var tempDay = 0
    var tempMonth = 0
    var tempYear = 0
    
    if calendarType == .gregoryCal && juliusDays > 2299160 {
      tempDay = juliusDays + 32044
      tempMonth = (4*tempDay+3) / 146097
      tempYear = tempDay - (tempMonth*146097)/4
    } else if calendarType == .juliusCal {
      tempMonth = 0
      tempYear = juliusDays + 32082
    }
    
    let convertedYear = (4*tempYear+3) / 1461
    let convertedDay = tempYear - (1461*convertedYear)/4
    let convertedMonth = (5*convertedDay+2) / 153
    
    let resultDay = convertedDay - (153*convertedMonth+2)/5 + 1
    let resultMonth = convertedMonth + 3 - 12*(convertedMonth/10)
    let resultYear = tempMonth*100 + convertedYear - 4800 + convertedMonth/10
    
    return (resultDay, resultMonth, resultYear)
  }
  
  class func zodiacStemBranchForJuliusDay(_ juliusDay: Int) -> (String, String) {
    let stem = CConstants.kZodiacStemSymbols[(juliusDay+9) % 10]
    let branch = CConstants.kZodiacBranchSymbols[(juliusDay+1) % 12]
    
    return (stem, branch)
  }
  
  class func zodiacStemBranchForLunarMonth(_ lunarMonth: Int, lunarYear: Int) -> (String, String) {
    let convertedFactor = lunarYear*12 + lunarMonth + 3
    let stem = CConstants.kZodiacStemSymbols[convertedFactor % 10]
    var branch = ""
    
    // Any better solution(s)?
    switch lunarMonth {
    case 11:
      branch = "Tý"
    case 12:
      branch = "Sửu"
    default:
      branch = CConstants.kZodiacBranchSymbols[lunarMonth + 1]
    }
    
    return (stem, branch)
  }
  
  class func zodiacStemBranchForLunarYear(_ lunarYear: Int) -> (String, String) {
    let stem = CConstants.kZodiacStemSymbols[(lunarYear+6) % 10]
    let branch = CConstants.kZodiacBranchSymbols[(lunarYear+8) % 12]
    
    return (stem, branch)
  }
}
