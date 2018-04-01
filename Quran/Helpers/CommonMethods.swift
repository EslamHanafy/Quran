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

//MARK: - Alerts
// display alert
public func displayAlert(_ messeg:String,forController controller:UIViewController){
    let alert = UIAlertController(title: "", message: messeg, preferredStyle: UIAlertControllerStyle.alert)
    alert.addAction(UIAlertAction(title: "حسنا", style: UIAlertActionStyle.default, handler: nil))
    DispatchQueue.main.async(execute: {
        controller.present(alert, animated: true, completion: nil)
    })
}

//display alert with timer to hide
public func displayAlertWithTimer(_ messeg:String,forController controller:UIViewController,timeInSeconds time:Double){
    let alert = UIAlertController(title: "", message: messeg, preferredStyle: UIAlertControllerStyle.alert)
    DispatchQueue.main.async(execute: {
        controller.present(alert, animated: true, completion: nil)
    })
    
    delay(time, closure: {
        mainQueue {
            alert.dismiss(animated: true, completion: nil)
        }
    })
}

extension UIView {
    
    public enum PeakSide: Int {
        case Top
        case Left
        case Right
        case Bottom
    }
    
    public func addPikeOnView( side: PeakSide, size: CGFloat = 10.0) {
        self.layoutIfNeeded()
        let peakLayer = CAShapeLayer()
        var path: CGPath?
        switch side {
        case .Top:
            path = self.makePeakPathWithRect(rect: self.bounds, topSize: size, rightSize: 0.0, bottomSize: 0.0, leftSize: 0.0)
        case .Left:
            path = self.makePeakPathWithRect(rect: self.bounds, topSize: 0.0, rightSize: 0.0, bottomSize: 0.0, leftSize: size)
        case .Right:
            path = self.makePeakPathWithRect(rect: self.bounds, topSize: 0.0, rightSize: size, bottomSize: 0.0, leftSize: 0.0)
        case .Bottom:
            path = self.makePeakPathWithRect(rect: self.bounds, topSize: 0.0, rightSize: 0.0, bottomSize: size, leftSize: 0.0)
        }
        peakLayer.path = path
        let color = (self.backgroundColor?.cgColor)
        peakLayer.fillColor = color
        peakLayer.strokeColor = color
        peakLayer.lineWidth = 1
        peakLayer.position = CGPoint.zero
        self.layer.insertSublayer(peakLayer, at: 0)
    }
    
    
    func makePeakPathWithRect(rect: CGRect, topSize ts: CGFloat, rightSize rs: CGFloat, bottomSize bs: CGFloat, leftSize ls: CGFloat) -> CGPath {
        //                      P3
        //                    /    \
        //      P1 -------- P2     P4 -------- P5
        //      |                               |
        //      |                               |
        //      P16                            P6
        //     /                                 \
        //  P15                                   P7
        //     \                                 /
        //      P14                            P8
        //      |                               |
        //      |                               |
        //      P13 ------ P12    P10 -------- P9
        //                    \   /
        //                     P11
        
        let centerX = rect.width / 2
        let centerY = rect.height / 2
        var h: CGFloat = 0
        let path = CGMutablePath()
        var points: [CGPoint] = []
        // P1
        points.append(CGPoint(x:rect.origin.x,y: rect.origin.y))
        // Points for top side
        if ts > 0 {
            h = ts * sqrt(3.0) / 2
            let x = rect.origin.x + centerX
            let y = rect.origin.y
            points.append(CGPoint(x:x - ts,y: y))
            points.append(CGPoint(x:x,y: y - h))
            points.append(CGPoint(x:x + ts,y: y))
        }
        
        // P5
        points.append(CGPoint(x:rect.origin.x + rect.width,y: rect.origin.y))
        // Points for right side
        if rs > 0 {
            h = rs * sqrt(3.0) / 2
            let x = rect.origin.x + rect.width
            let y = rect.origin.y + centerY
            points.append(CGPoint(x:x,y: y - rs))
            points.append(CGPoint(x:x + h,y: y))
            points.append(CGPoint(x:x,y: y + rs))
        }
        
        // P9
        points.append(CGPoint(x:rect.origin.x + rect.width,y: rect.origin.y + rect.height))
        // Point for bottom side
        if bs > 0 {
            h = bs * sqrt(3.0) / 2
            let x = rect.origin.x + centerX
            let y = rect.origin.y + rect.height
            points.append(CGPoint(x:x + bs,y: y))
            points.append(CGPoint(x:x,y: y + h))
            points.append(CGPoint(x:x - bs,y: y))
        }
        
        // P13
        points.append(CGPoint(x:rect.origin.x, y: rect.origin.y + rect.height))
        // Point for left sidey:
        if ls > 0 {
            h = ls * sqrt(3.0) / 2
            let x = rect.origin.x
            let y = rect.origin.y + centerY
            points.append(CGPoint(x:x,y: y + ls))
            points.append(CGPoint(x:x - h,y: y))
            points.append(CGPoint(x:x,y: y - ls))
        }
        
        let startPoint = points.removeFirst()
        self.startPath(path: path, onPoint: startPoint)
        for point in points {
            self.addPoint(point: point, toPath: path)
        }
        self.addPoint(point: startPoint, toPath: path)
        return path
    }
    
    private func startPath( path: CGMutablePath, onPoint point: CGPoint) {
        path.move(to: CGPoint(x: point.x, y: point.y))
    }
    
    private func addPoint(point: CGPoint, toPath path: CGMutablePath) {
        path.addLine(to: CGPoint(x: point.x, y: point.y))
    }
}
