import UIKit


extension UIView {
    // Use animation to scale its size down to 0.0001 over a specified number of seconds.
    func bounceOut(duration: TimeInterval) {
        UIView.animate(withDuration: duration, animations: { [unowned self] in
            self.transform = CGAffineTransform(scaleX: 0.0001, y: 0.0001)
        })
    }
}

// Extend Int with a times() method that runs a closure as many times as the number is high.
extension Int {
    func times(closure: () -> Void) {
        guard self > 0 else { return }
        
        for _ in 0..<self {
            closure()
        }
    }
}

5.times {
    print("Hello!")
}

// Extend Array so that it has a mutating remove(item:) method. If the item exists more than once, it should remove only the first instance it finds
extension Array where Element: Comparable {
    mutating func remove(item: Element) {
        if let index = self.firstIndex(of: item) {
            self.remove(at: index)
        }
    }
}


var numbers = [1, 2, 3, 4, 5]
numbers.remove(item: 3)
