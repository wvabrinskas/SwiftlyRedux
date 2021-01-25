//
//  TextViewModel.swift
//  SwiftlyRedux
//
//  Created by William Vabrinskas on 1/25/21.
//

import Foundation
import UIKit
import SwiftUI

struct TextViewModel {
  var buttonTitle: String = "Done"
  var placeholder: String = ""
  var placeholderColor: UIColor? = nil
  var textSize: CGFloat = 12
  var textAlignment: NSTextAlignment = .left
  var textColor: UIColor = .black
  var isPassword: Bool = false
}
