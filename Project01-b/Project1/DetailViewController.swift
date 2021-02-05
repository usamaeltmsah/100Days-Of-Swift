//
//  DetailViewController.swift
//  Project1
//
//  Created by Usama Fouad on 12/11/20.
//

import UIKit

class DetailViewController: UIViewController {

    @IBOutlet var imageView: UIImageView!
    var selectedImage: String?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(shareTapped))
//        title = selectedImage
        title = "Picture \(selectedPictureNumber!) of \(totalPictures!)"
        navigationItem.largeTitleDisplayMode = .never
        
        // Do any additional setup after loading the view.
        
        if let imageToLoad = selectedImage {
            imageView.image = UIImage(named: imageToLoad)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.hidesBarsOnTap = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.hidesBarsOnTap = false
    }
    
    @objc func shareTapped() {
        guard let _ = imageView.image?.jpegData(compressionQuality: 0.8) else {
            print("No image found")
            return
        }
        let vc = UIActivityViewController(activityItems: [selectedImage!, combineImageAndText(img: imageView.image!)], applicationActivities: [])
        
        vc.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItem
        present(vc, animated: true)
    }
    
    func combineImageAndText(img: UIImage, text: String = "From Storm Viewer") -> Data {
        let size = img.size
        print(size)
        let renderer = UIGraphicsImageRenderer(size: size)
        
        let image = renderer.image { ctx in
            img.draw(at: CGPoint(x: 0, y: 0))
            
            let paragaphStyle = NSMutableParagraphStyle()
            paragaphStyle.alignment = .center
            
            let attrs: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 100),
                .paragraphStyle: paragaphStyle,
                .strokeColor: UIColor.white.cgColor,
                .backgroundColor: UIColor.black.cgColor,
                .strokeWidth: 5
            ]
            let attributedString = NSAttributedString(string: text, attributes: attrs)
            
            attributedString.draw(with: CGRect(x: 32, y: 32, width: size.width - 50, height: size.height - 50), options: .usesLineFragmentOrigin, context: nil)
        }
        return image.jpegData(compressionQuality: 0.8)!
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
