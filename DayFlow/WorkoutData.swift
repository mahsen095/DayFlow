import SwiftUI

let dfWorkouts: [DFWorkout] = [

    DFWorkout(
        title: "Morning Awakening",
        category: "FLEXIBILITY",
        minutes: 5,
        description: "A gentle routine to wake up your body and start fresh.",
        icon: "sun.max.fill",
        color: DF.coral,
        exercises: [
            "Neck rotations – 30 seconds",
            "Shoulder rolls – 30 seconds",
            "Standing side stretch – 1 minute",
            "Forward fold – 1 minute",
            "Arm stretches – 2 minutes"
        ]
    ),

    DFWorkout(
        title: "Full Body Energy",
        category: "STRENGTH",
        minutes: 10,
        description: "An accessible full-body routine using simple movements.",
        icon: "figure.strengthtraining.traditional",
        color: DF.purple,
        exercises: [
            "March in place – 1 minute",
            "Bodyweight squats – 2 minutes",
            "Wall push-ups – 2 minutes",
            "Standing lunges – 2 minutes",
            "Side steps – 2 minutes",
            "Cool down – 1 minute"
        ]
    ),

    DFWorkout(
        title: "Cardio Flow",
        category: "CARDIO",
        minutes: 8,
        description: "Get your body moving with an easy cardio session.",
        icon: "figure.run",
        color: DF.coral,
        exercises: [
            "March in place – 1 minute",
            "Step jacks – 2 minutes",
            "High knees – 1 minute",
            "Side steps – 2 minutes",
            "Slow walking – 2 minutes"
        ]
    ),

    DFWorkout(
        title: "Core Balance",
        category: "CORE",
        minutes: 12,
        description: "Build core stability with slow and controlled movements.",
        icon: "figure.core.training",
        color: DF.green,
        exercises: [
            "Standing knee raises – 2 minutes",
            "Bird dog – 2 minutes",
            "Dead bug – 2 minutes",
            "Modified plank – 2 minutes",
            "Glute bridge – 2 minutes",
            "Cool down – 2 minutes"
        ]
    ),

    DFWorkout(
        title: "Peaceful Recovery",
        category: "RELAXATION",
        minutes: 6,
        description: "Slow down, stretch and reconnect with your body.",
        icon: "figure.mind.and.body",
        color: DF.blueColor,
        exercises: [
            "Deep breathing – 1 minute",
            "Child's pose – 1 minute",
            "Seated stretch – 1 minute",
            "Cat and cow – 1 minute",
            "Relaxation – 2 minutes"
        ]
    )
]
