//===----------------------------------------------------------------------===//
//
// This source file is part of the Swift.org open source project
//
// Copyright (c) 2014 - 2023 Apple Inc. and the Swift project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
// See https://swift.org/CONTRIBUTORS.txt for the list of Swift project authors
//
//===----------------------------------------------------------------------===//

import SwiftSyntax
import SwiftSyntaxBuilder
import SyntaxSupport
import Utils

let isLexerClassifiedFile = SourceFileSyntax(leadingTrivia: copyrightHeader) {
  DeclSyntax("import SwiftSyntax")

  try! ExtensionDeclSyntax(
    """
    extension Keyword
    """
  ) {
    try! VariableDeclSyntax(
      """
      /// Whether the token kind is switched from being an identifier to being a keyword in the lexer.
      /// This is true for keywords that used to be considered non-contextual.
      var isLexerClassified: Bool
      """
    ) {
      try! SwitchExprSyntax("switch self") {
        for keyword in KEYWORDS {
          if keyword.isLexerClassified {
            SwitchCaseSyntax("case .\(raw: keyword.escapedName): return true")
          }
        }
        SwitchCaseSyntax("default: return false")
      }
    }
  }

  try! ExtensionDeclSyntax(
    """
    extension TokenKind
    """
  ) {
    try! VariableDeclSyntax(
      """
      /// Returns `true` if the token is a Swift keyword.
      ///
      /// Keywords are reserved unconditionally for use by Swift and may not
      /// appear as identifiers in any position without being escaped. For example,
      /// `class`, `func`, or `import`.
      @_spi(Diagnostics) @_spi(Testing)
      public var isLexerClassifiedKeyword: Bool
      """
    ) {
      try! SwitchExprSyntax("switch self") {
        SwitchCaseSyntax("case .eof:") {
          StmtSyntax("return false")
        }

        for token in SYNTAX_TOKENS where token.isKeyword {
          SwitchCaseSyntax("case .\(raw: token.swiftKind):") {
            StmtSyntax("return true")
          }
        }

        SwitchCaseSyntax("case .keyword(let keyword):") {
          StmtSyntax("return keyword.isLexerClassified")
        }
        SwitchCaseSyntax("default: return false")
      }
    }
  }
}
