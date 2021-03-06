//
//  StringExtension.swift
//  Dash
//
//  Created by Yuji Nakayama on 2021/05/05.
//  Copyright © 2021 Yuji Nakayama. All rights reserved.
//

import Foundation

fileprivate let fullwidthAlphanumericsRegularExpression = try! NSRegularExpression(pattern: "[Ａ-Ｚａ-ｚ０-９]+")

extension String {
    func covertFullwidthAlphanumericsToHalfwidth() -> String {
        var string = self

        fullwidthAlphanumericsRegularExpression.enumerateMatches(in: string) { (result, flags, stop) in
            guard let matchingRange = result?.range else { return }
            let substring = string[matchingRange]
            guard let convertedSubstring = substring.applyingTransform(.fullwidthToHalfwidth, reverse: false) else { return }
            string = (string as NSString).replacingCharacters(in: matchingRange, with: convertedSubstring)
        }

        return string
    }

    func convertFullwidthWhitespacesToHalfwidth() -> String {
        return replacingOccurrences(of: "　", with: " ")
    }

    subscript(range: NSRange) -> String {
        return (self as NSString).substring(with: range)
    }
}
