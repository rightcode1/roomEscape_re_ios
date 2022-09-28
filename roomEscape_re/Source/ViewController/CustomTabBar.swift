//
//  CustomTabBar.swift
//  roomEscape_re
//
//  Created by RightCode_IOS on 2021/12/09.
//

import UIKit

class CustomTabBar : UITabBar {
    @IBInspectable var height: CGFloat = 0.0

    override func sizeThatFits(_ size: CGSize) -> CGSize {
        var sizeThatFits = super.sizeThatFits(size)
        if height > 0.0 {
            sizeThatFits.height = height
        }
        return sizeThatFits
    }
}
