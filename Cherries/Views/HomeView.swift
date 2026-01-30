import SwiftUI

struct HomeView: View {
    @StateObject private var authManager = AuthManager.shared

    @State private var quests: [Quest] = []
    @State private var isLoadingQuests: Bool = false

    @State private var achievements: [Achievement] = [
        Achievement(id: UUID(), title: "First Quest", icon: "trophy.fill", color: Color(hex: "FFA726")),
        Achievement(id: UUID(), title: "3 Day Streak", icon: "star.fill", color: Color(hex: "7E57C2")),
        Achievement(id: UUID(), title: "Goal Master", icon: "target", color: Color(hex: "26A69A"))
    ]

    @State private var streakCount: Int = 3
    @State private var showAddQuest = false
    @State private var showLogin = false
    @State private var showProfilePopup = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Quest Cards Section
                    VStack(spacing: 16) {
                        if isLoadingQuests {
                            ProgressView()
                                .padding()
                        } else {
                            ForEach(quests) { quest in
                                QuestCard(quest: quest)
                            }

                            // Add New Quest Card
                            AddQuestCard {
                                showAddQuest = true
                            }
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 16)

                    // Recent Achievements Section
                    VStack(alignment: .leading, spacing: 16) {
                        Text("RECENT ACHIEVEMENTS")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(.secondary)
                            .tracking(1.2)
                            .padding(.horizontal, 24)

                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(achievements) { achievement in
                                    AchievementBadge(achievement: achievement)
                                }
                            }
                            .padding(.horizontal, 24)
                        }
                    }

                    Spacer(minLength: 40)
                }
            }
            .scrollContentBackground(.hidden)
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(hex: "FFE8EC"),
                        Color(hex: "E8F4FF"),
                        Color(hex: "F0E8FF")
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
            )
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    HStack(spacing: 8) {
                        CherryLogo(size: 32)
                        Text("Cherries")
                            .font(.system(size: 24, weight: .bold, design: .rounded))
                            .foregroundColor(Color(hex: "E91E63"))
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack(spacing: 16) {
                        // Streak Counter
                        HStack(spacing: 4) {
                            Image(systemName: "flame.fill")
                                .foregroundColor(Color(hex: "FF6B35"))
                            Text("\(streakCount)")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(Color(hex: "FF6B35"))
                        }

                        // Profile Button
                        Button(action: {
                            if authManager.isAuthenticated {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                    showProfilePopup = true
                                }
                            } else {
                                showLogin = true
                            }
                        }) {
                            if authManager.isAuthenticated {
                                AvatarView(
                                    avatarData: authManager.currentUser?.avatar,
                                    size: 36,
                                    showBorder: false
                                )
                            } else {
                                Circle()
                                    .fill(
                                        LinearGradient(
                                            gradient: Gradient(colors: [
                                                Color(hex: "26A69A"),
                                                Color(hex: "00BFA5")
                                            ]),
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .frame(width: 36, height: 36)
                                    .overlay(
                                        Image(systemName: "person")
                                            .foregroundColor(.white)
                                            .font(.system(size: 16, weight: .medium))
                                    )
                            }
                        }
                    }
                }
            }
        }
        .fullScreenCover(isPresented: $showAddQuest) {
            AddQuestView(quests: $quests)
        }
        .fullScreenCover(isPresented: $showLogin) {
            LoginView(authManager: authManager)
        }
        .overlay {
            if showProfilePopup {
                ProfilePopupView(authManager: authManager, isPresented: $showProfilePopup)
            }
        }
        .onAppear {
            loadQuests()
        }
    }

    private func loadQuests() {
        guard let token = authManager.accessToken else { return }

        isLoadingQuests = true

        Task {
            do {
                quests = try await QuestService.shared.getQuests(token: token)
            } catch {
                print("Failed to load quests: \(error)")
            }
            isLoadingQuests = false
        }
    }
}

#Preview {
    HomeView()
}
