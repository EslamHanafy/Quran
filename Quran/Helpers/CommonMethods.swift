//
//  CommonMethods.swift
//  Quran
//
//  Created by Eslam Hanafy on 3/21/18.
//  Copyright © 2018 magdsoft. All rights reserved.
//

import UIKit


public var screenWidth:CGFloat { get { return UIScreen.main.bounds.size.width } }
public var screenHeight:CGFloat { get { return UIScreen.main.bounds.size.height } }
public var isIpadScreen: Bool { get { return UIScreen.main.traitCollection.horizontalSizeClass == .regular } }



func getValidatedNumber(fromInt number: Int) -> String {
    let number = NSNumber(value: number)
    let format = NumberFormatter()
    format.locale = Locale(identifier: "ar")
    let faNumber = format.string(from: number)
    
    return faNumber!
}


//MARK: - active controller
// Returns the most recently presented UIViewController (visible)
public func getCurrentViewController() -> UIViewController? {
    
    // we must get the root UIViewController and iterate through presented views
    if let rootController = UIApplication.shared.keyWindow?.rootViewController {
        
        var currentController: UIViewController! = rootController
        
        // Each ViewController keeps track of the view it has presented, so we
        // can move from the head to the tail, which will always be the current view
        while( currentController.presentedViewController != nil ) {
            
            currentController = currentController.presentedViewController
        }
        return currentController
    }
    
    return nil
}


func goToView(withId:String, andStoryboard story:String = "Main", fromController controller:UIViewController? = nil) {
    let board = UIStoryboard(name: story, bundle: nil)
    let control = controller ?? getCurrentViewController() ?? UIViewController()
    control.present(board.instantiateViewController(withIdentifier: withId), animated: true, completion: nil)
}

/// go to view controller and make it the root view
///
/// - Parameter withId: the detination view controller id
func pushToView(withId:String){
    let rootviewcontroller: UIWindow = ((UIApplication.shared.delegate?.window)!)!
    let storyboard = UIStoryboard(name: "Main", bundle: nil)
    rootviewcontroller.rootViewController = storyboard.instantiateViewController(withIdentifier: withId)
    let mainwindow = (UIApplication.shared.delegate?.window!)!
    UIView.transition(with: mainwindow, duration: 0.5, options: [.transitionFlipFromLeft], animations: nil, completion: nil)
}


//MARK: - dispatch queues
//delay to time
public func delay(_ delay: Double, closure: @escaping ()->()) {
    DispatchQueue.main.asyncAfter(
        deadline: DispatchTime.now() + Double(Int64(delay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: closure)
}

public func mainQueue(_ closure: @escaping ()->()){
    DispatchQueue.main.async(execute: closure)
}

public func backgroundQueue(_ closure: @escaping ()->()){
    DispatchQueue.global(qos: .background).async {
        closure()
    }
}
