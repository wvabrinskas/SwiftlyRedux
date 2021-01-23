//
//  Default.swift
//  Homes
//
//  Created by William Vabrinskas on 7/28/20.
//  Copyright © 2020 William Vabrinskas. All rights reserved.
//

import Foundation
import UIKit
import SwiftUI
import Colorful

class Default: Theme {
  var background: Color {
    Color.lightCoral
  }

  var textColor: Color {
    Color.white
  }
  
  var commentTextColor: Color {
    Color.black
  }
  
  var secondaryBackground: Color {
    Color(hex: 0x242424)
  }

  var gradientBackground: LinearGradient {
    return LinearGradient(gradient: Gradient(colors: [firstGradientColor, secondaryBackground]),
                          startPoint: .top,
                          endPoint: .bottom)
  }
  
  var firstGradientColor: Color {
    let colorTop = Color(hex: 0x002952)
    return colorTop
  }
  
  var secondGradientColor: Color {
    let colorBottom = Color(hex: 0x00509F)
    return colorBottom
  }
  
  var buttonColor: Color {
    let colorBottom = Color(hex: 0x002952)
    return colorBottom
  }
  
  var overlayViewColor: Color {
    let color = Color(hex: 0xFFF7EF)
    return color
  }
  
  var lightButtonColor: Color {
    let color = Color(hex: 0x002952)
    return color
  }
  
  var creamBackgroundColor: Color {
    return Color(hex: 0xFFF7EF)
  }
  
  var buttonSize: CGSize {
    return CGSize(width: 343, height: 50)
  }
  
  var creamBackgroundColorWithAlpha: Color {
    return Color(hex: 0xFFF7EF).opacity(0.9)
  }
}
