import SwiftUI

struct AchievementBadge: View {
    let achievement: Achievement

    var body: some View {
        VStack(spacing: 12) {
            // Icon
            Image(systemName: achievement.icon)
                .font(.system(size: 32))
                .foregroundColor(.white.opacity(0.9))

            // Title
            Text(achievement.title)
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .lineLimit(2)
        }
        .frame(width: 100, height: 100)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(achievement.color)
        )
        .shadow(color: achievement.color.opacity(0.4), radius: 8, x: 0, y: 4)
    }
}

#Preview {
    HStack(spacing: 12) {
        AchievementBadge(achievement: Achievement(
            title: "First Quest",
            icon: "trophy.fill",
            color: Color(hex: "FFA726")
        ))

        AchievementBadge(achievement: Achievement(
            title: "3 Day Streak",
            icon: "star.fill",
            color: Color(hex: "7E57C2")
        ))

        AchievementBadge(achievement: Achievement(
            title: "Goal Master",
            icon: "target",
            color: Color(hex: "26A69A")
        ))
    }
    .padding()
    .background(Color(hex: "F8F9FA"))
}
