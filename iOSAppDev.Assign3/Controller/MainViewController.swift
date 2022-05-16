//
//  MainViewController.swift
//  iOSAppDev.Assign3
//
//  Created by John Balla on 3/5/2022.
//

import UIKit

class MainViewController: UIViewController {

    @IBOutlet weak var view1: UIView!
    @IBOutlet weak var view2: UIView!
    @IBOutlet weak var label1: UILabel!
    @IBOutlet weak var label2: UILabel!
    
    var displayString: String?
    var quotes = ["Bite-sized pasta", "Sushi", "Tapas", "Risotto", "Quesadilla", "Oyesters"]
    
    var whichQuotestoChoose = 0
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        let swipeLeft = UISwipeGestureRecognizer (target: self, action: #selector(ViewController.viewSwipped(_:)))
        swipeLeft.direction = UISwipeGestureRecognizerDirection.Left
        view1.addGestureRecognizer(swipeLeft)
        
        let swipeLeft1 = UISwipeGestureRecognizer(target: self, action: #selector(ViewCOntroller.viewSwipped(_:)))
        swipeLeft1.direction = UISwipeGestureRecognizerDirection.Left
        view2.addGestureRecognizer(swipeLeft1)
    }

    func viewSwipped(gesture: UIGestureRecognizer) {
        self.chooseAQuote()
        
        if let swippedView = gesture.view {
            //swippedView.slideInFromright()
            if swippedView.tag == 1 {
                label1.text = displayString
            } else {
                label2.text = displayString
    
            }
        }
    }


    func chooseAQuote() {
        displayString = quotes[whichQuotestoChoose]
        whichQuotestoChoose = Int(arc4random_uniform (84))
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        //Dispose of any resources that can be recreated
    }

}

extension UIView {
    func leftToRightAnimation(duration: NSTimeInterval = 0.5, completionDelegate: anyObject? = nil) {
        //Create a CATransition object
        let leftToRightTransition = CATransition()
        
        //Set its callback delegate to the completionDelegate that was provided
        if let delegate: AnyObject = completionDelegate {
            leftToRightTransition.delegate = delegate
        }
        
        leftToRightTransition.type = kCATransitionPush
        leftToRightTransition.subtype = kCATransitionFromRight
        leftToRightTransition.duration = duration
        leftToRightTransition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        leftToRightTransition.fillMode = KCAFillModeRemoved
        
        //Add the animation the View's Layer
        self.layer.addAnimation(leftToRightTransition, forKey: "leftToRightTransition")
    }
}
