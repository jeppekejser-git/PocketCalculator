import SwiftUI

// MARK: - Button Style Enum

enum CalcButtonStyle {
    case number
    case utility
    case `operator`
    case special   // pi, x^y

    var background: Color {
        switch self {
        case .number:    return Color(red: 0.2,  green: 0.2,  blue: 0.2)
        case .utility:   return Color(red: 0.647, green: 0.647, blue: 0.647)
        case .operator:  return Color(red: 1.0,  green: 0.584, blue: 0.0)
        case .special:   return Color(red: 0.2,  green: 0.502, blue: 0.8)
        }
    }

    var foreground: Color {
        switch self {
        case .utility: return .black
        default:       return .white
        }
    }
}

// MARK: - Button Model

struct CalcButton: Identifiable {
    let id = UUID()
    let label: String
    let style: CalcButtonStyle
    var widthMultiplier: CGFloat = 1.0
}

// MARK: - Main View

struct ContentView: View {
    @StateObject private var model = CalculatorModel()

    // Button grid rows
    private let rows: [[CalcButton]] = [
        [
            CalcButton(label: "AC",  style: .utility),
            CalcButton(label: "+/-", style: .utility),
            CalcButton(label: "%",   style: .utility),
            CalcButton(label: "÷",   style: .operator)
        ],
        [
            CalcButton(label: "7", style: .number),
            CalcButton(label: "8", style: .number),
            CalcButton(label: "9", style: .number),
            CalcButton(label: "×", style: .operator)
        ],
        [
            CalcButton(label: "4", style: .number),
            CalcButton(label: "5", style: .number),
            CalcButton(label: "6", style: .number),
            CalcButton(label: "−", style: .operator)
        ],
        [
            CalcButton(label: "1", style: .number),
            CalcButton(label: "2", style: .number),
            CalcButton(label: "3", style: .number),
            CalcButton(label: "+", style: .operator)
        ],
        [
            CalcButton(label: "π",   style: .special),
            CalcButton(label: "0",   style: .number),
            CalcButton(label: ".",   style: .number),
            CalcButton(label: "=",   style: .operator)
        ]
    ]

    // Bottom extra row
    private let extraRow: CalcButton = CalcButton(label: "xʸ", style: .special)

    var body: some View {
        GeometryReader { geo in
            ZStack {
                Color.black.ignoresSafeArea()

                VStack(spacing: 0) {
                    Spacer()

                    // Display
                    displayArea
                        .padding(.horizontal, 24)
                        .padding(.bottom, 8)

                    // Main button grid
                    VStack(spacing: buttonSpacing(geo)) {
                        ForEach(rows.indices, id: \.self) { rowIndex in
                            HStack(spacing: buttonSpacing(geo)) {
                                ForEach(rows[rowIndex]) { btn in
                                    buttonView(btn, size: buttonSize(geo))
                                }
                            }
                        }

                        // x^y wide button
                        wideButtonView(extraRow, geo: geo)
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 16)
                }
            }
        }
    }

    // MARK: - Display

    private var displayArea: some View {
        HStack {
            Spacer()
            Text(model.display)
                .font(.system(size: displayFontSize(model.display), weight: .thin, design: .default))
                .foregroundColor(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.3)
                .frame(maxWidth: .infinity, alignment: .trailing)
        }
    }

    private func displayFontSize(_ text: String) -> CGFloat {
        let count = text.count
        if count <= 9  { return 80 }
        if count <= 12 { return 60 }
        return 40
    }

    // MARK: - Button Sizes

    private func buttonSpacing(_ geo: GeometryProxy) -> CGFloat {
        return (geo.size.width - 32) * 0.03
    }

    private func buttonSize(_ geo: GeometryProxy) -> CGFloat {
        let spacing = buttonSpacing(geo)
        return (geo.size.width - 32 - spacing * 3) / 4
    }

    // MARK: - Individual Button View

    @ViewBuilder
    private func buttonView(_ btn: CalcButton, size: CGFloat) -> some View {
        Button(action: { handleTap(btn.label) }) {
            Text(btn.label)
                .font(.system(size: size * 0.38, weight: .regular))
                .foregroundColor(btn.style.foreground)
                .frame(width: size, height: size)
                .background(btn.style.background)
                .clipShape(Circle())
        }
    }

    // MARK: - Wide Button View (x^y)

    @ViewBuilder
    private func wideButtonView(_ btn: CalcButton, geo: GeometryProxy) -> some View {
        let spacing = buttonSpacing(geo)
        let size = buttonSize(geo)
        let wideWidth = size * 2 + spacing

        Button(action: { handleTap(btn.label) }) {
            Text(btn.label)
                .font(.system(size: size * 0.38, weight: .regular))
                .foregroundColor(btn.style.foreground)
                .frame(width: wideWidth, height: size)
                .background(btn.style.background)
                .clipShape(RoundedRectangle(cornerRadius: size / 2))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.leading, 0)
    }

    // MARK: - Action Dispatch

    private func handleTap(_ label: String) {
        switch label {
        case "AC":   model.allClear()
        case "+/-":  model.toggleSign()
        case "%":    model.percent()
        case "÷":    model.operationTapped(.divide)
        case "×":    model.operationTapped(.multiply)
        case "−":    model.operationTapped(.subtract)
        case "+":    model.operationTapped(.add)
        case "xʸ":   model.operationTapped(.power)
        case "=":    model.equals()
        case "π":    model.piTapped()
        case ".":    model.decimalTapped()
        case "0":    model.digitTapped(0)
        case "1":    model.digitTapped(1)
        case "2":    model.digitTapped(2)
        case "3":    model.digitTapped(3)
        case "4":    model.digitTapped(4)
        case "5":    model.digitTapped(5)
        case "6":    model.digitTapped(6)
        case "7":    model.digitTapped(7)
        case "8":    model.digitTapped(8)
        case "9":    model.digitTapped(9)
        default:     break
        }
    }
}

// MARK: - Preview

#Preview {
    ContentView()
        .preferredColorScheme(.dark)
}
