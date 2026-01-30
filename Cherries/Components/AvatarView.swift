import SwiftUI

struct AvatarView: View {
    let avatarData: AvatarData?
    let size: CGFloat
    let showBorder: Bool

    init(avatarData: AvatarData?, size: CGFloat, showBorder: Bool = false) {
        self.avatarData = avatarData
        self.size = size
        self.showBorder = showBorder
    }

    // Emoji to color mapping (matching ProfilePopupView)
    private let emojiColors: [String: Color] = [
        "🐶": Color(hex: "FFD54F"),  // Puppy - Yellow
        "🐱": Color(hex: "FF8A80"),  // Kitty - Pink
        "🐼": Color(hex: "B9F6CA"),  // Panda - Green
        "🐨": Color(hex: "B0BEC5"),  // Koala - Gray
        "🦊": Color(hex: "FFAB91"),  // Fox - Orange
        "🐰": Color(hex: "F8BBD0"),  // Bunny - Light Pink
        "🐻": Color(hex: "BCAAA4"),  // Bear - Brown
        "🐸": Color(hex: "A5D6A7")   // Frog - Light Green
    ]

    private var defaultGradient: LinearGradient {
        LinearGradient(
            gradient: Gradient(colors: [
                Color(hex: "26A69A"),
                Color(hex: "00BFA5")
            ]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    private func backgroundForEmoji(_ emoji: String) -> Color {
        emojiColors[emoji] ?? Color(hex: "26A69A")
    }

    var body: some View {
        Group {
            switch avatarData?.type {
            case "emoji":
                // Display emoji with its specific background color
                if let emoji = avatarData?.value {
                    ZStack {
                        Circle()
                            .fill(backgroundForEmoji(emoji).opacity(0.3))

                        Text(emoji)
                            .font(.system(size: size * 0.5))
                    }
                } else {
                    defaultAvatar
                }
            case "preset", "custom":
                // Future: Display AsyncImage for URLs
                if let urlString = avatarData?.value,
                   let url = URL(string: urlString) {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .empty:
                            ProgressView()
                        case .success(let image):
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                        case .failure:
                            defaultAvatar
                        @unknown default:
                            defaultAvatar
                        }
                    }
                } else {
                    defaultAvatar
                }
            default:
                // Default avatar for nil or unknown types
                defaultAvatar
            }
        }
        .frame(width: size, height: size)
        .clipShape(Circle())
        .overlay(
            Circle()
                .stroke(Color(hex: "E91E63"), lineWidth: showBorder ? 3 : 0)
        )
    }

    private var defaultAvatar: some View {
        ZStack {
            Circle()
                .fill(defaultGradient)

            Image(systemName: "person.fill")
                .foregroundColor(.white)
                .font(.system(size: size * 0.4, weight: .medium))
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        AvatarView(
            avatarData: AvatarData(type: "emoji", value: "🐶"),
            size: 60,
            showBorder: false
        )

        AvatarView(
            avatarData: AvatarData(type: "emoji", value: "🐱"),
            size: 60,
            showBorder: true
        )

        AvatarView(
            avatarData: nil,
            size: 60,
            showBorder: false
        )
    }
    .padding()
}
