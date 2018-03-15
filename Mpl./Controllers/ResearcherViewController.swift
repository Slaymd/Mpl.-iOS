//
//  ResearcherViewController.swift
//  Mpl.
//
//  Created by Darius Martin on 12/03/2018.
//  Copyright © 2018 Darius MARTIN. All rights reserved.
//

import UIKit

class ResearcherViewController: UIViewController {

    @IBOutlet weak var panel1: UIView!
    var logo: UILineLogo? = nil
    var animState = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        let line3 = TransportData.getLine(byTamId: 3)
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap(sender:)))
        //tap.delegate = self
        panel1.addGestureRecognizer(tap)
        if (line3 != nil) {
            panel1.backgroundColor = line3!.bgColor
            let logo = UILineLogo(lineShortName: line3!.shortName, bgColor: .white, fontColor: line3!.bgColor, type: .TRAMWAY, at: CGPoint(x: 10, y: 10))
            self.logo = logo
            panel1.addSubview(logo.panel)
        }
        self.panel1.layer.cornerRadius = 15
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func handleTap(sender: UITapGestureRecognizer? = nil) {
        // handling code
        print("cc")
        if (animState == 0) {
            UIView.animate(withDuration: 0.55, delay: 0.0, options: [.curveEaseInOut], animations: {
                self.panel1.frame.origin = CGPoint(x: 0, y: 0)
                self.panel1.frame.size = CGSize(width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height*0.22)
                self.logo!.panel.frame.origin = CGPoint(x: 25, y: 50)
                self.logo!.panel.transform = CGAffineTransform(scaleX: 1.45, y: 1.45)
                self.panel1.layer.cornerRadius = 0
            }) { (value: Bool) in
                self.animState = 1
                print("animation finished.")
            }
        } else if (animState == 1) {
            UIView.animate(withDuration: 0.55, delay: 0.0, options: [.curveEaseInOut], animations: {
                self.panel1.frame.origin = CGPoint(x: 15, y: 150)
                self.panel1.frame.size = CGSize(width: 150, height: 160)
                self.logo!.panel.frame.origin = CGPoint(x: 5, y: 5)
                self.logo!.panel.transform = CGAffineTransform.identity
                self.panel1.layer.cornerRadius = 15
            }) { (value: Bool) in
                self.animState = 0
                print("animation finished.")
            }
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
