//
//  ButtonView.swift
//  Homes
//
//  Created by William Vabrinskas on 7/28/20.
//  Copyright © 2020 William Vabrinskas. All rights reserved.
//

import SwiftUI


struct LoadingView: View {
  @Environment(\.theme) var theme

  var body: some View {
    VStack {
      Spacer()
      Image("swift")
        .resizable()
        .aspectRatio(contentMode: .fit)
        .frame(width: 300, height: 300)
      Spacer()
    }
    .background(theme.secondaryBackground)
  }
}

