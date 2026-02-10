import SwiftUI

struct QuestCard: View {
    let quest: Quest
    var onTap: (() -> Void)? = nil

    @State private var showShareSheet = false

    var body: some View {
        cardContent
            .contentShape(Rectangle())
            .onTapGesture {
                onTap?()
            }
    }

    private var cardContent: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(quest.name)
                        .font(.system(size: 22, weight: .bold, design: .rounded))
                        .foregroundColor(.white)

                    Text(quest.dateRange)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white.opacity(0.9))
                }

                Spacer()

                // Share code button
                Button(action: {
                    showShareSheet = true
                }) {
                    Image(systemName: "square.and.arrow.up")
                        .foregroundColor(.white)
                        .font(.system(size: 20))
                }
            }

            // Progress Section
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Progress")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white.opacity(0.9))

                    Spacer()

                    Text("\(quest.progressPercentage)%")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                }

                // Progress Bar
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(.white.opacity(0.3))
                            .frame(height: 12)

                        RoundedRectangle(cornerRadius: 8)
                            .fill(.white)
                            .frame(width: geometry.size.width * quest.progress, height: 12)
                    }
                }
                .frame(height: 12)
            }

            // Stats
            HStack {
                Text("\(quest.dailyTasks.count) tasks")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white.opacity(0.8))

                Spacer()

                ParticipantAvatarsView(
                    participants: quest.participants,
                    maxVisible: 3,
                    avatarSize: 24,
                    overlap: 8,
                    borderWidth: 2
                )
            }
        }
        .padding(20)
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
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: Color(hex: "00B4D8").opacity(0.3), radius: 15, x: 0, y: 8)
        .sheet(isPresented: $showShareSheet) {
            ShareSheet(items: ["Come and join my adventure! Use this code \(quest.shareCode) to join!"])
        }
    }
}

// MARK: - Share Sheet
struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

#Preview {
    QuestCard(quest: Quest(
        id: "1",
        name: "My first quest",
        description: "Continue your journey",
        startDate: Date(),
        endDate: Date().addingTimeInterval(7 * 24 * 60 * 60),
        creatorId: "user1",
        shareCode: "123456789",
        shareCodeExpiresAt: Date().addingTimeInterval(3 * 24 * 60 * 60),
        createdAt: Date(),
        updatedAt: nil,
        dailyTasks: [],
        participants: [
            Participant(
                userId: "user1",
                username: "Creator",
                avatar: AvatarData(type: "emoji", value: "🐶"),
                joinedAt: Date(),
                totalPoints: 100
            ),
            Participant(
                userId: "user2",
                username: "Friend1",
                avatar: AvatarData(type: "emoji", value: "🐱"),
                joinedAt: Date(),
                totalPoints: 50
            ),
        ]
    ))
    .padding()
    .background(Color(hex: "F8F9FA"))
}
