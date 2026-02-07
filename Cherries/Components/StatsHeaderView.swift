import SwiftUI

struct StatsHeaderView: View {
    let stats: CheckInStats?

    var body: some View {
        HStack(spacing: 0) {
            StatItem(
                value: "\(stats?.totalCheckIns ?? 0)",
                label: "Check-ins",
                icon: "checkmark.circle.fill",
                color: AppColors.accent
            )

            Divider()
                .frame(height: 40)

            StatItem(
                value: "\(stats?.totalPoints ?? 0)",
                label: "Points",
                icon: "star.fill",
                color: AppColors.achievementOrange
            )

            Divider()
                .frame(height: 40)

            StatItem(
                value: "\(stats?.currentStreak ?? 0)",
                label: "Streak",
                icon: "flame.fill",
                color: AppColors.streakOrange
            )

            Divider()
                .frame(height: 40)

            StatItem(
                value: "\(stats?.longestStreak ?? 0)",
                label: "Best",
                icon: "trophy.fill",
                color: AppColors.achievementPurple
            )
        }
        .padding(.vertical, 16)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
}

struct StatItem: View {
    let value: String
    let label: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(spacing: 6) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 14))
                    .foregroundColor(color)

                Text(value)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.primary)
            }

            Text(label)
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    StatsHeaderView(stats: CheckInStats(
        questId: "1",
        userId: "user1",
        totalCheckIns: 15,
        totalPoints: 150,
        currentStreak: 5,
        longestStreak: 7
    ))
    .padding()
    .background(Color.gray.opacity(0.1))
}
