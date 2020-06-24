//
//  ProductDetailVC.swift
//  TurnerMockup
//
//  Created by Jeffrey Thompson on 3/22/19.
//  Copyright © 2019 Jeffrey Thompson. All rights reserved.
//

import UIKit
import MessageUI

class ProductDetailVC: UIViewController {
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    var productImg: UIImage!
    var productText: String = "\tLorem ipsum dolor sit amet, consectetur adipiscing elit. Integer nec odio. Praesent libero. Sed cursus ante dapibus diam. Sed nisi. Nulla quis sem at nibh elementum imperdiet. Duis sagittis ipsum. Praesent mauris. Fusce nec tellus sed augue semper porta. Mauris massa. Vestibulum lacinia arcu eget nulla. \n\tLorem ipsum dolor sit amet, consectetur adipiscing elit. Integer nec odio. Praesent libero. Sed cursus ante dapibus diam. Sed nisi. Nulla quis sem at nibh elementum imperdiet. Duis sagittis ipsum. Praesent mauris. Fusce nec tellus sed augue semper porta. Mauris massa. Vestibulum lacinia arcu eget nulla."
    var productTitle: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupGraphics()
        scrollView.isScrollEnabled = true
        let width = scrollView.frame.width
        let height = CGFloat(690)
        scrollView.contentSize = CGSize(width: width, height: height)
    }
    
    private func setupGraphics(){
        
//        scrollView.backgroundColor = UIColor(white: 1.0, alpha: 0.55)
//        scrollView.layer.cornerRadius = 30
//        scrollView.layer.masksToBounds = true
        
        let width = scrollView.frame.width
        let height = 690.0
        
        let frame = CGRect(x: 0.0, y: 0.0, width: Double(width), height: height)
        let scrollBG = UIView(frame: frame)
        scrollBG.backgroundColor = UIColor(white: 1.0, alpha: 0.55)
        scrollBG.layer.cornerRadius = 30
        scrollBG.layer.masksToBounds = true
        
        scrollView.addSubview(scrollBG)
        
        let imageView = UIImageView(image: productImg)
        imageView.layer.cornerRadius = 30
        imageView.layer.masksToBounds = true

        scrollBG.addSubview(imageView)
        let offsetX = (scrollBG.frame.width - 160)/2
        scrollBG.addConstraintsWithFormat(format: "H:|-\(offsetX)-[v0(160)]|", views: imageView)
        scrollBG.addConstraintsWithFormat(format: "V:|-20-[v0(160)]", views: imageView)

        //let labelFrame = CGRect(x: 5, y: imageView.frame.minY+imageView.frame.height+100, width: 400, height: 400)
        //let label = UILabel(frame: labelFrame)
        let label = UILabel()
        label.text = productText
        label.numberOfLines = 30
        label.textAlignment = .justified
        label.lineBreakMode = .byWordWrapping
        label.textColor = UIColor.darkGray

        scrollBG.addSubview(label)
        scrollBG.addConstraintsWithFormat(format: "H:|-12-[v0]-12-|", views: label)
        scrollBG.addConstraintsWithFormat(format: "V:|-200-[v0(400)]", views: label)

        let btnGetQuote = UIButton(type: .custom)
        btnGetQuote.setTitle("Contact for Quote", for: .normal)
        btnGetQuote.setTitleColor(UIColor.darkGray, for: .normal)
        //btnGetQuote.titleLabel?.text = "Contact for Quote"
        //btnGetQuote.titleLabel?.textColor = UIColor.darkGray
        //btnGetQuote.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        btnGetQuote.backgroundColor = UIColor(white: 1.0, alpha: 0.8)
        btnGetQuote.layer.cornerRadius = 22
        btnGetQuote.layer.masksToBounds = true
        
        btnGetQuote.addTarget(self, action: #selector(onPressQuoteBtn), for: .touchUpInside)

        scrollBG.addSubview(btnGetQuote)
        let btnOffsetX = (scrollBG.frame.width - 220)/2
        scrollBG.addConstraintsWithFormat(format: "H:|-\(btnOffsetX)-[v0(220)]|", views: btnGetQuote)
        scrollBG.addConstraintsWithFormat(format: "V:|-620-[v0(44)]|", views: btnGetQuote)
        
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    @objc private func onPressQuoteBtn(){
        //print("pressed quote button")
        
        let emailVC = MFMailComposeViewController()
        emailVC.mailComposeDelegate = self
        
        emailVC.setSubject("Request for Quote: \(productTitle ?? "TD Product")")
        emailVC.setToRecipients(["jefreythompson@gmail.com"])
        emailVC.setMessageBody("Please quote this product.", isHTML: false)
        
        if MFMailComposeViewController.canSendMail() {
            self.present(emailVC, animated: true, completion: nil)
        } else {
            print("email send error")
        }
    }
}

extension ProductDetailVC: UIScrollViewDelegate {
    
}

extension ProductDetailVC: MFMailComposeViewControllerDelegate {
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        
        if let error = error {
            print(error)
        }
        
        controller.dismiss(animated: true, completion: nil)
    }
    
}
