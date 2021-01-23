//
//  CloseableTextFieldViewModel.swift
//  Homes
//
//  Created by William Vabrinskas on 8/5/20.
//  Copyright © 2020 William Vabrinskas. All rights reserved.
//

import Foundation
import UIKit
import SwiftUI

struct CloseableTextFieldViewModel {
  var buttonTitle: String = ""
  var placeholder: String = ""
  var placeholderColor: UIColor? = nil
  var textSize: CGFloat = 12
  var textAlignment: NSTextAlignment = .left
  var textColor: UIColor = .black
  var isPassword: Bool = false
}
