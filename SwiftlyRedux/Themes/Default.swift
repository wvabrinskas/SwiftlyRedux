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
  var buttonSize: CGSize {
    .init(width: 300, height: 50)
  }
  
  var lightButtonColor: Color {
    .dodgerBlue
  }
  
  var darkButtonColor: Color {
    .midnightBlue
  }
  
  var background: Color {
    .darkSlateGray
  }

  var lightTextColor: Color {
    .whiteSmoke
  }
  
  var darkTextColor: Color {
    .darkSlateGray
  }
  
  var secondaryBackground: Color {
    .steelBlue
  }
  
  var cellColor: Color {
    .whiteSmoke
  }
}
