//
//  ViewController.swift
//  RestaurantSearcher
//
//  Created by 渡邊輝夢 on 2020/03/13.
//  Copyright © 2020 Terumu Watanabe. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import CoreLocation

enum Requirement: Int {
    case on = 1
    case off = 0
}

class ViewController: UIViewController, CLLocationManagerDelegate, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate {
    
    
    
    @IBOutlet weak var rangePickerView: UIPickerView!
    
    @IBOutlet weak var freeWordTextField: UITextField!
    
    @IBOutlet weak var searchButton: UIButton!
    
    @IBOutlet weak var wifiAvaileButton: UIButton!
    @IBOutlet weak var powerAvaileButton: UIButton!
    @IBOutlet weak var nonsmokingButton: UIButton!
    @IBOutlet weak var cardAvaileButton: UIButton!
    @IBOutlet weak var takeoutAvaileButton: UIButton!
    @IBOutlet weak var parkingAvaileButton: UIButton!
    @IBOutlet weak var eMoneyAvaileButton: UIButton!
    var buttonCorrection: [UIButton] = []
    
    var isWifiAvaile: Requirement = .off
    var isPowerAvaile: Requirement = .off
    var isNonsmoking : Requirement = .off
    var isCardAvaile: Requirement = .off
    var isTakeoutAvaile: Requirement = .off
    var isParkingAvaile: Requirement = .off
    var isEMoneyAvaile: Requirement = .off
    
    var locationManager: CLLocationManager!
    var latitude: CLLocationDegrees!
    var longitude: CLLocationDegrees!
    
    let apiKey = "7c26053265ff1eabac65817bfc40546d"
    let baseUrl = "https://api.gnavi.co.jp/RestSearchAPI/v3/"
    var url = ""
    var encodedUrl: String {
        get {
            return url.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!
        }
    }
    
    var restaurans: [Restaurant] = []
    let rangeStrings: [String] = ["300m", "500m", "1000m", "2000m", "3000m"]
    var selectedRange = 2
    
    var preSelectedLb: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        buttonCorrection = [wifiAvaileButton, powerAvaileButton, nonsmokingButton, cardAvaileButton, takeoutAvaileButton, parkingAvaileButton, eMoneyAvaileButton]
        
        searchButton.layer.cornerRadius = 10
        
        freeWordTextField.delegate = self
        freeWordTextField.placeholder = "業態、メニューなど"
        self.hideKeyboardWhenTappedAround()
        
        for button in buttonCorrection { makeButtonOff(button) }
        
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.tintColor = UIColor.white
        self.navigationItem.backBarButtonItem = UIBarButtonItem(
            title: "検索画面",
            style: .plain,
            target: nil,
            action: nil)
        
        rangePickerView.delegate = self
        rangePickerView.dataSource = self
        rangePickerView.selectRow(1, inComponent: 0, animated: true)
        
        setupLocationManager()
    }
    
    
    
    @IBAction func searchButtonTapped(_ sender: Any) {
        
        let status = CLLocationManager.authorizationStatus()
        if status == .denied {
            showAlert()
        } else if status == .authorizedWhenInUse {
            locationManager.delegate = self
            locationManager.distanceFilter = 10.0
            locationManager.startUpdatingLocation()
        }
        
        
        restaurans = []
        print("range: \(rangeStrings[selectedRange - 1])")
        guard let lat = latitude, let lon = longitude else { return  }
        guard let text = freeWordTextField.text else { return }
        
        url = "\(baseUrl)?keyid=\(apiKey)&latitude=\(lat)&longitude=\(lon)&range=\(selectedRange)&hit_per_page=20&freeword=\(text)&wifi=\(isWifiAvaile.rawValue)&outret=\(isPowerAvaile.rawValue)&no_smoking=\(isNonsmoking.rawValue)&card=\(isCardAvaile.rawValue)&takeout=\(isTakeoutAvaile.rawValue)&parking=\(isParkingAvaile.rawValue)&e_money=\(isEMoneyAvaile.rawValue)"
        print(url)
//        let takasaki = "https://api.gnavi.co.jp/RestSearchAPI/v3/?keyid=7c26053265ff1eabac65817bfc40546d&latitude=36.343267&longitude=138.993157"
        
        self.performSegue(withIdentifier: "toResultVC", sender: nil)
    }
    
   
    
    @IBAction func wifiAvaileButtonTapped(_ sender: UIButton) {
        
        swichButton(button: wifiAvaileButton, requirement: &isWifiAvaile)
    }
    
    @IBAction func powerAvaileButtonTapped(_ sender: Any) {
        
        swichButton(button: powerAvaileButton, requirement: &isPowerAvaile)
    }
    
    @IBAction func nonsmokingButtonTapped(_ sender: Any) {
        
        swichButton(button: nonsmokingButton, requirement: &isNonsmoking)
    }
    
    @IBAction func cardAvaileButtonTapped(_ sender: Any) {
        
        swichButton(button: cardAvaileButton, requirement: &isCardAvaile)
    }
    
    @IBAction func takeoutAvaileButtonTapped(_ sender: Any) {
        
        swichButton(button: takeoutAvaileButton, requirement: &isTakeoutAvaile)
    }
    
    @IBAction func parkingAvaileButtonTapped(_ sender: Any) {
        
        swichButton(button: parkingAvaileButton, requirement: &isParkingAvaile)
    }
    
    @IBAction func eMoneyAvaileButtonTapped(_ sender: Any) {

        swichButton(button: eMoneyAvaileButton, requirement: &isEMoneyAvaile)
    }
    
    
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView,
                    numberOfRowsInComponent component: Int) -> Int {
        return self.rangeStrings.count
    }
    
    func pickerView(_ pickerView: UIPickerView,
                    titleForRow row: Int,
                    forComponent component: Int) -> String? {
        return self.rangeStrings[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        self.selectedRange = row + 1
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
        return true
    }
    

    func setupLocationManager() {
        
        locationManager = CLLocationManager()
        guard let locationManager = locationManager else { return }
        
        locationManager.requestWhenInUseAuthorization()
        let status = CLLocationManager.authorizationStatus()
        if status == .authorizedWhenInUse {
            
            locationManager.delegate = self
            locationManager.distanceFilter = 10.0
            locationManager.pausesLocationUpdatesAutomatically = true
            locationManager.startUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager,
                         didUpdateLocations locations: [CLLocation]) {
        
        let location = locations.first
        latitude = location?.coordinate.latitude
        longitude = location?.coordinate.longitude
        
        guard let lat = latitude, let lon = longitude else { return }
        print("latitude: \(lat)")
        print("longitude: \(lon)")
    }
    
    
    
    override func prepare(for segue: UIStoryboardSegue,
                          sender: Any?) {
        
        if segue.identifier == "toResultVC" {
            let nextVC = segue.destination as! ResultViewController
            nextVC.url = self.encodedUrl
            nextVC.range = rangeStrings[selectedRange - 1]
            nextVC.freeWord = freeWordTextField.text!
        }
    }
    
    
    
    func swichButton(button: UIButton, requirement: inout Requirement) {
        
        if requirement == .off {
            makeButtonOn(button)
            requirement = .on
        } else {
            makeButtonOff(button)
            requirement = .off
        }
    }
    
    func makeButtonOff(_ button: UIButton) {
        
        button.backgroundColor = UIColor.white
        button.layer.borderWidth = 0.5
        button.layer.borderColor = UIColor.orange.cgColor
        button.layer.cornerRadius = button.frame.size.height / 2
        button.setTitleColor(UIColor.orange, for: UIControl.State.normal)
    }
    
    func makeButtonOn(_ button: UIButton) {
        
        button.backgroundColor = UIColor.orange
        button.layer.cornerRadius = button.frame.size.height / 2
        button.setTitleColor(UIColor.white, for: UIControl.State.normal)
    }
    
    
    func showAlert() {
        
        let title = "位置情報の使用がか許可されていません"
        let message = "設定アプリの「プライバシー > 位置情報サービス」から変更してください。"
        let alert = UIAlertController(
            title: title,
            message: message,
            preferredStyle: UIAlertController.Style.alert)
        
        let defaultAction = UIAlertAction(
            title: "OK",
            style: UIAlertAction.Style.default,
            handler: nil)
        
        alert.addAction(defaultAction)
        
        present(alert, animated: true, completion: nil)
    }
    
}



extension UIViewController {
    
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(
            target: self,
            action: #selector(UIViewController.hideKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }

    @objc func hideKeyboard() {
        view.endEditing(true)
    }
    
}

