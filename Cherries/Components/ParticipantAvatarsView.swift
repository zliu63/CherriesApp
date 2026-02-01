import SwiftUI

struct ParticipantAvatarsView: View {
    let participants: [Participant]
    let maxVisible: Int
    let avatarSize: CGFloat
    let overlap: CGFloat
    let borderWidth: CGFloat

    init(
        participants: [Participant],
        maxVisible: Int = 3,
        avatarSize: CGFloat = 24,
        overlap: CGFloat = 8,
        borderWidth: CGFloat = 2
    ) {
        self.participants = participants
        self.maxVisible = maxVisible
        self.avatarSize = avatarSize
        self.overlap = overlap
        self.borderWidth = borderWidth
    }

    private var visibleParticipants: [Participant] {
        Array(participants.prefix(maxVisible))
    }

    private var extraCount: Int {
        max(0, participants.count - maxVisible)
    }

    var body: some View {
        HStack(spacing: -overlap) {
            ForEach(Array(visibleParticipants.enumerated()), id: \.element.id) { index, participant in
                AvatarView(
                    avatarData: participant.avatar,
                    size: avatarSize,
                    showBorder: false
                )
                .overlay(
                    Circle()
                        .stroke(Color.white, lineWidth: borderWidth)
                )
                .zIndex(Double(maxVisible - index))
            }

            if extraCount > 0 {
                ZStack {
                    Circle()
                        .fill(Color.white.opacity(0.3))

                    Text("+\(extraCount)")
                        .font(.system(size: avatarSize * 0.4, weight: .semibold))
                        .foregroundColor(.white)
                }
                .frame(width: avatarSize, height: avatarSize)
                .overlay(
                    Circle()
                        .stroke(Color.white, lineWidth: borderWidth)
                )
                .zIndex(0)
            }
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        // 1 participant
        ParticipantAvatarsView(
            participants: [
                Participant(
                    userId: "1",
                    username: "User1",
                    avatar: AvatarData(type: "emoji", value: "🐶"),
                    joinedAt: Date(),
                    totalPoints: 0
                )
            ]
        )

        // 3 participants
        ParticipantAvatarsView(
            participants: [
                Participant(
                    userId: "1",
                    username: "User1",
                    avatar: AvatarData(type: "emoji", value: "🐶"),
                    joinedAt: Date(),
                    totalPoints: 0
                ),
                Participant(
                    userId: "2",
                    username: "User2",
                    avatar: AvatarData(type: "emoji", value: "🐱"),
                    joinedAt: Date(),
                    totalPoints: 0
                ),
                Participant(
                    userId: "3",
                    username: "User3",
                    avatar: AvatarData(type: "emoji", value: "🐼"),
                    joinedAt: Date(),
                    totalPoints: 0
                )
            ]
        )

        // 5 participants (shows +2)
        ParticipantAvatarsView(
            participants: [
                Participant(
                    userId: "1",
                    username: "User1",
                    avatar: AvatarData(type: "emoji", value: "🐶"),
                    joinedAt: Date(),
                    totalPoints: 0
                ),
                Participant(
                    userId: "2",
                    username: "User2",
                    avatar: AvatarData(type: "emoji", value: "🐱"),
                    joinedAt: Date(),
                    totalPoints: 0
                ),
                Participant(
                    userId: "3",
                    username: "User3",
                    avatar: AvatarData(type: "emoji", value: "🐼"),
                    joinedAt: Date(),
                    totalPoints: 0
                ),
                Participant(
                    userId: "4",
                    username: "User4",
                    avatar: AvatarData(type: "emoji", value: "🐨"),
                    joinedAt: Date(),
                    totalPoints: 0
                ),
                Participant(
                    userId: "5",
                    username: "User5",
                    avatar: AvatarData(type: "emoji", value: "🦊"),
                    joinedAt: Date(),
                    totalPoints: 0
                )
            ]
        )
    }
    .padding()
    .background(
        LinearGradient(
            gradient: Gradient(colors: [
                Color(hex: "00D9B5"),
                Color(hex: "00B4D8"),
                Color(hex: "4C8BF5")
            ]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    )
}
