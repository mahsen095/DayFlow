import SwiftUI

struct DFWorkoutDetail: View {

    let workout: DFWorkout
    @ObservedObject var store: DFStore
    @Environment(\.dismiss) var dismiss

    @State private var remaining = 0
    @State private var running = false
    @State private var finished = false

    private let timer = Timer.publish(
        every: 1,
        on: .main,
        in: .common
    ).autoconnect()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 22) {

                    ZStack {
                        Circle()
                            .fill(workout.color.opacity(0.13))
                            .frame(width: 140, height: 140)

                        Image(systemName: workout.icon)
                            .font(.system(size: 55))
                            .foregroundStyle(workout.color)
                    }
                    .padding(.top, 15)

                    Text(workout.title)
                        .font(.system(size: 27, weight: .black, design: .rounded))
                        .foregroundStyle(DF.ink)

                    Text(workout.description)
                        .font(.system(size: 13))
                        .foregroundStyle(DF.muted)
                        .multilineTextAlignment(.center)

                    DFCard {
                        Text(timeString)
                            .font(.system(size: 48, weight: .black, design: .rounded))
                            .monospacedDigit()
                            .foregroundStyle(DF.ink)
                            .frame(maxWidth: .infinity)

                        Text(finished ? "SESSION COMPLETE" : running ? "KEEP GOING" : "READY WHEN YOU ARE")
                            .font(.system(size: 10, weight: .bold))
                            .tracking(2)
                            .foregroundStyle(workout.color)
                            .frame(maxWidth: .infinity)
                    }

                    DFSection(title: "Your routine")

                    ForEach(Array(workout.exercises.enumerated()), id: \.offset) { index, exercise in
                        HStack(spacing: 13) {
                            Text(String(format: "%02d", index + 1))
                                .font(.system(size: 13, weight: .black))
                                .foregroundStyle(workout.color)
                                .frame(width: 37, height: 37)
                                .background(workout.color.opacity(0.12))
                                .clipShape(Circle())

                            Text(exercise)
                                .font(.system(size: 13, weight: .medium))
                                .foregroundStyle(DF.ink)

                            Spacer()
                        }
                        .padding(12)
                        .background(DF.paper)
                        .clipShape(RoundedRectangle(cornerRadius: 15))
                    }

                    if !finished {
                        DFPrimaryButton(
                            title: running ? "Pause Session" : remaining == 0 ? "Start Workout" : "Resume Workout",
                            icon: running ? "pause.fill" : "play.fill",
                            color: workout.color
                        ) {
                            if remaining == 0 {
                                remaining = workout.minutes * 60
                            }
                            running.toggle()
                        }
                    } else {
                        DFPrimaryButton(
                            title: "Save My Progress",
                            icon: "checkmark",
                            color: DF.green
                        ) {
                            store.sessions += 1
                            store.workoutMinutes += workout.minutes
                            dismiss()
                        }
                    }
                }
                .padding(20)
            }
            .background(DF.bg)
            .navigationTitle("Workout")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Close") {
                        running = false
                        dismiss()
                    }
                    .foregroundStyle(DF.purple)
                }
            }
            .onReceive(timer) { _ in
                guard running, remaining > 0 else { return }

                remaining -= 1

                if remaining == 0 {
                    running = false
                    finished = true
                }
            }
            .onDisappear {
                running = false
            }
        }
    }

    private var timeString: String {
        String(format: "%02d:%02d", remaining / 60, remaining % 60)
    }
}
