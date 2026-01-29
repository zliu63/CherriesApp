import SwiftUI

struct QuestCard: View {
    let quest: Quest

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(quest.title)
                        .font(.system(size: 22, weight: .bold, design: .rounded))
                        .foregroundColor(.white)

                    Text(quest.subtitle)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white.opacity(0.9))
                }

                Spacer()

                // Toggle/Checkbox
                Circle()
                    .fill(.white)
                    .frame(width: 48, height: 28)
                    .overlay(
                        Circle()
                            .fill(Color.white)
                            .frame(width: 24, height: 24)
                            .offset(x: quest.isActive ? 8 : -8),
                        alignment: quest.isActive ? .trailing : .leading
                    )
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

            // Action Buttons
            HStack(spacing: 12) {
                Button(action: {}) {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(.white)
                        .frame(height: 40)
                }

                Button(action: {}) {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(.white)
                        .frame(height: 40)
                }
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
    }
}

#Preview {
    QuestCard(quest: Quest(
        title: "My first quest",
        subtitle: "Continue your journey",
        progress: 0.65
    ))
    .padding()
    .background(Color(hex: "F8F9FA"))
}
