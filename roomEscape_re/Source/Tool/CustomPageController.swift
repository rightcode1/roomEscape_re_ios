//
//  CustomPageController.swift
//  ppuryo
//
//  Created by hoonKim on 2021/05/07.
//

import Foundation
import UIKit

// 커스텀 페이지컨트롤러

class CustomPageControl: UIPageControl {

    override var currentPage: Int {
        didSet {
            updateDots()
        }
    }

    override func sendAction(_ action: Selector, to target: Any?, for event: UIEvent?) {
        super.sendAction(action, to: target, for: event)
        updateDots()
    }

    private func updateDots() {
        let currentDot = subviews[currentPage]
        let largeScaling = CGAffineTransform(scaleX: 1.8, y: 1.0)
        let smallScaling = CGAffineTransform(scaleX: 1.0, y: 1.0)

        subviews.forEach {
            // Apply the large scale of newly selected dot.
            // Restore the small scale of previously selected dot.
            $0.layer.cornerRadius = $0 == currentDot ? 1.5 : 3.5
            $0.transform = $0 == currentDot ? largeScaling : smallScaling
        }
    }

    override func updateConstraints() {
        super.updateConstraints()
        // We rewrite all the constraints
        rewriteConstraints()
    }

    private func rewriteConstraints() {
        let systemDotSize: CGFloat = 7.0
        let systemDotDistance: CGFloat = 20.0

        let halfCount = CGFloat(subviews.count) / 2
        subviews.enumerated().forEach {
            let dot = $0.element
            dot.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.deactivate(dot.constraints)
            NSLayoutConstraint.activate([
                dot.widthAnchor.constraint(equalToConstant: systemDotSize),
                dot.heightAnchor.constraint(equalToConstant: systemDotSize),
                dot.centerYAnchor.constraint(equalTo: centerYAnchor, constant: 0),
                dot.centerXAnchor.constraint(equalTo: centerXAnchor, constant: systemDotDistance * (CGFloat($0.offset) - halfCount + CGFloat(0.7)))
                ])
        }
    }
}

class CustomSlider: UISlider {
  override func trackRect(forBounds bounds: CGRect) -> CGRect {
    let point = CGPoint(x: bounds.minX, y: bounds.midY)
    return CGRect(origin: point, size: CGSize(width: bounds.width, height: 13))
  }
}
