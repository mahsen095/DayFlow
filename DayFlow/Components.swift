import SwiftUI

struct DFHeader: View {
    let eyebrow: String
    let title: String
    var subtitle: String = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(eyebrow.uppercased())
                .font(.system(size: 10, weight: .bold))
                .tracking(2)
                .foregroundStyle(DF.purple)

            Text(title)
                .font(.system(size: 29, weight: .black, design: .rounded))
                .foregroundStyle(DF.ink)

            if !subtitle.isEmpty {
                Text(subtitle)
                    .font(.system(size: 13))
                    .foregroundStyle(DF.muted)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct DFSection: View {
    let title: String
    var detail: String = ""

    var body: some View {
        HStack(alignment: .center) {
            Text(title)
                .font(.system(size: 19, weight: .bold, design: .rounded))
                .foregroundStyle(DF.ink)

            Spacer()

            if !detail.isEmpty {
                Text(detail)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(DF.muted)
            }
        }
    }
}

struct DFCard<Content: View>: View {
    var padding: CGFloat = 17
    @ViewBuilder var content: Content

    var body: some View {
        content
            .padding(padding)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(DF.paper)
            .clipShape(RoundedRectangle(cornerRadius: 23))
    }
}

struct DFTag: View {
    let title: String
    var color: Color = DF.purple

    var body: some View {
        Text(title)
            .font(.system(size: 10, weight: .bold))
            .foregroundStyle(color)
            .padding(.horizontal, 11)
            .padding(.vertical, 7)
            .background(color.opacity(0.12))
            .clipShape(Capsule())
    }
}

struct DFPrimaryButton: View {
    let title: String
    var icon: String = "arrow.right"
    var color: Color = DF.purple
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 9) {
                Text(title)
                    .font(.system(size: 14, weight: .bold))

                Image(systemName: icon)
                    .font(.system(size: 12, weight: .bold))
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(color)
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
        .buttonStyle(.plain)
    }
}

struct DFRing: View {
    let progress: Double
    let color: Color
    var size: CGFloat = 100
    var lineWidth: CGFloat = 10

    var body: some View {
        ZStack {
            Circle()
                .stroke(color.opacity(0.14), lineWidth: lineWidth)

            Circle()
                .trim(from: 0, to: min(max(progress, 0), 1))
                .stroke(
                    color,
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))

            Text("\(Int(progress * 100))%")
                .font(.system(size: size * 0.21, weight: .black))
                .foregroundStyle(DF.ink)
        }
        .frame(width: size, height: size)
    }
}
