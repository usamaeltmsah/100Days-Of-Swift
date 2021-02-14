//
//  SelectionViewController.swift
//  Project30
//
//  Created by TwoStraws on 20/08/2016.
//  Copyright (c) 2016 TwoStraws. All rights reserved.
//

import UIKit

class SelectionViewController: UITableViewController {
	var items = [String]() // this is the array that will store the filenames to load
	var viewControllers = [UIViewController]() // create a cache of the detail view controllers for faster loading
	var dirty = false

    override func viewDidLoad() {
        super.viewDidLoad()

		title = "Reactionist"

		tableView.rowHeight = 90
		tableView.separatorStyle = .none

		// load all the JPEGs into our array
		let fm = FileManager.default

		if let tempItems = try? fm.contentsOfDirectory(atPath: Bundle.main.resourcePath!) {
			for item in tempItems {
				if item.range(of: "Large") != nil {
					items.append(item)
				}
			}
		}
    }

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)

		if dirty {
			// we've been marked as needing a counter reload, so reload the whole table
			tableView.reloadData()
		}
	}

    // MARK: - Table view data source

	override func numberOfSections(in tableView: UITableView) -> Int {
        // Return the number of sections.
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Return the number of rows in the section.
        return items.count * 10
    }


    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = UITableViewCell(style: .default, reuseIdentifier: "Cell")

		// find the image for this cell, and load its thumbnail
		let currentImage = items[indexPath.row % items.count]
		let imageRootName = currentImage.replacingOccurrences(of: "Large", with: "Thumb")
		let path = Bundle.main.path(forResource: imageRootName, ofType: nil)!
		let original = UIImage(contentsOfFile: path)!

        // MARK: The problem is that the images being loaded are 750x750 pixels at 1x resolution, so 1500x1500 at 2x and 2250x2250 at 3x. If you look at viewDidLoad() you’ll see that the row height is 90 points, so we’re loading huge pictures into a tiny space. That means loading a 1500x1500 image or larger, creating a second render buffer that size, rendering the image into it, and so on.
        
//		let renderer = UIGraphicsImageRenderer(size: original.size)
        let renderRect = CGRect(origin: .zero, size: CGSize(width: 90, height: 90))
        let renderer = UIGraphicsImageRenderer(size: renderRect.size)

		let rounded = renderer.image { ctx in
            // MARK: New Code
            
            // Core Graphics is more than able of drawing shadows itself, which means we could handle the shadow rendering in our UIGraphicsImageRenderer pass rather than needing an extra render pass. To do that, we can use the Core Graphics setShadow() method, which takes three parameters: how far to offset the shadow, how much to blur it, and what color to use. You’ll notice there’s no way of specifying what shape the shadow should be, because Core Graphics has a simple but powerful solution: once you enable a shadow, it gets applied to everything you draw until you disable it by specifying a nil color.
//            ctx.cgContext.setShadow(offset: CGSize.zero, blur: 200, color: UIColor.black.cgColor)
//            ctx.cgContext.fillEllipse(in: CGRect(origin: CGPoint.zero, size: original.size))
//            ctx.cgContext.setShadow(offset: CGSize.zero, blur: 0, color: nil)
            
//			ctx.cgContext.addEllipse(in: CGRect(origin: CGPoint.zero, size: original.size))
            
            ctx.cgContext.addEllipse(in: renderRect)
            
            // clip(): you can create a path and draw it using two separate Core Graphics commands, but instead of running the draw command you can take the existing path and use it for clipping instead. This has the effect of only drawing things that lie inside the path, so when the UIImage is drawn only the parts that lie inside the elliptical clipping path are visible, thus rounding the corners.
			ctx.cgContext.clip()

//			original.draw(at: CGPoint.zero)
            original.draw(in: renderRect)
		}

		cell.imageView?.image = rounded

		// give the images a nice shadow to make them look a bit more dramatic
		cell.imageView?.layer.shadowColor = UIColor.black.cgColor
		cell.imageView?.layer.shadowOpacity = 1
		cell.imageView?.layer.shadowRadius = 10
		cell.imageView?.layer.shadowOffset = CGSize.zero
        
        // We can tell iOS not to automatically calculate the shadow path for our images by giving it the exact shadow path to use. The easiest way to do this is to create a new UIBezierPath that describes our image (an ellipse with width 90 and height 90), then convert it to a CGPath because CALayer doesn't understand what UIBezierPath is.
        cell.imageView?.layer.shadowPath = UIBezierPath(ovalIn: renderRect).cgPath
        // When you run that, you'll still see the same shadows everywhere, but the dark yellow color is gone. This means we’ve successfully eliminated the second render pass by giving iOS the pre-calculated shadow path, and we’ve also sped up drawing by scaling down the amount of working being done. You can turn off Color Offscreen-Rendered Yellow now; we don’t need it any more.
        
		// each image stores how often it's been tapped
		let defaults = UserDefaults.standard
		cell.textLabel?.text = "\(defaults.integer(forKey: currentImage))"

		return cell
    }

	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let vc = ImageViewController()
		vc.image = items[indexPath.row % items.count]
		vc.owner = self

		// mark us as not needing a counter reload when we return
		dirty = false

		// add to our view controller cache and show
		viewControllers.append(vc)
		navigationController!.pushViewController(vc, animated: true)
	}
}
