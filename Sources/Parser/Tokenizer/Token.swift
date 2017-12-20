//
//  Token.swift
//  Parser
//
//  Created by Franklin Schrans on 12/19/17.
//

import Foundation

public enum Token {

   public enum BinaryOperator: Character {
      case plus   = "+"
      case minus  = "-"
      case equal  = "="
      case dot    = "."
   }

   public enum Marker: String {
      case openBrace       = "{"
      case closeBrace      = "}"
      case colon           = ":"
      case doubleColon     = "::"
      case openBracket     = "("
      case closeBracket    = ")"
      case arrow           = "->"
   }

   // Keywords
   case contract
   case `var`
   case `func`
   case `mutating`
   case `return`
   case `public`

   // Operators
   case binaryOperator(BinaryOperator)

   // Markers
   case marker(Marker)

   // Identifiers
   case identifier(String)

   static let nonIdentifierMap: [String: Token] = [
      "contract": .contract,
      "var": .var,
      "func": .func,
      "mutating": .mutating,
      "return": .return,
      "public": .public,
      "+": .binaryOperator(.plus),
      "-": .binaryOperator(.minus),
      "=": .binaryOperator(.equal),
      ".": .binaryOperator(.dot),
      "{": .marker(.openBrace),
      "}": .marker(.closeBrace),
      ":": .marker(.colon),
      "::": .marker(.doubleColon),
      "(": .marker(.openBracket),
      ")": .marker(.closeBracket),
      "->": .marker(.arrow)
   ]

   static func splitOnMarkers(string: String) -> [String] {
      var components = [String]()
      var acc = ""

      for char in string {
         if CharacterSet.alphanumerics.contains(char.unicodeScalars.first!) {
            acc += String(char)
         } else {
            if !acc.isEmpty {
               components.append(acc)
               acc = ""
            }

            if let last = components.last {
               if last == ":", char == ":" {
                  components[components.endIndex.advanced(by: -1)] = "::"
                  continue
               } else if last == "-", char == ">" {
                  components[components.endIndex.advanced(by: -1)] = "->"
                  continue
               }
            }

            components.append(String(char))
         }
      }

      components.append(acc)
      return components.filter { !$0.isEmpty }
   }

   static func tokenize(string: String) -> [Token] {
      let components = splitOnMarkers(string: string)
      return components.flatMap { nonIdentifierMap[$0] ?? .identifier($0) }
   }

   init?(nonIdentifier: String) {
      guard let token = Token.nonIdentifierMap[nonIdentifier] else { return nil }
      self = token
   }
}

extension Token: Equatable {
   public static func ==(lhs: Token, rhs: Token) -> Bool {
      switch (lhs, rhs) {
        case (.contract, .contract): return true
        case (.var, .var): return true
        case (.func, .func): return true
        case (.mutating, .mutating): return true
        case (.return, .return): return true
        case (.public, .public): return true
        case (.binaryOperator(let operator1), .binaryOperator(let operator2)): return operator1 == operator2
        case (.marker(let marker1), .marker(let marker2)): return marker1 == marker2
        case (.identifier(let identifier1), .identifier(let identifier2)): return identifier1 == identifier2
      default:
         return false
      }
   }
}