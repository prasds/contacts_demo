//
//  ViewController.swift
//  contacts_tutorial
//
//  Created by Prashanth Ds on 2/4/15.
//  Copyright (c) 2015 Prashanth Ds. All rights reserved.
//

import UIKit
import AddressBookUI

class ViewController: UIViewController, ABPeoplePickerNavigationControllerDelegate {
    
    // ------ The below function executes everytime the button is pressed
    
    @IBAction func showPicker(sender: AnyObject) {
        
        getContactNames()
        
    }
    
// ----- Creates the address book everytime the app loads
    
    var adbk : ABAddressBook!
    
    func createAddressBook() -> Bool {
        if self.adbk != nil {
            return true
        }
        var err : Unmanaged<CFError>? = nil
        let adbk : ABAddressBook? = ABAddressBookCreateWithOptions(nil, &err).takeRetainedValue()
        if adbk == nil {
            println(err)
            self.adbk = nil
            return false
        }
        self.adbk = adbk
        return true
    }
    
 // ---- To get the permission from the user for accessing the addressbook database
    
    func determineStatus() -> Bool {
        let status = ABAddressBookGetAuthorizationStatus()
        switch status {
        case .Authorized:
            return self.createAddressBook()
        case .NotDetermined:
            var ok = false
            ABAddressBookRequestAccessWithCompletion(nil) {
                (granted:Bool, err:CFError!) in
                dispatch_async(dispatch_get_main_queue()) {
                    if granted {
                        ok = self.createAddressBook()
                    }
                }
            }
            if ok == true {
                return true
            }
            self.adbk = nil
            return false
        case .Restricted:
            self.adbk = nil
            return false
        case .Denied:
            self.adbk = nil
            return false
        }
    }
    
    
    //---- This function is used to extract the created address book of the information we need e.g: name, phone number, email, etc..
    //---- This function is not complete as it extracts only name and phone numbers for now.
    
    func getContactNames() {
        if !self.determineStatus() {
            println("not authorized")
            return
        }
        let people = ABAddressBookCopyArrayOfAllPeople(adbk).takeRetainedValue() as NSArray as [ABRecord]
        // println(people.count)
        
        for person in people {
            
            // ------------------- exract full name ----------------------
            println("Name : ", ABRecordCopyCompositeName(person).takeRetainedValue())
            
            // ------------------- exract Nick Name ----------------------   
        
           // let nickName = ABRecordCopyValue(person, kABPersonNicknameProperty).takeUnretainedValue() as NSString as String
            
            //let vv = ABRecordCopyValue(person, kABPersonAddressStateKey)?.takeRetainedValue as String?
            
            // ------------------- exract all the phone numbers ----------------------
            
            let phones = ABRecordCopyValue(person, kABPersonPhoneProperty).takeUnretainedValue() as NSObject
            
            let countOfPhones = ABMultiValueGetCount(phones)
            
            for index in 0..<countOfPhones{
                
                let phLabel = ABMultiValueCopyLabelAtIndex(phones, index).takeUnretainedValue() as NSObject as NSString
                let phNumber = ABMultiValueCopyValueAtIndex(phones, index).takeUnretainedValue() as NSObject as NSString
                
                println("\(phLabel) : \(phNumber)")
            }
            


        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        
        
        
    }
    
    override func viewDidAppear(animated: Bool) {
        
        createAddressBook()
        determineStatus()

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}

