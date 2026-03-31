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

    // MARK: - Digit Input

    func digitTapped(_ digit: Int) {
        if justEvaluated {
            display = "\(digit)"
            hasDecimal = false
            justEvaluated = false
            shouldResetDisplay = false
            currentValue = Double(digit)
            return
        }
        if shouldResetDisplay {
            display = "\(digit)"
            hasDecimal = false
            shouldResetDisplay = false
        } else {
            if display == "0" || display == "-0" {
                let sign = display.hasPrefix("-") ? "-" : ""
                display = sign + "\(digit)"
            } else {
                // Limit visible digits to avoid overflow
                let digitCount = display.filter { $0.isNumber }.count
                if digitCount < 9 {
                    display += "\(digit)"
                }
            }
        }
        currentValue = Double(display) ?? 0
    }

    // MARK: - Decimal Input

    func decimalTapped() {
        if justEvaluated {
            display = "0."
            hasDecimal = true
            justEvaluated = false
            shouldResetDisplay = false
            currentValue = 0
            return
        }
        if shouldResetDisplay {
            display = "0."
            hasDecimal = true
            shouldResetDisplay = false
            return
        }
        guard !hasDecimal else { return }
        display += "."
        hasDecimal = true
    }

    // MARK: - Pi

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
        guard display != "0", display != "Error" else { return }
        if display.hasPrefix("-") {
            display = String(display.dropFirst())
        } else {
            display = "-" + display
        }
        currentValue = Double(display) ?? 0
    }

    func percent() {
        guard display != "Error" else { return }
        currentValue = (Double(display) ?? 0) / 100.0
        display = formatValue(currentValue)
        hasDecimal = display.contains(".")
        justEvaluated = false
        shouldResetDisplay = false
    }

    // MARK: - Binary Operations

    func operationTapped(_ op: CalcOperation) {
        guard display != "Error" else { return }
        currentValue = Double(display) ?? 0
        // Chain operations: evaluate any pending op before storing new one
        if pendingOperation != .none && !shouldResetDisplay {
            evaluate()
        }
        storedValue = currentValue
        pendingOperation = op
        shouldResetDisplay = true
        hasDecimal = false
        justEvaluated = false
    }

    func equals() {
        guard display != "Error" else {
            allClear()
            return
        }
        currentValue = Double(display) ?? 0
        evaluate()
        pendingOperation = .none
        shouldResetDisplay = true
        hasDecimal = display.contains(".")
        justEvaluated = true
    }

    // MARK: - Private Evaluation

    private func evaluate() {
        let rhs = currentValue
        let lhs = storedValue
        var result: Double

        switch pendingOperation {
        case .add:
            result = lhs + rhs
        case .subtract:
            result = lhs - rhs
        case .multiply:
            result = lhs * rhs
        case .divide:
            guard rhs != 0 else {
                setError()
                return
            }
            result = lhs / rhs
        case .power:
            result = pow(lhs, rhs)
        case .none:
            return
        }

        guard !result.isNaN, !result.isInfinite else {
            setError()
            return
        }

        currentValue = result
        storedValue = result
        display = formatValue(result)
        hasDecimal = display.contains(".")
    }

    private func setError() {
        display = "Error"
        currentValue = 0
        storedValue = 0
        pendingOperation = .none
        shouldResetDisplay = true
    }

    // MARK: - Display Formatting

    private func formatValue(_ value: Double) -> String {
        guard !value.isNaN, !value.isInfinite else { return "Error" }

        // Show as integer when it's a whole number within safe integer range
        if value == value.rounded(.towardZero),
           abs(value) < 1_000_000_000,
           value == Double(Int(value)) {
            return "\(Int(value))"
        }

        // For very large or very small numbers, use scientific notation
        let absVal = abs(value)
        if absVal >= 1e10 || (absVal < 1e-6 && absVal > 0) {
            return String(format: "%.4e", value)
        }

        // Up to 10 significant figures, strip trailing zeros
        let formatted = String(format: "%.10g", value)
        return formatted
    }
}
