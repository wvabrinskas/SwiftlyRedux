//
//  Theme.swift
//  Homes
//
//  Created by William Vabrinskas on 7/28/20.
//  Copyright © 2020 William Vabrinskas. All rights reserved.
//

import Foundation
import UIKit
import SwiftUI

public protocol Theme {
  var secondaryBackground: Color { get }
  var background: Color { get }
  var textColor: Color { get }
  var commentTextColor: Color { get }
  var gradientBackground: LinearGradient { get }
  var firstGradientColor: Color { get }
  var secondGradientColor: Color { get }
  var buttonColor: Color { get }
  var lightButtonColor: Color { get }
  var overlayViewColor: Color { get }
  var creamBackgroundColor: Color { get }
  var buttonSize: CGSize { get }
  var creamBackgroundColorWithAlpha: Color { get }
}
