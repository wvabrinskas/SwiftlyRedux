//
//  TextView.swift
//
//  Created by William Vabrinskas on 1/15/21.
//  Copyright © 2021 William Vabrinskas. All rights reserved.
//

import Foundation
import SwiftUI

struct TextView: UIViewRepresentable {
  var viewModel: TextViewModel
  
  @Binding var text: String
  
  public var didUpdate: ((_ text: String) -> ())?
  
  func makeUIView(context: Context) -> UITextView {
    let textView = UITextView()
    
    textView.font = UIFont.boldSystemFont(ofSize: viewModel.textSize)
    textView.autocapitalizationType = .sentences
    textView.isSelectable = true
    textView.isUserInteractionEnabled = true
    textView.backgroundColor = .clear
    textView.textColor = viewModel.textColor
    
    let toolBar = UIToolbar(frame: CGRect(x: 0, y: 0, width: textView.frame.size.width, height: 44))
    
    let doneButton = UIBarButtonItem(title: viewModel.buttonTitle,
                                     style: .done,
                                     target: self,
                                     action: #selector(textView.doneButtonTapped(button:)))
    
    toolBar.items = [doneButton]
    toolBar.setItems([doneButton], animated: true)
    textView.inputAccessoryView = toolBar
    
    textView.delegate = context.coordinator
    
    return textView
  }
  
  func updateUIView(_ uiView: UITextView, context: Context) {
    uiView.text = text
  }
  
  func makeCoordinator() -> Coordinator {
    Coordinator($text, didUpdate: self.didUpdate)
  }
  
  class Coordinator: NSObject, UITextViewDelegate {
    var text: Binding<String>
    public var didUpdate: ((_ text: String) -> ())?

    init(_ text: Binding<String>, didUpdate: ((_ text: String) -> ())?) {
      self.text = text
      self.didUpdate = didUpdate
    }
    
    func textViewDidChange(_ textView: UITextView) {
      self.text.wrappedValue = textView.text
      self.didUpdate?(textView.text)
    }
  }
}

extension UITextView {
  @objc func doneButtonTapped(button: UIBarButtonItem) -> Void {
    self.resignFirstResponder()
  }
}

