import SwiftUI

struct DFCalculator: View {

    @State private var display = "0"
    @State private var stored: Double?
    @State private var operation: String?
    @State private var reset = false

    private let rows = [
        ["AC", "±", "%", "÷"],
        ["7", "8", "9", "×"],
        ["4", "5", "6", "−"],
        ["1", "2", "3", "+"],
        ["0", ".", "="]
    ]

    var body: some View {
        VStack(spacing: 11) {
            VStack(alignment: .trailing, spacing: 8) {
                Text("YOUR CALCULATION")
                    .font(.system(size: 9, weight: .bold))
                    .tracking(2)
                    .foregroundStyle(DF.muted)

                Text(display)
                    .font(.system(size: 42, weight: .black, design: .rounded))
                    .foregroundStyle(DF.ink)
                    .lineLimit(1)
                    .minimumScaleFactor(0.4)
            }
            .frame(maxWidth: .infinity, alignment: .trailing)
            .padding(20)
            .frame(height: 115)
            .background(DF.lavender.opacity(0.55))
            .clipShape(RoundedRectangle(cornerRadius: 19))

            ForEach(Array(rows.enumerated()), id: \.offset) { _, row in
                HStack(spacing: 9) {
                    ForEach(row, id: \.self) { key in
                        Button {
                            tap(key)
                        } label: {
                            Text(key)
                                .font(.system(size: 19, weight: .bold))
                                .foregroundStyle(foreground(key))
                                .frame(maxWidth: .infinity)
                                .frame(height: 57)
                                .background(background(key))
                                .clipShape(RoundedRectangle(cornerRadius: 15))
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
        .padding(15)
        .background(DF.paper)
        .clipShape(RoundedRectangle(cornerRadius: 22))
    }

    private func foreground(_ key: String) -> Color {
        if key == "=" { return .white }
        if ["÷", "×", "−", "+", "%"].contains(key) { return DF.purple }
        if ["AC", "±"].contains(key) { return DF.coral }
        return DF.ink
    }

    private func background(_ key: String) -> Color {
        if key == "=" { return DF.purple }
        if ["÷", "×", "−", "+", "%"].contains(key) { return DF.lavender }
        if ["AC", "±"].contains(key) { return DF.peach }
        return DF.bg
    }

    private func format(_ number: Double) -> String {
        guard number.isFinite else { return "Error" }
        if number.rounded() == number {
            return String(format: "%.0f", number)
        }
        return String(number)
    }

    private func tap(_ key: String) {
        switch key {
        case "AC":
            display = "0"
            stored = nil
            operation = nil
            reset = false

        case "±":
            if let n = Double(display) {
                display = format(-n)
            }

        case "%":
            if let n = Double(display) {
                display = format(n / 100)
            }

        case "+", "−", "×", "÷":
            stored = Double(display) ?? 0
            operation = key
            reset = true

        case "=":
            guard let first = stored,
                  let second = Double(display),
                  let op = operation else { return }

            var result = first

            switch op {
            case "+": result = first + second
            case "−": result = first - second
            case "×": result = first * second
            case "÷":
                guard second != 0 else {
                    display = "Error"
                    stored = nil
                    operation = nil
                    reset = true
                    return
                }
                result = first / second
            default: break
            }

            display = format(result)
            stored = nil
            operation = nil
            reset = true

        case ".":
            if reset {
                display = "0."
                reset = false
            } else if !display.contains(".") {
                display += "."
            }

        default:
            if reset || display == "0" || display == "Error" {
                display = key
                reset = false
            } else if display.count < 15 {
                display += key
            }
        }
    }
}
