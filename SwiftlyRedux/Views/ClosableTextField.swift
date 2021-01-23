//
//  ClosableTextField.swift
//  Homes
//
//  Created by William Vabrinskas on 8/5/20.
//  Copyright © 2020 William Vabrinskas. All rights reserved.
//

import Foundation
import SwiftUI
import Combine

struct ClosableTextField: UIViewRepresentable {

  var viewModel: CloseableTextFieldViewModel
  
  @Binding var text: String
  var keyType: UIKeyboardType
  let textfield = UITextField(frame: .zero)
  var didUpdate: ((_ text: String) -> ())?

  func makeUIView(context: Context) -> UITextField {
    
    textfield.keyboardType = keyType
    textfield.placeholder = viewModel.placeholder
    
    if let placeholderColor = viewModel.placeholderColor {
      textfield.attributedPlaceholder = NSAttributedString(string: viewModel.placeholder, attributes: [.foregroundColor: placeholderColor])
    }
    
    textfield.textAlignment = viewModel.textAlignment
    textfield.textColor = viewModel.textColor
    textfield.font = UIFont.boldSystemFont(ofSize: viewModel.textSize)
    textfield.isSecureTextEntry = viewModel.isPassword 
    
    let toolBar = UIToolbar(frame: CGRect(x: 0, y: 0, width: textfield.frame.size.width, height: 44))
    
    let doneButton = UIBarButtonItem(title: viewModel.buttonTitle,
                                     style: .done,
                                     target: self,
                                     action: #selector(textfield.doneButtonTapped(button:)))
    
    toolBar.items = [doneButton]
    toolBar.setItems([doneButton], animated: true)
    textfield.inputAccessoryView = toolBar
    
    return textfield
    
  }
  
  func updateUIView(_ uiView: UITextField, context: Context) {
    self.textfield.text = text
  }
  
  func makeCoordinator() -> Coordinator {
    Coordinator(self)
  }
  
  typealias UIViewType = UITextField
  
  class Coordinator: NSObject {
    let owner: ClosableTextField
    private var subscriber: AnyCancellable
    
    init(_ owner: ClosableTextField) {
      self.owner = owner
      subscriber = NotificationCenter.default.publisher(for: UITextField.textDidChangeNotification, object: owner.textfield)
        .sink(receiveValue: { _ in
          owner.$text.wrappedValue = owner.textfield.text ?? ""
          owner.didUpdate?(owner.textfield.text ?? "")
        })
    }
    
  }
}

extension UITextField {
  @objc func doneButtonTapped(button: UIBarButtonItem) -> Void {
    self.resignFirstResponder()
  }
  
}
