//
//  RactangleSize.swift
//  Rotate 360
//
//  Created by 윤태민 on 8/10/21.
//  Copyright © 2021 Taemin Yun. All rights reserved.
//

// Size of Rectangle

import Foundation

struct RectangleSize {
    private(set)  var width: CGFloat = 0
    private(set)  var height: CGFloat = 0
    
    init(_ width: CGFloat, _ height: CGFloat) {
        self.width = width
        self.height = height
    }
}
