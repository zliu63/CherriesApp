import SwiftUI

struct ScoreboardView: View {
    let participants: [Participant]

    private var rankedParticipants: [Participant] {
        Array(participants.sorted { $0.totalPoints > $1.totalPoints }.prefix(3))
    }

    private func medal(for rank: Int) -> String {
        switch rank {
        case 0: return "🥇"
        case 1: return "🥈"
        case 2: return "🥉"
        default: return ""
        }
    }

    private func rowColor(for rank: Int) -> Color {
        switch rank {
        case 0: return Color(hex: "FFF8E1")
        case 1: return Color(hex: "F3F3F3")
        case 2: return Color(hex: "FBE9E7")
        default: return Color.white
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Image(systemName: "trophy.fill")
                    .foregroundColor(AppColors.achievementOrange)
                Text("Scoreboard")
                    .font(.system(size: 16, weight: .bold))
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)

            if rankedParticipants.isEmpty {
                Text("No participants yet")
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
                    .padding(.vertical, 16)
            } else {
                ForEach(Array(rankedParticipants.enumerated()), id: \.element.id) { index, participant in
                    HStack(spacing: 12) {
                        Text(medal(for: index))
                            .font(.system(size: 22))
                            .frame(width: 32)

                        AvatarView(
                            avatarData: participant.avatar,
                            size: 32,
                            showBorder: false
                        )

                        Text(participant.username ?? "Anonymous")
                            .font(.system(size: 15, weight: index == 0 ? .bold : .medium))
                            .lineLimit(1)

                        Spacer()

                        HStack(spacing: 4) {
                            Image(systemName: "star.fill")
                                .font(.system(size: 12))
                                .foregroundColor(AppColors.achievementOrange)
                            Text("\(participant.totalPoints)")
                                .font(.system(size: 15, weight: .bold))
                                .foregroundColor(AppColors.achievementOrange)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(rowColor(for: index))

                    if index < rankedParticipants.count - 1 {
                        Divider().padding(.leading, 60)
                    }
                }
            }
        }
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
}

#Preview {
    ScoreboardView(participants: [
        Participant(userId: "1", username: "Alice", avatar: AvatarData(type: "emoji", value: "🐶"), joinedAt: Date(), totalPoints: 250),
        Participant(userId: "2", username: "Bob", avatar: AvatarData(type: "emoji", value: "🐱"), joinedAt: Date(), totalPoints: 180),
        Participant(userId: "3", username: "Charlie", avatar: AvatarData(type: "emoji", value: "🐼"), joinedAt: Date(), totalPoints: 120),
    ])
    .padding()
    .background(Color(hex: "FFE8EC"))
}
