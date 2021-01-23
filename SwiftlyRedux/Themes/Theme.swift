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
  var lightTextColor: Color { get }
  var darkTextColor: Color { get  }
  var lightButtonColor: Color { get }
  var darkButtonColor: Color { get }
  var buttonSize: CGSize { get }
}
