import SwiftUI

struct SignupView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var authManager: AuthManager

    @State private var email: String = ""
    @State private var username: String = ""
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    @State private var showPassword: Bool = false
    @State private var showConfirmPassword: Bool = false
    @State private var showError: Bool = false
    @State private var errorMessage: String = ""

    var body: some View {
        NavigationStack {
            ZStack {
                AppColors.background
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 32) {
                        // Logo and Title
                        VStack(spacing: 16) {
                            Image(systemName: "sparkles")
                                .font(.system(size: 80))
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [AppColors.addButtonStart, AppColors.addButtonEnd],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )

                            Text("Create Account")
                                .font(.system(size: 28, weight: .bold, design: .rounded))
                                .foregroundColor(.primary)

                            Text("Start your adventure today")
                                .font(.system(size: 16, design: .rounded))
                                .foregroundColor(.secondary)
                        }
                        .padding(.top, 40)

                        // Form Fields
                        VStack(spacing: 20) {
                            // Email Field
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Email")
                                    .font(.system(size: 14, weight: .medium, design: .rounded))
                                    .foregroundColor(.secondary)

                                HStack {
                                    Image(systemName: "envelope.fill")
                                        .foregroundColor(AppColors.addButtonStart)
                                        .frame(width: 20)

                                    TextField("Enter your email", text: $email)
                                        .font(.system(size: 16, design: .rounded))
                                        .textContentType(.emailAddress)
                                        .keyboardType(.emailAddress)
                                        .autocapitalization(.none)
                                        .disableAutocorrection(true)
                                }
                                .padding()
                                .background(Color.white)
                                .cornerRadius(12)
                                .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                            }

                            // Username Field
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Username")
                                    .font(.system(size: 14, weight: .medium, design: .rounded))
                                    .foregroundColor(.secondary)

                                HStack {
                                    Image(systemName: "person.fill")
                                        .foregroundColor(AppColors.addButtonStart)
                                        .frame(width: 20)

                                    TextField("Choose a username", text: $username)
                                        .font(.system(size: 16, design: .rounded))
                                        .textContentType(.username)
                                        .autocapitalization(.none)
                                        .disableAutocorrection(true)
                                }
                                .padding()
                                .background(Color.white)
                                .cornerRadius(12)
                                .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                            }

                            // Password Field
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Password")
                                    .font(.system(size: 14, weight: .medium, design: .rounded))
                                    .foregroundColor(.secondary)

                                HStack {
                                    Image(systemName: "lock.fill")
                                        .foregroundColor(AppColors.addButtonStart)
                                        .frame(width: 20)

                                    if showPassword {
                                        TextField("Create a password", text: $password)
                                            .font(.system(size: 16, design: .rounded))
                                            .textContentType(.newPassword)
                                            .autocapitalization(.none)
                                            .disableAutocorrection(true)
                                    } else {
                                        SecureField("Create a password", text: $password)
                                            .font(.system(size: 16, design: .rounded))
                                            .textContentType(.newPassword)
                                    }

                                    Button(action: { showPassword.toggle() }) {
                                        Image(systemName: showPassword ? "eye.slash.fill" : "eye.fill")
                                            .foregroundColor(.secondary)
                                    }
                                }
                                .padding()
                                .background(Color.white)
                                .cornerRadius(12)
                                .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                            }

                            // Confirm Password Field
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Confirm Password")
                                    .font(.system(size: 14, weight: .medium, design: .rounded))
                                    .foregroundColor(.secondary)

                                HStack {
                                    Image(systemName: "lock.shield.fill")
                                        .foregroundColor(AppColors.addButtonStart)
                                        .frame(width: 20)

                                    if showConfirmPassword {
                                        TextField("Confirm your password", text: $confirmPassword)
                                            .font(.system(size: 16, design: .rounded))
                                            .textContentType(.newPassword)
                                            .autocapitalization(.none)
                                            .disableAutocorrection(true)
                                    } else {
                                        SecureField("Confirm your password", text: $confirmPassword)
                                            .font(.system(size: 16, design: .rounded))
                                            .textContentType(.newPassword)
                                    }

                                    Button(action: { showConfirmPassword.toggle() }) {
                                        Image(systemName: showConfirmPassword ? "eye.slash.fill" : "eye.fill")
                                            .foregroundColor(.secondary)
                                    }
                                }
                                .padding()
                                .background(Color.white)
                                .cornerRadius(12)
                                .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)

                                // Password match indicator
                                if !confirmPassword.isEmpty {
                                    HStack(spacing: 4) {
                                        Image(systemName: passwordsMatch ? "checkmark.circle.fill" : "xmark.circle.fill")
                                            .font(.system(size: 12))
                                        Text(passwordsMatch ? "Passwords match" : "Passwords don't match")
                                            .font(.system(size: 12, design: .rounded))
                                    }
                                    .foregroundColor(passwordsMatch ? AppColors.accent : AppColors.primary)
                                    .padding(.top, 4)
                                }
                            }
                        }
                        .padding(.horizontal, 24)

                        // Signup Button
                        Button(action: signup) {
                            HStack {
                                if authManager.isLoading {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                } else {
                                    Text("Create Account")
                                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(
                                LinearGradient(
                                    colors: isFormValid ? [AppColors.addButtonStart, AppColors.addButtonEnd] : [Color.gray.opacity(0.5)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .foregroundColor(.white)
                            .cornerRadius(16)
                            .shadow(color: isFormValid ? AppColors.addButtonStart.opacity(0.4) : Color.clear, radius: 10, x: 0, y: 5)
                        }
                        .disabled(!isFormValid || authManager.isLoading)
                        .padding(.horizontal, 24)

                        // Login Link
                        HStack(spacing: 4) {
                            Text("Already have an account?")
                                .font(.system(size: 15, design: .rounded))
                                .foregroundColor(.secondary)

                            Button(action: { dismiss() }) {
                                Text("Sign In")
                                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                                    .foregroundColor(AppColors.addButtonStart)
                            }
                        }
                        .padding(.top, 8)

                        Spacer()
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.secondary)
                    }
                }
            }
            .alert("Error", isPresented: $showError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(errorMessage)
            }
            .onChange(of: authManager.isAuthenticated) { _, isAuthenticated in
                if isAuthenticated {
                    dismiss()
                }
            }
        }
    }

    private var passwordsMatch: Bool {
        password == confirmPassword && !password.isEmpty
    }

    private var isFormValid: Bool {
        !email.isEmpty &&
        !username.isEmpty &&
        !password.isEmpty &&
        email.contains("@") &&
        passwordsMatch &&
        password.count >= 6
    }

    private func signup() {
        guard passwordsMatch else {
            errorMessage = "Passwords don't match"
            showError = true
            return
        }

        Task {
            do {
                try await authManager.signup(email: email, username: username, password: password)
            } catch let error as APIError {
                errorMessage = error.localizedDescription
                showError = true
            } catch {
                errorMessage = "An unexpected error occurred"
                showError = true
            }
        }
    }
}

#Preview {
    SignupView(authManager: AuthManager.shared)
}
