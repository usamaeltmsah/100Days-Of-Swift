//
//  ImageViewController.swift
//  Project30
//
//  Created by TwoStraws on 20/08/2016.
//  Copyright (c) 2016 TwoStraws. All rights reserved.
//

import UIKit


// Press Cmd+I to run the app using Instruments.

// By default, the detail view shows everything in the app run that was captured, but you can click (right click) and drag in the top window to select part of the readings when you tapped on an image. All being well (or as well as can be expected in this broken code!) you should see the readings noticeably spike at those places.

// When you select an area of the readings like this, the detail view now shows information just on the part you chose. You should see that the vast majority of the time that was selected was spent on the main thread, which means we're not taking much advantage of having multiple CPU cores.

// Immediately to the left of "Main thread" in the detail view is a disclosure arrow. You can click that to open up all the top-level calls made on the Main Thread, which will just be "Start", which in turn has its own calls under its own arrow. You can if you want hold down Option and click on these arrows, which causes all the children (and their children's children) to be opened up, but that gets messy.

// Instead, there are two options. First, you should have a right-hand detail pane with two buttons: Extended Detail and Run Info (accessible through Cmd+1 and Cmd+2). Select "Main thread" in the detail view then press Cmd+1 to choose the extended detail view: this will automatically show you the "heaviest" stack trace, which is the code that took the most time to run.

// If you scroll down to the bottom, you'll see it's probably all around either in the table view’s cellForRowAt or the detail view’s viewDidLoad() depending on whether you spent more of your time flicking through the table view or going into the detail controller.

// This heaviest stack trace is the part of the code that took up the most time. That might not always be your problem: sometimes something that runs slowly is just something that's always going to be slow, because it’s doing a lot of work. That said, it's always a good place to start!

// The second option is inside the Call Tree menu that inside the status bar at the bottom of the Time Profiler window, and is called Invert Call Tree. This will show you the heaviest code first, with a disclosure arrow revealing what called it, and so on. Chances are you’ll now see lots of image-related functions: argb32_sample_argb32() is called by argb32_image_mark(), which is called by argb32_imag(), and so on.

// There is a third option, but it's of mixed help. It's called "Hide system libraries" and is near to the "Invert Call Tree" checkbox. This eliminates all time being used by Apple's frameworks so you can focus on your own code. This is great if you have lots of complicated code that could be slow, but it doesn't help at all if your app is slow because you're using the system libraries poorly!

// Now, although profiling your code is best done on a real device, using the simulator gives us some bonus functionality that will help us identify performance problems. So, try running the app in the simulator now.

// Under the Debug menu on your Mac you’ll see a few options. Two in particular are very useful:

    // - Color Blended Layers shows views that are opaque in green and translucent in red. If there are multiple transparent views inside each other, you'll see more and more red.
    // - Color Offscreen-Rendered shows views that require an extra drawing pass in yellow. Some special drawing work must be drawn individually off screen then drawn again onto the screen, which means a lot more work.
// Broadly speaking, you want "Color Blended Layers" to show as little red as possible, and "Color Offscreen-Rendered Yellow" to show no yellow.



class ImageViewController: UIViewController {
	weak var owner: SelectionViewController!
	var image: String!
	var animTimer: Timer!

	var imageView: UIImageView!

	override func loadView() {
		super.loadView()
		
		view.backgroundColor = UIColor.black

		// create an image view that fills the screen
		imageView = UIImageView()
		imageView.contentMode = .scaleAspectFit
		imageView.translatesAutoresizingMaskIntoConstraints = false
		imageView.alpha = 0

		view.addSubview(imageView)

		// make the image view fill the screen
		imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
		imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
		imageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
		imageView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true

		// schedule an animation that does something vaguely interesting
		animTimer = Timer.scheduledTimer(withTimeInterval: 5, repeats: true) { timer in
			// do something exciting with our image
			self.imageView.transform = CGAffineTransform.identity

			UIView.animate(withDuration: 3) {
				self.imageView.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
			}
		}
	}

    override func viewDidLoad() {
        super.viewDidLoad()

		title = image.replacingOccurrences(of: "-Large.jpg", with: "")
        // MARK: Running Out OF Memory Issue
        // How likely is it that users will go back and forward to the same image again and again? Not likely at all, so we can skip the image cache by creating our images using the UIImage(contentsOfFile:) initializer instead. This isn't as friendly as UIImage(named:) because you need to specify the exact path to an image rather than just its filename in your app bundle. The solution is to use Bundle.main.path(forResource:ofType:), which is similar to the Bundle.main.url(forResource:) method we’ve used previously, except it returns a simple string rather than a URL:
//		let original = UIImage(named: image)!
        
        if let path = Bundle.main.path(forResource: image, ofType: nil) {
            if let original = UIImage(contentsOfFile: path) {
                // What's causing the image view controller to never be destroyed? If you read through SelectionViewController.swift and ImageViewController.swift you might spot these two things:
                
                    // 1. The selection view controller has a viewControllers array that claims to be a cache of the detail view controllers. This cache is never actually used, and even if it were used it really isn't needed.
                    // 2. The image view controller has a property var owner: SelectionViewController! – that makes it a strong reference to the view controller that created it.
                
                let renderer = UIGraphicsImageRenderer(size: original.size)

                let rounded = renderer.image { ctx in
                    ctx.cgContext.addEllipse(in: CGRect(origin: CGPoint.zero, size: original.size))
                    ctx.cgContext.closePath()

                    original.draw(at: CGPoint.zero)
                }

                imageView.image = rounded
            }
        }
    }

	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)

		imageView.alpha = 0

		UIView.animate(withDuration: 3) { [unowned self] in
			self.imageView.alpha = 1
		}
	}

	override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
		let defaults = UserDefaults.standard
		var currentVal = defaults.integer(forKey: image)
		currentVal += 1

		defaults.set(currentVal, forKey:image)

		// tell the parent view controller that it should refresh its table counters when we go back
		owner.dirty = true
	}
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        animTimer.invalidate()
    }
}
