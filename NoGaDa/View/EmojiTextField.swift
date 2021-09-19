//
//  EmojiTextField.swift
//  NoGaDa
//
//  Created by 이승기 on 2021/09/19.
//

import UIKit

class EmojiTextField: UITextField {

   // required for iOS 13
   override var textInputContextIdentifier: String? { "" }

    override var textInputMode: UITextInputMode? {
        for mode in UITextInputMode.activeInputModes {
            if mode.primaryLanguage == "emoji" {
                return mode
            }
        }
        return nil
    }
    
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        if action == #selector(UIResponderStandardEditActions.paste(_:)) {
            return false
        }
        return super.canPerformAction(action, withSender: sender)
    }
}

extension Character {
    
    var isEmoji: Bool {
        return unicodeScalars.count == 1 && unicodeScalars.first?.properties.isEmojiPresentation ?? false
    }
}
