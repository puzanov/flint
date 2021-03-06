//
//  SemanticError.swift
//  SemanticAnalyzer
//
//  Created by Franklin Schrans on 1/4/18.
//

import AST

// MARK: Errors

extension Diagnostic {
  static func noMatchingFunctionForFunctionCall(_ functionCall: FunctionCall, contextCallerCapabilities: [CallerCapability], candidates: [FunctionInformation]) -> Diagnostic {

    let candidateNotes = candidates.map { candidate in
      return Diagnostic(severity: .note, sourceLocation: candidate.declaration.sourceLocation, message: "Perhaps you meant this function, which requires one of the caller capabilities in \(renderCapabilityGroup(candidate.callerCapabilities))")
    }

    return Diagnostic(severity: .error, sourceLocation: functionCall.sourceLocation, message: "Function \(functionCall.identifier.name) is not in scope or cannot be called using the caller capabilities \(renderCapabilityGroup(contextCallerCapabilities))", notes: candidateNotes)
  }

  static func contractBehaviorDeclarationNoMatchingContract(_ contractBehaviorDeclaration: ContractBehaviorDeclaration) -> Diagnostic {
    return Diagnostic(severity: .error, sourceLocation: contractBehaviorDeclaration.sourceLocation, message: "Contract behavior declaration for \(contractBehaviorDeclaration.contractIdentifier.name) has no associated contract declaration")
  }

  static func undeclaredCallerCapability(_ callerCapability: CallerCapability, contractIdentifier: Identifier) -> Diagnostic {
    return Diagnostic(severity: .error, sourceLocation: callerCapability.sourceLocation, message: "Caller capability \(callerCapability.name) is undefined in \(contractIdentifier.name) or has incompatible type")
  }

  static func useOfMutatingExpressionInNonMutatingFunction(_ expression: Expression, functionDeclaration: FunctionDeclaration) -> Diagnostic {
    return Diagnostic(severity: .error, sourceLocation: expression.sourceLocation, message: "Use of mutating statement in a nonmutating function")
  }

  static func payableFunctionDoesNotHavePayableValueParameter(_ functionDeclaration: FunctionDeclaration) -> Diagnostic {
    return Diagnostic(severity: .error, sourceLocation: functionDeclaration.sourceLocation, message: "\(functionDeclaration.identifier.name) is declared @payable but doesn't have an implicit parameter of a currency type")
  }

  static func ambiguousPayableValueParameter(_ functionDeclaration: FunctionDeclaration) -> Diagnostic {
    return Diagnostic(severity: .error, sourceLocation: functionDeclaration.sourceLocation, message: "Ambiguous implicit payable value parameter. Only one parameter can be declared implicit with a currency type")
  }

  static func useOfUndeclaredIdentifier(_ identifier: Identifier) -> Diagnostic {
    return Diagnostic(severity: .error, sourceLocation: identifier.sourceLocation, message: "Use of undeclared identifier \(identifier.name)")
  }

  static func missingReturnInNonVoidFunction(closeBraceToken: Token, resultType: Type) -> Diagnostic {
    return Diagnostic(severity: .error, sourceLocation: closeBraceToken.sourceLocation, message: "Missing return in function expected to return \(resultType.name)")
  }

  static func reassignmentToConstant(_ identifier: Identifier, _ declarationSourceLocation: SourceLocation) -> Diagnostic {
    let note = Diagnostic(severity: .note, sourceLocation: declarationSourceLocation, message: "'\(identifier.name)' is declared here")
    return Diagnostic(severity: .error, sourceLocation: identifier.sourceLocation, message: "Cannot assign to value: '\(identifier.name)' is a 'let' constant", notes: [note])
  }

  static func statePropertyDeclarationIsAssignedANonLiteralExpression(_ variableDeclaration: VariableDeclaration) -> Diagnostic {
    return Diagnostic(severity: .error, sourceLocation: variableDeclaration.sourceLocation, message: "The default value assigned to a state property must be a literal")
  }

  static func constantStatePropertyIsNotAssignedAValue(_ variableDeclaration: VariableDeclaration) -> Diagnostic {
    return Diagnostic(severity: .error, sourceLocation: variableDeclaration.sourceLocation, message: "'let' constant 'e' needs to be assigned a value")
  }

  static func renderCapabilityGroup(_ capabilities: [CallerCapability]) -> String {
    return "(\(capabilities.map({ $0.name }).joined(separator: ", ")))"
  }
}

// MARK: Warnings

extension Diagnostic {
  static func codeAfterReturn(_ statement: Statement) -> Diagnostic {
    return Diagnostic(severity: .warning, sourceLocation: statement.sourceLocation, message: "Code after return will never be executed")
  }

  static func functionCanBeDeclaredNonMutating(_ mutatingToken: Token) -> Diagnostic {
    return Diagnostic(severity: .warning, sourceLocation: mutatingToken.sourceLocation, message: "Function does not have to be declared mutating: none of its statements are mutating")
  }
}
