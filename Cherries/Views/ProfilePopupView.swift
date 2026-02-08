import SwiftUI

struct ProfilePopupView: View {
    @ObservedObject var authManager: AuthManager
    @Binding var isPresented: Bool
    @StateObject private var viewModel = ProfileViewModel()

    let animalAvatars = [
        ("🐶", "Puppy", Color(hex: "FFD54F")),
        ("🐱", "Kitty", Color(hex: "FF8A80")),
        ("🐼", "Panda", Color(hex: "B9F6CA")),
        ("🐨", "Koala", Color(hex: "B0BEC5")),
        ("🦊", "Fox", Color(hex: "FFAB91")),
        ("🐰", "Bunny", Color(hex: "F8BBD0")),
        ("🐻", "Bear", Color(hex: "BCAAA4")),
        ("🐸", "Frog", Color(hex: "A5D6A7"))
    ]

    @State private var selectedAvatar: Int = 0
    @State private var editingUsername = false
    @State private var usernameText = ""
    @State private var showSaveSuccess = false

    var body: some View {
        ZStack {
            // Dimmed background
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                        isPresented = false
                    }
                }

            // Popup content
            VStack(spacing: 0) {
                // Header
                HStack {
                    Text("Profile")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundColor(Color(hex: "E91E63"))

                    Spacer()

                    Button(action: {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                            isPresented = false
                        }
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 24))
                            .foregroundColor(.secondary.opacity(0.5))
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 24)
                .padding(.bottom, 16)

                // User info
                if let user = authManager.currentUser {
                    VStack(spacing: 8) {
                        if editingUsername {
                            HStack(spacing: 8) {
                                TextField("Username", text: $usernameText)
                                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                                    .textFieldStyle(.plain)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 8)
                                    .background(Color(hex: "F8BBD0").opacity(0.2))
                                    .cornerRadius(12)
                                    .multilineTextAlignment(.center)

                                Button(action: {
                                    let name = usernameText.trimmingCharacters(in: .whitespaces)
                                    guard !name.isEmpty else { return }
                                    Task {
                                        await viewModel.saveUsername(name)
                                        if viewModel.errorMessage == nil {
                                            editingUsername = false
                                            showSaveSuccess = true
                                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                                                showSaveSuccess = false
                                            }
                                        }
                                    }
                                }) {
                                    if viewModel.isSaving {
                                        ProgressView()
                                            .frame(width: 32, height: 32)
                                    } else {
                                        Image(systemName: "checkmark.circle.fill")
                                            .font(.system(size: 24))
                                            .foregroundColor(Color(hex: "E91E63"))
                                    }
                                }
                                .disabled(viewModel.isSaving)
                            }
                            .padding(.horizontal, 24)
                        } else {
                            HStack(spacing: 6) {
                                Text(user.username ?? "User")
                                    .font(.system(size: 20, weight: .semibold, design: .rounded))
                                    .foregroundColor(.primary)

                                Button(action: {
                                    usernameText = user.username ?? ""
                                    editingUsername = true
                                }) {
                                    Image(systemName: "pencil.circle.fill")
                                        .font(.system(size: 18))
                                        .foregroundColor(Color(hex: "E91E63").opacity(0.6))
                                }
                            }
                        }

                        if showSaveSuccess {
                            Text("Saved!")
                                .font(.system(size: 13, weight: .medium, design: .rounded))
                                .foregroundColor(Color(hex: "4CAF50"))
                        }

                        if let error = viewModel.errorMessage {
                            Text(error)
                                .font(.system(size: 13, weight: .medium, design: .rounded))
                                .foregroundColor(.red)
                        }

                        Text(user.email)
                            .font(.system(size: 14, weight: .regular))
                            .foregroundColor(.secondary)
                    }
                    .padding(.bottom, 20)
                }

                // Avatar selection title
                Text("Choose Your Avatar")
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundColor(.secondary)
                    .padding(.bottom, 16)

                // Animal avatars grid
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible()),
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 12) {
                    ForEach(Array(animalAvatars.enumerated()), id: \.offset) { index, avatar in
                        Button(action: {
                            selectedAvatar = index
                            // Save avatar selection
                            Task {
                                await saveAvatar(emoji: avatar.0)
                            }
                        }) {
                            VStack(spacing: 4) {
                                ZStack {
                                    Circle()
                                        .fill(avatar.2.opacity(0.3))
                                        .frame(width: 64, height: 64)

                                    Text(avatar.0)
                                        .font(.system(size: 32))

                                    if selectedAvatar == index {
                                        Circle()
                                            .stroke(Color(hex: "E91E63"), lineWidth: 3)
                                            .frame(width: 64, height: 64)
                                    }
                                }

                                Text(avatar.1)
                                    .font(.system(size: 11, weight: .medium, design: .rounded))
                                    .foregroundColor(.secondary)
                            }
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 24)

                Divider()
                    .padding(.horizontal, 24)
                    .padding(.bottom, 16)

                // Logout button
                Button(action: {
                    Task {
                        await authManager.logout()
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                            isPresented = false
                        }
                    }
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: "arrow.right.square.fill")
                            .font(.system(size: 18, weight: .semibold))

                        Text("Logout")
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color(hex: "E91E63"),
                                Color(hex: "EC407A")
                            ]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(16)
                    .shadow(color: Color(hex: "E91E63").opacity(0.3), radius: 8, x: 0, y: 4)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 24)
            }
            .background(Color.white)
            .cornerRadius(24)
            .shadow(color: .black.opacity(0.15), radius: 20, x: 0, y: 10)
            .padding(.horizontal, 32)
            .transition(.scale(scale: 0.8).combined(with: .opacity))
            .onAppear {
                // Load currently selected avatar from user data
                if let avatar = authManager.currentUser?.avatar,
                   avatar.type == "emoji",
                   let index = animalAvatars.firstIndex(where: { $0.0 == avatar.value }) {
                    selectedAvatar = index
                }
            }
        }
    }

    private func saveAvatar(emoji: String) async {
        await viewModel.saveAvatar(emoji: emoji)
    }
}

#Preview {
    ProfilePopupView(
        authManager: AuthManager.shared,
        isPresented: .constant(true)
    )
}
