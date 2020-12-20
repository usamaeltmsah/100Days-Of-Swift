//
//  ViewController.swift
//  Project06b
//
//  Created by Usama Fouad on 20/12/2020.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let label1 = UILabel()
        label1.backgroundColor = .red
        label1.text = "THESE"
        
        let label2 = UILabel()
        label2.backgroundColor = .cyan
        label2.text = "ARE"
        
        let label3 = UILabel()
        
        label3.backgroundColor = .yellow
        label3.text = "SOME"
        
        let label4 = UILabel()
        label4.backgroundColor = .green
        label4.text = "AWESOME"
        
        let label5 = UILabel()
        label5.backgroundColor = .orange
        label5.text = "LABELS"
        
        
//        let viewsDictionary = ["label1": label1, "label2": label2, "label3": label3, "label4": label4, "label5": label5]
//
//        for label in viewsDictionary.keys {
//            view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[\(label)]|", options: [], metrics: nil, views: viewsDictionary))
//        }
//
//        let metrics = ["labelHeight": 88]
//
//        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[label1(labelHeight@999)]-[label2(label1)]-[label3(label1)]-[label4(label1)]-[label5(label1)]-(>=10)-|", options: [], metrics: metrics, views: viewsDictionary))
        
        var previous: UILabel?
        
        for label in [label1, label2, label3, label4, label5] {
            view.addSubview(label)
            label.translatesAutoresizingMaskIntoConstraints = false
            label.sizeToFit()
            label.textAlignment = .center
            
            label.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
            label.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true

            label.heightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.heightAnchor, multiplier: 1/5, constant: -10).isActive = true
            
            if let previous = previous {
                label.topAnchor.constraint(equalTo: previous.bottomAnchor, constant: 10).isActive = true
            } else {
                label.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 0).isActive = true
            }
            
            previous = label
        }
    }


}

