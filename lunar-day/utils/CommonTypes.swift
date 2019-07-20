//
//  CommonTypes.swift
//  lunar-day
//
//  Created by Lực Nguyễn 18/07/2019.
//  Copyright © 2019 Luc Nguyen All rights reserved.
//

import Foundation

struct CConstants {
  static let kTimeZones: [String: Int] = [
    "Hanoi, Vietnam": 7,
    "Shanghai, China": 8,
    "Seoul, Korea": 9,
    "Tokyo, Japan": 9
  ]
  static let kVnDefaultTimeZone: Int = kTimeZones["Hanoi, Vietnam"]!
  static let kZodiacStemSymbols: [String] = ["Giáp", "Ất", "Bính", "Đinh", "Mậu", "Kỷ", "Canh", "Tân", "Nhâm", "Quý"]
  static let kZodiacBranchSymbols: [String] = ["Tý", "Sửu", "Dần", "Mão", "Thìn", "Tỵ", "Ngọ", "Mùi", "Thân", "Dậu", "Tuất", "Hợi"]
}

enum CalendarTypesEnum {
  case gregoryCal
  case juliusCal
}

enum ZodiacStemsEnum: Int {
  case giap = 0, at, binh, dinh, mau, ky, canh, tan, nham, quy
}

enum ZodiacBranchesEnum: Int {
  case dan = 1, mao, thin, ty2, ngo, mui, than, dau, tuat, hoi, ty, suu
}
