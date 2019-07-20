//
//  ViewController.swift
//  lunar-day
//
//  Created by Lực Nguyễn 18/07/2019.
//  Copyright © 2019 Luc Nguyen All rights reserved.
//

import UIKit

class MainViewController: UIViewController {
  @IBOutlet weak var _pkgDatePicker: UIDatePicker!
  @IBOutlet weak var _swtConvertDirection: UISwitch!
  @IBOutlet weak var _lblSolarToLunar: UILabel!
  @IBOutlet weak var _lblLunarToSolar: UILabel!
  @IBOutlet weak var _lblResultDayNumber: UILabel!
  @IBOutlet weak var _lblResultMonthNumber: UILabel!
  @IBOutlet weak var _lblResultYearNumber: UILabel!
  @IBOutlet weak var _vResultLunarZodiacNames: UIView!
  @IBOutlet weak var _lblResultDayZodiacName: UILabel!
  @IBOutlet weak var _lblResultMonthZodiacName: UILabel!
  @IBOutlet weak var _lblResultYearZodiacName: UILabel!
  
  let _lunarDayUtils = LunarDayUtils()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.navigationController?.navigationBar.titleTextAttributes = [
        NSAttributedString.Key.font : UIFont(name: "Roboto-Medium", size: 17)!
    ]
    
    convertDays()
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }
  
  @IBAction func pkgDatePickerValueChanged(_ sender: UIDatePicker) {
    convertDays()
  }
  
  @IBAction func swtConvertDirectionValueChanged(_ sender: UISwitch) {
    _vResultLunarZodiacNames.isHidden = !_swtConvertDirection.isOn
    convertDays()
    
    if _swtConvertDirection.isOn {
      _lblSolarToLunar.font = UIFont(name: "Roboto-Medium", size: 17)
      _lblLunarToSolar.font = UIFont(name: "Roboto-Light", size: 17)
    } else {
      _lblSolarToLunar.font = UIFont(name: "Roboto-Light", size: 17)
      _lblLunarToSolar.font = UIFont(name: "Roboto-Medium", size: 17)
    }
  }
  
  func convertDays() {
    _swtConvertDirection.isOn ? convertSolarToLunar() : convertLunarToSolar()
  }
  
  fileprivate func convertSolarToLunar() -> Void {
    let (day, month, year) = getDayMonthYearFromDatePicker()
    
    let (lunarDay, lunarMonth, lunarYear, lunarLeap, juliusDay) =
      _lunarDayUtils.convertSolarToLunar(day, month: month, year: year)
    
    _lblResultDayNumber.text = String(lunarDay)
    _lblResultMonthNumber.text = String(lunarMonth) + (lunarLeap ? "+" : "")
    _lblResultYearNumber.text = String(lunarYear)
    
    var (stem, branch) = DateConverter.zodiacStemBranchForJuliusDay(juliusDay)
    _lblResultDayZodiacName.text = "\(stem) \(branch)"
    
    (stem, branch) = DateConverter.zodiacStemBranchForLunarMonth(lunarMonth, lunarYear: lunarYear)
    _lblResultMonthZodiacName.text = "\(stem) \(branch)"
    
    (stem, branch) = DateConverter.zodiacStemBranchForLunarYear(lunarYear)
    _lblResultYearZodiacName.text = "\(stem) \(branch)"
  }
  
  fileprivate func convertLunarToSolar() -> Void {
    let (day, month, year) = getDayMonthYearFromDatePicker()
    let (solarDay, solarMonth, solarYear) = _lunarDayUtils.convertLunarToSolar(day, lunarMonth: month, lunarYear: year)

//    _lblResultDayNumber.text = String(solarDay)
//    _lblResultMonthNumber.text = String(solarMonth)
//    _lblResultYearNumber.text = String(solarYear)

    let pairs: [UILabel: Int] = [
      _lblResultDayNumber: solarDay,
      _lblResultMonthNumber: solarMonth,
      _lblResultYearNumber: solarYear
    ]

    for (label, value) in pairs {
      label.text = String(value)
    }
  }
  
  fileprivate func getDayMonthYearFromDatePicker() -> (Int, Int, Int) {
    let components = (Calendar.current as NSCalendar).components([.day, .month, .year], from: _pkgDatePicker.date)
    return (components.day!, components.month!, components.year!)
  }
}
