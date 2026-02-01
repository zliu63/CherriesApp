import SwiftUI

struct DeletableQuestCard: View {
    let quest: Quest
    let canDelete: Bool
    let onDelete: () -> Void

    @State private var offsetX: CGFloat = 0
    private let revealWidth: CGFloat = 88
    private let maxReveal: CGFloat = 100

    var body: some View {
        ZStack {
            // Background delete action (leading side for right swipe)
            HStack(spacing: 0) {
                if canDelete {
                    Button(role: .destructive) {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                            offsetX = 0
                        }
                        onDelete()
                    } label: {
                        Label("Delete", systemImage: "trash")
                            .font(.system(size: 16, weight: .semibold))
                            .frame(width: revealWidth)
                            .frame(maxHeight: .infinity)
                    }
                    .tint(.red)
                } else {
                    Color.clear.frame(width: 0)
                }
                Spacer(minLength: 0)
            }

            // Foreground card
            QuestCard(quest: quest)
                .offset(x: offsetX)
                .gesture(
                    DragGesture(minimumDistance: 10, coordinateSpace: .local)
                        .onChanged { value in
                            guard canDelete else { return }
                            let translation = value.translation.width
                            if translation > 0 { // right swipe to reveal
                                offsetX = min(maxReveal, translation)
                            } else { // left swipe to close
                                offsetX = max(0, offsetX + translation)
                            }
                        }
                        .onEnded { value in
                            guard canDelete else { return }
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                if offsetX > revealWidth * 0.6 {
                                    offsetX = revealWidth
                                } else {
                                    offsetX = 0
                                }
                            }
                        }
                )
                .animation(.spring(response: 0.3, dampingFraction: 0.8), value: offsetX)
        }
    }
}
