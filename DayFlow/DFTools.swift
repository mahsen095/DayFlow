import SwiftUI

enum DFTool: String, CaseIterable {
    case calculator = "Calculator"
    case notes = "Notes"
    case water = "Water"
    case checklist = "Checklist"

    var icon: String {
        switch self {
        case .calculator: return "calculator"
        case .notes: return "note.text"
        case .water: return "drop.fill"
        case .checklist: return "checklist"
        }
    }

    var color: Color {
        switch self {
        case .calculator: return DF.purple
        case .notes: return DF.coral
        case .water: return DF.blueColor
        case .checklist: return DF.green
        }
    }
}

struct DFTools: View {

    @ObservedObject var store: DFStore
    @State private var selected: DFTool = .calculator

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 23) {

                DFHeader(
                    eyebrow: "YOUR EVERYDAY TOOLKIT",
                    title: "Little tools.\nBig convenience.",
                    subtitle: "Everything you need, in one place."
                )

                LazyVGrid(
                    columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ],
                    spacing: 12
                ) {
                    ForEach(DFTool.allCases, id: \.self) { tool in
                        Button {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                selected = tool
                            }
                        } label: {
                            VStack(alignment: .leading, spacing: 13) {
                                Image(systemName: tool.icon)
                                    .font(.system(size: 22))
                                    .foregroundStyle(tool.color)
                                    .frame(width: 45, height: 45)
                                    .background(tool.color.opacity(0.13))
                                    .clipShape(RoundedRectangle(cornerRadius: 14))

                                Text(tool.rawValue)
                                    .font(.system(size: 15, weight: .bold))
                                    .foregroundStyle(DF.ink)

                                HStack {
                                    Text(selected == tool ? "OPEN NOW" : "EXPLORE")
                                        .font(.system(size: 9, weight: .bold))
                                        .tracking(1)
                                    Spacer()
                                    Image(systemName: "arrow.up.right")
                                        .font(.system(size: 10, weight: .bold))
                                }
                                .foregroundStyle(tool.color)
                            }
                            .padding(15)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(selected == tool ? tool.color.opacity(0.08) : DF.paper)
                            .overlay {
                                RoundedRectangle(cornerRadius: 19)
                                    .stroke(selected == tool ? tool.color.opacity(0.6) : .clear, lineWidth: 1.3)
                            }
                            .clipShape(RoundedRectangle(cornerRadius: 19))
                        }
                        .buttonStyle(.plain)
                    }
                }

                HStack {
                    Text(selected.rawValue)
                        .font(.system(size: 21, weight: .black))
                        .foregroundStyle(DF.ink)

                    Spacer()

                    DFTag(title: "OFFLINE", color: DF.green)
                }

                Group {
                    switch selected {
                    case .calculator:
                        DFCalculator()
                    case .notes:
                        DFNotes(store: store)
                    case .water:
                        DFWater(store: store)
                    case .checklist:
                        DFChecklist(store: store)
                    }
                }
                .id(selected)
            }
            .padding(19)
            .padding(.top, 15)
        }
    }
}
