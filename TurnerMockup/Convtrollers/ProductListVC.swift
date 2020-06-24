//
//  ProductListVC.swift
//  TurnerMockup
//
//  Created by Jeffrey Thompson on 3/21/19.
//  Copyright © 2019 Jeffrey Thompson. All rights reserved.
//

import UIKit

class ProductListVC: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    let productImages: [UIImage?] = [
        UIImage(named: "C3thumbnail"),
        UIImage(named: "C6Kthumbnail"),
        UIImage(named: "C6Pthumbnail"),
        UIImage(named: "CIthumbnail")
    ]
    
    let productTexts: [String] = [
        "C3 Submersible Fluorometer",
        "Cyclops-6K Submersible Fluorometer",
        "C6P Submersible Fluorometer",
        "Cyclops Integrator Submersible Fluorometer"
    ]
    
    var selectedRowNumberForSegue: Int?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        // Do any additional setup after loading the view.
        //self.navigationController?.navigationBar.backgroundColor = UIColor.clear
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = false
    }
    
    private func setupTableView(){
        tableView.backgroundColor = UIColor.clear
        tableView.separatorStyle = .none
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if let destination = segue.destination as? ProductDetailVC {
            destination.productImg = productImages[selectedRowNumberForSegue!]
            destination.productTitle = productTexts[selectedRowNumberForSegue!]
        }
    }
}

extension ProductListVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 140
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("Selected at row: \(indexPath.row)")
        
        selectedRowNumberForSegue = indexPath.row
        performSegue(withIdentifier: "showProductSegue", sender: self)
        
    }
}

extension ProductListVC: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return productTexts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "productListCell", for: indexPath) as! ProductListTblCell
        
        // Configure the cell...
        let imgView = UIImageView(image: productImages[indexPath.row])
        imgView.layer.cornerRadius = 15
        imgView.layer.masksToBounds = true
        //addConstraintsWithFormat("H:|-8-[v0(150)]", imgView)
        
        cell.imgContainer.addSubview(imgView)
        
        cell.imgContainer.addConstraintsWithFormat(format: "H:|-2-[v0(96)]", views: imgView)
        cell.imgContainer.addConstraintsWithFormat(format: "V:|-2-[v0(96)]", views: imgView)
        
        
        
        cell.labelView.text = productTexts[indexPath.row]
        cell.labelView.numberOfLines = 3
        cell.labelView.textAlignment = .left
        cell.labelView.lineBreakMode = .byWordWrapping
        
        cell.selectionStyle = .none
        
        return cell
    }
}

extension UIView {
    
    func addConstraintsWithFormat(format: String, views: UIView...) {
        var viewsDictionary = [String : UIView]()
        for (index, view) in views.enumerated() {
            let key = "v\(index)"
            viewsDictionary[key] = view
            view.translatesAutoresizingMaskIntoConstraints = false
        }
        
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: format, options: NSLayoutConstraint.FormatOptions(), metrics: nil, views: viewsDictionary))
    }
    
}
