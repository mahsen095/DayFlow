import SwiftUI

struct DFWater: View {

    @ObservedObject var store: DFStore

    private var progress: Double {
        min(Double(store.water) / Double(max(store.waterGoal, 1)), 1)
    }

    var body: some View {
        VStack(spacing: 20) {

            ZStack {
                Circle()
                    .fill(Color(hex: 0xE4F1FF))
                    .frame(width: 160, height: 160)

                Circle()
                    .stroke(DF.blueColor.opacity(0.16), lineWidth: 11)
                    .frame(width: 135, height: 135)

                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(
                        DF.blueColor,
                        style: StrokeStyle(lineWidth: 11, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))
                    .frame(width: 135, height: 135)

                VStack(spacing: 5) {
                    Image(systemName: "drop.fill")
                        .font(.system(size: 22))
                        .foregroundStyle(DF.blueColor)

                    Text("\(store.water)")
                        .font(.system(size: 29, weight: .black))
                        .foregroundStyle(DF.ink)

                    Text("GLASSES")
                        .font(.system(size: 9, weight: .bold))
                        .tracking(1)
                        .foregroundStyle(DF.muted)
                }
            }

            Text("\(store.water) of \(store.waterGoal) glasses")
                .font(.system(size: 17, weight: .bold))
                .foregroundStyle(DF.ink)

            Text(progress >= 1 ? "Daily goal reached. Well done!" : "Every glass is a small act of care.")
                .font(.system(size: 12))
                .foregroundStyle(DF.muted)

            HStack(spacing: 12) {
                Button {
                    store.water = max(0, store.water - 1)
                } label: {
                    Image(systemName: "minus")
                        .font(.system(size: 17, weight: .bold))
                        .foregroundStyle(DF.blueColor)
                        .frame(width: 50, height: 50)
                        .background(Color(hex: 0xE4F1FF))
                        .clipShape(Circle())
                }

                Button {
                    store.water += 1
                } label: {
                    Label("Add a glass", systemImage: "plus")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 23)
                        .frame(height: 50)
                        .background(DF.blueColor)
                        .clipShape(Capsule())
                }
            }

            Stepper("Daily goal: \(store.waterGoal) glasses", value: $store.waterGoal, in: 1...20)
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(DF.ink)

            Button("Reset count") {
                store.water = 0
            }
            .font(.system(size: 11, weight: .semibold))
            .foregroundStyle(DF.coral)
        }
        .frame(maxWidth: .infinity)
        .padding(20)
        .background(DF.paper)
        .clipShape(RoundedRectangle(cornerRadius: 22))
    }
}
