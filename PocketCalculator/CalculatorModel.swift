import Foundation
import Combine

enum CalcOperation {
    case add, subtract, multiply, divide, power, none
}

class CalculatorModel: ObservableObject {
    @Published var display: String = "0"

    private var currentValue: Double = 0
    private var storedValue: Double = 0
    private var pendingOperation: CalcOperation = .none
    private var shouldResetDisplay: Bool = false
    private var hasDecimal: Bool = false
    private var justEvaluated: Bool = false

    // MARK: - Input Handling

    func digitTapped(_ digit: Int) {
        if justEvaluated {
            display = "\(digit)"
            hasDecimal = false
            justEvaluated = false
            shouldResetDisplay = false
            return
        }
        if shouldResetDisplay {
            display = "\(digit)"
            hasDecimal = false
            shouldResetDisplay = false
        } else {
            if display == "0" {
                display = "\(digit)"
            } else {
                if display.count < 10 {
                    display += "\(digit)"
                }
            }
        }
        currentValue = Double(display) ?? 0
    }

    func decimalTapped() {
        if justEvaluated {
            display = "0."
            hasDecimal = true
            justEvaluated = false
            shouldResetDisplay = false
            return
        }
        if shouldResetDisplay {
            display = "0."
            hasDecimal = true
            shouldResetDisplay = false
            return
        }
        if !hasDecimal {
            display += "."
            hasDecimal = true
        }
    }

    func piTapped() {
        let pi = Double.pi
        display = formatValue(pi)
        currentValue = pi
        hasDecimal = true
        shouldResetDisplay = false
        justEvaluated = false
    }

    // MARK: - Utility Operations

    func allClear() {
        display = "0"
        currentValue = 0
        storedValue = 0
        pendingOperation = .none
        shouldResetDisplay = false
        hasDecimal = false
        justEvaluated = false
    }

    func toggleSign() {
        if display == "0" { return }
        if display.hasPrefix("-") {
            display = String(display.dropFirst())
        } else {
            display = "-" + display
        }
        currentValue = Double(display) ?? 0
    }

    func percent() {
        currentValue = (Double(display) ?? 0) / 100.0
        display = formatValue(currentValue)
        hasDecimal = display.contains(".")
        justEvaluated = false
        shouldResetDisplay = false
    }

    // MARK: - Binary Operations

    func operationTapped(_ op: CalcOperation) {
        currentValue = Double(display) ?? 0
        if pendingOperation != .none && !shouldResetDisplay {
            evaluate()
            storedValue = currentValue
        } else {
            storedValue = currentValue
        }
        pendingOperation = op
        shouldResetDisplay = true
        hasDecimal = false
        justEvaluated = false
    }

    func equals() {
        currentValue = Double(display) ?? 0
        evaluate()
        pendingOperation = .none
        shouldResetDisplay = true
        hasDecimal = display.contains(".")
        justEvaluated = true
    }

    // MARK: - Private Helpers

    private func evaluate() {
        let rhs = currentValue
        let lhs = storedValue
        var result: Double = 0
        switch pendingOperation {
        case .add:
            result = lhs + rhs
        case .subtract:
            result = lhs - rhs
        case .multiply:
            result = lhs * rhs
        case .divide:
            if rhs == 0 {
                display = "Error"
                currentValue = 0
                storedValue = 0
                pendingOperation = .none
                shouldResetDisplay = true
                return
            }
            result = lhs / rhs
        case .power:
            result = pow(lhs, rhs)
        case .none:
            return
        }
        currentValue = result
        storedValue = result
        display = formatValue(result)
        hasDecimal = display.contains(".")
    }

    private func formatValue(_ value: Double) -> String {
        if value.isNaN || value.isInfinite {
            return "Error"
        }
        // Show as integer if it is a whole number
        if value == value.rounded() && abs(value) < 1_000_000_000 {
            return "\(Int(value))"
        }
        // Use up to 10 significant digits, trim trailing zeros
        let formatted = String(format: "%.10g", value)
        return formatted
    }
}
