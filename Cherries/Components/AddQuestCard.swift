import SwiftUI

struct AddQuestCard: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 16) {
                // Plus Icon
                Circle()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color(hex: "E040FB"),
                                Color(hex: "EA80FC")
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 56, height: 56)
                    .overlay(
                        Image(systemName: "plus")
                            .font(.system(size: 28, weight: .medium))
                            .foregroundColor(.white)
                    )
                    .shadow(color: Color(hex: "E040FB").opacity(0.4), radius: 10, x: 0, y: 4)

                VStack(spacing: 4) {
                    Text("Add new quest!")
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)

                    Text("Start your next adventure")
                        .font(.system(size: 14, weight: .regular, design: .rounded))
                        .foregroundColor(.secondary)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 32)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .strokeBorder(
                        style: StrokeStyle(lineWidth: 2, dash: [8, 6])
                    )
                    .foregroundColor(Color.gray.opacity(0.3))
            )
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.white)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    AddQuestCard(action: {})
        .padding()
        .background(Color(hex: "F8F9FA"))
}
