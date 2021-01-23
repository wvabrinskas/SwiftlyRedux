//
//  ButtonViewModels.swift
//  Neuron
//
//  Created by William Vabrinskas on 7/1/20.
//  Copyright © 2020 William Vabrinskas. All rights reserved.
//

import Foundation
import UIKit
import SwiftUI


struct ButtonViewModel {
  var title: String = ""
  var buttonImage: String = "person"
  var size: CGSize = CGSize(width: 100, height: 100)
  var backgroundColor: Color = Color.white
  var imageColor: Color = Color.black
  var imageSize: CGFloat = 60
  var shadow: Bool = false
  var shadowRadius: CGFloat = 0
}

