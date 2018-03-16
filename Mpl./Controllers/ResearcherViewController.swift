//
//  ResearcherViewController.swift
//  Mpl.
//
//  Created by Darius Martin on 12/03/2018.
//  Copyright © 2018 Darius MARTIN. All rights reserved.
//

import UIKit

class ResearcherViewController: UIViewController {

    var lineCards: [UILineCard] = []
    var animState = 0

    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var headerShadowLabel: UILabel!
    @IBOutlet weak var headerLightLabel: UILabel!

    @IBOutlet weak var linesTitle: UILabel!
    @IBOutlet weak var linesScroll: UIScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Header
        self.headerView.frame.size = CGSize(width: UIScreen.main.bounds.width+60, height: UIScreen.main.bounds.height*0.22)
        self.headerView.layer.shadowRadius = 40
        self.headerView.layer.shadowColor = UIColor.lightGray.cgColor
        self.headerView.layer.shadowOpacity = 1
        //Label position
        headerLightLabel.frame = CGRect(x: 30+12, y: headerView.frame.maxY-45, width: self.view.frame.width-20, height: headerLightLabel.frame.height)
        headerShadowLabel.frame = CGRect(x: 30+16, y: headerView.frame.maxY-42, width: self.view.frame.width-20, height: headerLightLabel.frame.height)
        headerView.addSubview(headerShadowLabel)
        headerView.addSubview(headerLightLabel)
        
        //Lines scrollview
        linesScroll.frame.origin = CGPoint(x: 0, y: self.headerView.frame.height+75)
        linesScroll.frame.size = CGSize(width: UIScreen.main.bounds.width, height: 170)
        
        self.linesTitle.frame = CGRect(x: 16, y: self.headerView.frame.maxY+50, width: self.linesScroll.frame.width, height: 23)
        
        let sortedLines = TransportData.lines.sorted(by: { $0.displayId < $1.displayId})
        
        for i in 0..<sortedLines.count {
            if i >= sortedLines.count { break }
            let line = sortedLines[i]
            
            let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap(sender:)))
            let lineCard = UILineCard.init(frame: CGRect.init(x: i*150+15+(15*i), y: 5, width: 150, height: 160), line: line)
            lineCard.addGestureRecognizer(tap)
            lineCards.append(lineCard)
            self.linesScroll.addSubview(lineCard)
            self.linesScroll.contentSize = CGSize(width: i*150+15+(15*i)+150+15, height: 170)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func handleTap(sender: UITapGestureRecognizer? = nil) {
        // handling code
        let card = self.lineCards[0]
        if (animState == 0) {
            self.view.addSubview(card)
            card.frame = CGRect.init(x: 15, y: 150+5, width: card.frame.width, height: card.frame.height)
            for label in card.destinationsLabels {
                label.removeFromSuperview()
            }
            UIView.animate(withDuration: 0.55, delay: 0.0, options: [.curveEaseInOut], animations: {
                card.frame.origin = CGPoint(x: 0, y: 0)
                card.frame.size = CGSize(width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height*0.22)
                card.logo?.panel.frame.origin = CGPoint(x: 25, y: 50)
                card.logo?.panel.transform = CGAffineTransform(scaleX: 1.45, y: 1.45)
                card.layer.cornerRadius = 0
            }) { (value: Bool) in
                card.animState = 1
                print("animation finished.")
            }
        } else if (animState == 1) {
            UIView.animate(withDuration: 0.55, delay: 0.0, options: [.curveEaseInOut], animations: {
                card.frame.origin = CGPoint(x: 15, y: 150)
                card.frame.size = CGSize(width: 150, height: 160)
                card.logo!.panel.frame.origin = CGPoint(x: 5, y: 5)
                card.logo!.panel.transform = CGAffineTransform.identity
                card.layer.cornerRadius = 15
            }) { (value: Bool) in
                card.animState = 0
                print("animation finished.")
                self.linesScroll.addSubview(card)
            }
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
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
