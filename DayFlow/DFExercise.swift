import SwiftUI

struct DFExercise: View {

    @ObservedObject var store: DFStore
    @State private var selected: DFWorkout?

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 24) {

                DFHeader(
                    eyebrow: "YOUR MOVEMENT STUDIO",
                    title: "Find your\nflow.",
                    subtitle: "A little movement can change your day."
                )

                ZStack(alignment: .bottomLeading) {
                    RoundedRectangle(cornerRadius: 26)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color(hex: 0xE7A28B),
                                    Color(hex: 0xF3C2A9),
                                    Color(hex: 0xF9D8BD)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )

                    Circle()
                        .fill(.white.opacity(0.25))
                        .frame(width: 180, height: 180)
                        .offset(x: 210, y: -75)

                    VStack(alignment: .leading, spacing: 12) {
                        DFTag(title: "TODAY'S INSPIRATION", color: DF.ink)

                        Image(systemName: "figure.cooldown")
                            .font(.system(size: 43))
                            .foregroundStyle(DF.ink)
                            .padding(.top, 5)

                        Text("Move a little.\nFeel a lot.")
                            .font(.system(size: 27, weight: .black, design: .rounded))
                            .foregroundStyle(DF.ink)

                        Button {
                            selected = dfWorkouts[0]
                        } label: {
                            HStack {
                                Text("Explore workout")
                                Image(systemName: "arrow.right")
                            }
                            .font(.system(size: 12, weight: .bold))
                            .foregroundStyle(.white)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            .background(DF.ink)
                            .clipShape(Capsule())
                        }
                    }
                    .padding(21)
                }
                .frame(height: 255)
                .clipShape(RoundedRectangle(cornerRadius: 26))

                HStack(spacing: 12) {
                    workoutStat("Sessions", "\(store.sessions)", "trophy.fill", DF.purple)
                    workoutStat("Minutes", "\(store.workoutMinutes)", "timer", DF.green)
                }

                DFSection(title: "Your workout collection", detail: "5 ROUTINES")

                ForEach(dfWorkouts) { workout in
                    Button {
                        selected = workout
                    } label: {
                        HStack(spacing: 14) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 17)
                                    .fill(workout.color.opacity(0.14))

                                Image(systemName: workout.icon)
                                    .font(.system(size: 26, weight: .medium))
                                    .foregroundStyle(workout.color)
                            }
                            .frame(width: 59, height: 59)

                            VStack(alignment: .leading, spacing: 6) {
                                Text(workout.category)
                                    .font(.system(size: 9, weight: .bold))
                                    .tracking(1.2)
                                    .foregroundStyle(workout.color)

                                Text(workout.title)
                                    .font(.system(size: 15, weight: .bold))
                                    .foregroundStyle(DF.ink)

                                Text("\(workout.minutes) minutes • Beginner friendly")
                                    .font(.system(size: 10))
                                    .foregroundStyle(DF.muted)
                            }

                            Spacer()

                            Image(systemName: "play.circle.fill")
                                .font(.system(size: 29))
                                .foregroundStyle(workout.color)
                        }
                        .padding(14)
                        .background(DF.paper)
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                    }
                    .buttonStyle(.plain)
                }

                Text("Move at your own pace. Stop if you feel pain, dizziness or unusual discomfort.")
                    .font(.system(size: 11))
                    .foregroundStyle(DF.muted)
                    .padding(.bottom, 10)
            }
            .padding(19)
            .padding(.top, 15)
        }
        .sheet(item: $selected) { workout in
            DFWorkoutDetail(workout: workout, store: store)
        }
    }

    private func workoutStat(
        _ title: String,
        _ value: String,
        _ icon: String,
        _ color: Color
    ) -> some View {
        HStack(spacing: 11) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundStyle(color)

            VStack(alignment: .leading, spacing: 3) {
                Text(value)
                    .font(.system(size: 20, weight: .black))
                    .foregroundStyle(DF.ink)

                Text(title)
                    .font(.system(size: 10))
                    .foregroundStyle(DF.muted)
            }

            Spacer()
        }
        .padding(15)
        .frame(maxWidth: .infinity)
        .background(DF.paper)
        .clipShape(RoundedRectangle(cornerRadius: 18))
    }
}
