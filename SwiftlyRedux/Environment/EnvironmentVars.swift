//
//  EnvironmentVars+Theme.swift
//  Homes
//
//  Created by William Vabrinskas on 7/28/20.
//  Copyright © 2020 William Vabrinskas. All rights reserved.
//

import Foundation
import SwiftUI

struct ThemeKey: EnvironmentKey {
  static let defaultValue: Theme = Default()
}

struct StateKey: EnvironmentKey {
  static let defaultValue: StateCoordinator = StateCoordinator()
}

extension EnvironmentValues {
  var state: StateCoordinator {
    get { self[StateKey.self] }
    set { self[StateKey.self] = newValue }
  }
  
  var theme: Theme {
    get { self[ThemeKey.self] }
    set { self[ThemeKey.self] = newValue }
  }
}
