//
//  LunarDayUtils.swift
//  lunar-day
//
//  Created by Lực Nguyễn 18/07/2019.
//  Copyright © 2019 Luc Nguyen All rights reserved.
//

import Foundation

class LunarDayUtils: NSObject {
  func convertSolarToLunar(_ day: Int,
                           month: Int,
                           year: Int,
                           timeZone: Int = CConstants.kVnDefaultTimeZone) -> (Int, Int, Int, Bool, Int) {
    let juliusDay = DateConverter.convertDateToJuliusDays(day, month: month, year: year)
    let k = Int(floor((Float(juliusDay) - 2415021.076998695) / 29.530588853))
    
    var monthStart = getNewMoonDay(k+1, timeZone: timeZone)
    if monthStart > juliusDay {
      monthStart = getNewMoonDay(k, timeZone: timeZone)
    }
    
    var a11 = getLunarMonth11(year, timeZone: timeZone)
    var b11 = a11
    
    var lunarYear = 0
    
    if a11 >= monthStart {
      lunarYear = year
      a11 = getLunarMonth11(year-1, timeZone: timeZone)
    } else {
      lunarYear = year+1
      b11 = getLunarMonth11(year+1, timeZone: timeZone)
    }
    
    let lunarDay = juliusDay - monthStart + 1
    let diff = Int(floor(Float(monthStart - a11) / 29))
    var lunarLeap = false
    var lunarMonth = diff + 11
    
    if b11-a11 > 365 {
      let leapMonthDiff = getLeapMonthOffset(a11, timeZone: timeZone)
      
      if diff > leapMonthDiff {
        lunarMonth = diff + 1
        
        if diff == leapMonthDiff {
          lunarLeap = true
        }
      }
    }
    
    if lunarMonth > 12 {
      lunarMonth -= 12
    }
    
    if lunarMonth >= 11 && diff < 4 {
      lunarYear -= 1
    }
    
    return (lunarDay, lunarMonth, lunarYear, lunarLeap, juliusDay)
  }
  
  func convertLunarToSolar(_ lunarDay: Int,
                           lunarMonth: Int,
                           lunarYear: Int,
                           lunarLeap: Bool = false,
                           timeZone: Int = CConstants.kVnDefaultTimeZone) -> (Int, Int, Int) {
    var a11 = 0
    var b11 = 0
    
    if lunarMonth < 11 {
      a11 = getLunarMonth11(lunarYear-1, timeZone:timeZone)
      b11 = getLunarMonth11(lunarYear, timeZone:timeZone)
    } else {
      a11 = getLunarMonth11(lunarYear, timeZone:timeZone)
      b11 = getLunarMonth11(lunarYear+1, timeZone:timeZone)
    }
    
    var off = lunarMonth - 11
    if off < 0 {
      off += 12
    }
    
    if b11 - a11 > 365 {
      let leapOff = getLeapMonthOffset(a11, timeZone:timeZone)
      
      var leapMonth = leapOff - 2;
      if leapMonth < 0 {
        leapMonth += 12
      }
      
      if lunarLeap && lunarMonth != leapMonth {
        return (0, 0, 0)
      }
      
      if lunarLeap || off >= leapOff {
        off += 1
      }
    }
    
    let k = Int(floor(0.5 + (Float(a11) - 2415021.076998695) / 29.530588853))
    let monthStart = getNewMoonDay(k+off, timeZone:timeZone)
    return DateConverter.convertJuliusDaysToDate(monthStart + lunarDay - 1)
  }
  
  fileprivate func getNewMoonDay(_ kthNewMoon: Int, timeZone: Int = CConstants.kVnDefaultTimeZone) -> Int {
    let k = Float(kthNewMoon)
    let T = k/1236.85 // Time in Julian centirues from 1900 January 0.5
    let T2 = T*T
    let T3 = T2*T
    let dr = Float(Double.pi) / 180
    
    var Jd1 = 2415020.75933 + 29.53058868*k + 0.0001178*T2 - 0.000000155*T3
    Jd1 += 0.00033*sin((166.56 + 132.87*T - 0.009173*T2)*dr) // Mean new moon
    
    let M = 359.2242 + 29.10535608*k - 0.0000333*T2 - 0.00000347*T3 // Sun's mean anomaly
    let Mpr = 306.0253 + 385.81691806*k + 0.0107306*T2 + 0.00001236*T3 // Moon's mean anomaly
    let F = 21.2964 + 390.67050646*k - 0.0016528*T2 - 0.00000239*T3 // Moon's argument of latitude
    
    var C1 = (0.1734 - 0.000393*T)*sin(M*dr) + 0.0021*sin(2*dr*M)
    C1 = C1 - 0.4068*sin(Mpr*dr) + 0.0161*sin(dr*2*Mpr)
    C1 = C1 - 0.0004*sin(dr*3*Mpr)
    C1 = C1 + 0.0104*sin(dr*2*F) - 0.0051*sin(dr*(M+Mpr))
    C1 = C1 - 0.0074*sin(dr*(M-Mpr)) + 0.0004*sin(dr*(2*F+M))
    C1 = C1 - 0.0004*sin(dr*(2*F-M)) - 0.0006*sin(dr*(2*F+Mpr))
    C1 = C1 + 0.0010*sin(dr*(2*F-Mpr)) + 0.0005*sin(dr*(2*Mpr+M))
    
    var deltaT: Float = 0
    
    if T < -11 {
      deltaT = 0.001 + 0.000839*T + 0.0002261*T2 - 0.00000845*T3 - 0.000000081*T*T3
    } else {
      deltaT = -0.000278 + 0.000265*T + 0.000262*T2
    }
    
    let JdNew = Jd1 + C1 - deltaT
    let newMoonDay = floor(JdNew + 0.5 + Float(timeZone)/24)
    
    return Int(newMoonDay)
  }
  
  fileprivate func getSunLongitude(_ juliusDays: Int, timeZone: Int = CConstants.kVnDefaultTimeZone) -> Int {
    let jdn = Float(juliusDays)
    let T = (jdn - 2451545.5 - Float(timeZone)/24) / 36525 // Time in Julian centuries from 2000-01-01 12:00:00 GMT
    let T2 = T*T
    
    let PI = Float(Double.pi)
    let dr = PI/180 // degree to radian
    let M = 357.52910 + 35999.05030*T - 0.0001559*T2 - 0.00000048*T*T2 // mean anomaly, degree
    let L0 = 280.46645 + 36000.76983*T + 0.0003032*T2 // mean longitude, degree
    
    var DL = (1.914600 - 0.004817*T - 0.000014*T2)*sin(dr*M)
    DL += (0.019993 - 0.000101*T)*sin(dr*2*M) + 0.000290*sin(dr*3*M)
    
    var L = L0 + DL // true longitude, degree
    L *= dr
    L -= PI*2*floor(L/(PI*2)) // Normalize to (0, 2*PI)
    
    return Int(floor(L / PI * 6))
  }
  
  fileprivate func getLunarMonth11(_ year: Int, timeZone: Int = CConstants.kVnDefaultTimeZone) -> Int {
    let offset = DateConverter.convertDateToJuliusDays(31, month: 12, year: year) - 2415021
    let kthNewMoon = Int(floor(Float(offset) / 29.530588853))
    var newMoonDay = getNewMoonDay(kthNewMoon, timeZone: timeZone)
    let sunLongitude = getSunLongitude(newMoonDay, timeZone: timeZone)
    
    if sunLongitude >= 9 {
      newMoonDay = getNewMoonDay(kthNewMoon-1, timeZone: timeZone)
    }
    
    return newMoonDay
  }
  
  fileprivate func getLeapMonthOffset(_ a11: Int, timeZone: Int = CConstants.kVnDefaultTimeZone) -> Int {
    let kthNewMoon = Int(floor(Float(a11) - 2415021.076998695) / 29.530588853 + 0.5)
    var lastNewMoon = 0
    var delta = 1
    var sunLongitude = getSunLongitude(getNewMoonDay(kthNewMoon+delta, timeZone: timeZone), timeZone: timeZone)
    
    repeat {
      lastNewMoon = sunLongitude
      delta += 1
      sunLongitude = getSunLongitude(getNewMoonDay(kthNewMoon+1, timeZone: timeZone), timeZone: timeZone)
    } while sunLongitude != lastNewMoon && delta < 14
    
    return delta-1
  }
}
