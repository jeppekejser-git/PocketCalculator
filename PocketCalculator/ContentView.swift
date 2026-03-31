import SwiftUI

// MARK: - Button Style Enum

enum CalcButtonStyle {
    case number
    case utility
    case `operator`
    case special   // pi, x^y

    var background: Color {
        switch self {
        case .number:   return Color(red: 0.200, green: 0.200, blue: 0.200)
        case .utility:  return Color(red: 0.647, green: 0.647, blue: 0.647)
        case .operator: return Color(red: 1.000, green: 0.584, blue: 0.000)
        case .special:  return Color(red: 0.200, green: 0.502, blue: 0.800)
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
}

// MARK: - Main View

struct ContentView: View {
    @StateObject private var model = CalculatorModel()

    // Button grid: rows 0-4 (4 columns each)
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

    var body: some View {
        GeometryReader { geo in
            ZStack {
                Color.black.ignoresSafeArea()

                VStack(spacing: 0) {
                    Spacer(minLength: 0)

                    // Display
                    displayArea
                        .padding(.horizontal, 24)
                        .padding(.bottom, 12)

                    // Main button grid + x^y row
                    buttonGrid(geo: geo)
                        .padding(.horizontal, 16)
                        .padding(.bottom, max(geo.safeAreaInsets.bottom, 16))
                }
            }
        }
    }

    // MARK: - Display

    private var displayArea: some View {
        Text(model.display)
            .font(.system(size: displayFontSize(model.display), weight: .thin, design: .default))
            .foregroundColor(.white)
            .lineLimit(1)
            .minimumScaleFactor(0.3)
            .frame(maxWidth: .infinity, alignment: .trailing)
    }

    private func displayFontSize(_ text: String) -> CGFloat {
        let count = text.count
        if count <= 9  { return 80 }
        if count <= 12 { return 60 }
        return 40
    }

    // MARK: - Button Grid

    private func buttonGrid(geo: GeometryProxy) -> some View {
        let spacing = buttonSpacing(geo)
        let size    = buttonSize(geo)

        return VStack(spacing: spacing) {
            // Rows 0-4: four equal-sized buttons per row
            ForEach(rows.indices, id: \.self) { rowIndex in
                HStack(spacing: spacing) {
                    ForEach(rows[rowIndex]) { btn in
                        roundButton(label: btn.label,
                                    style: btn.style,
                                    width: size,
                                    height: size,
                                    fontSize: size * 0.38,
                                    cornerRadius: size / 2)
                    }
                }
            }

            // x^y: wide button spanning ~2 cells
            HStack(spacing: spacing) {
                roundButton(label: "xʸ",
                            style: .special,
                            width: size * 2 + spacing,
                            height: size,
                            fontSize: size * 0.38,
                            cornerRadius: size / 2)
                Spacer()
            }
        }
    }

    // MARK: - Reusable Rounded Button

    private func roundButton(label: String,
                             style: CalcButtonStyle,
                             width: CGFloat,
                             height: CGFloat,
                             fontSize: CGFloat,
                             cornerRadius: CGFloat) -> some View {
        Button(action: { handleTap(label) }) {
            Text(label)
                .font(.system(size: fontSize, weight: .regular))
                .foregroundColor(style.foreground)
                .frame(width: width, height: height)
                .background(style.background)
                .clipShape(RoundedRectangle(cornerRadius: cornerRadius,
                                            style: .continuous))
        }
        .buttonStyle(CalcButtonPressStyle())
    }

    // MARK: - Sizing Helpers

    private func buttonSpacing(_ geo: GeometryProxy) -> CGFloat {
        (geo.size.width - 32) * 0.030
    }

    private func buttonSize(_ geo: GeometryProxy) -> CGFloat {
        let spacing = buttonSpacing(geo)
        return (geo.size.width - 32 - spacing * 3) / 4
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

// MARK: - Button Press Style (subtle scale feedback)

struct CalcButtonPressStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.94 : 1.0)
            .animation(.easeInOut(duration: 0.08), value: configuration.isPressed)
    }
}

// MARK: - Preview

#Preview {
    ContentView()
        .preferredColorScheme(.dark)
}
