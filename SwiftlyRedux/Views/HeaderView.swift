import SwiftUI

struct HeaderView: View {
  @Environment(\.theme) var theme
  var viewModel: HeaderViewModel
  
  var body: some View {
    VStack {
      Text(viewModel.title)
        .font(Font.system(size: 30))
        .foregroundColor(theme.lightTextColor)
        .fontWeight(.bold)
        .padding([.leading], 20)
        .frame(maxWidth: .infinity, maxHeight: 40, alignment: .leading)
      
      Text(viewModel.subtitle)
        .font(Font.system(size: 16))
        .foregroundColor(theme.lightTextColor)
        .padding([.leading], 20)
        .frame(maxWidth: .infinity, maxHeight: 40, alignment: .leading)
    }

  }
}
