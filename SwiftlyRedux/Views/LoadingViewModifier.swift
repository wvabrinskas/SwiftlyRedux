import Foundation
import SwiftUI


extension View {
  @ViewBuilder func isHidden(_ hidden: Bool, remove: Bool = false) -> some View {
    if hidden {
      if !remove {
        self.hidden()
      }
    } else {
      self
    }
  }
}

struct LoadingIndicator: UIViewRepresentable {

    @Binding var isAnimating: Bool
    let style: UIActivityIndicatorView.Style

    func makeUIView(context: UIViewRepresentableContext<LoadingIndicator>) -> UIActivityIndicatorView {
        return UIActivityIndicatorView(style: style)
    }

    func updateUIView(_ uiView: UIActivityIndicatorView, context: UIViewRepresentableContext<LoadingIndicator>) {
        isAnimating ? uiView.startAnimating() : uiView.stopAnimating()
    }
}


extension View {
  func loadable(title: String = "", showing: Binding<Bool>,
                background: Color = .gray,
                textColor: Color = .white) -> some View {
    
    self.modifier(LoadingViewModifier(title: title,
                                      background: background,
                                      textColor: textColor,
                                      showing: showing))
  }
}

struct LoadingViewModifier: ViewModifier {
  let title: String
  var background: Color = .gray
  var textColor: Color = .white

  @Binding var showing: Bool

  func body(content: Content) -> some View {
    content
      .overlay(self.loadingView())
  }

  private func loadingView() -> AnyView {
    if self.showing {
      return AnyView(VStack {
        Text(title)
          .font(Font.system(size: 20))
          .foregroundColor(textColor)
          .fontWeight(.bold)
          .padding(10)
          .isHidden(title.isEmpty)
        LoadingIndicator(isAnimating: self.$showing, style: .large)
          .padding([.bottom], 10)
      }.background(background)
        .cornerRadius(20))
    }
    return AnyView(Color.clear)
  }
}


