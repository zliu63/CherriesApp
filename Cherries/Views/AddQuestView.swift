import SwiftUI

struct AddQuestView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var quests: [Quest]
    @StateObject private var authManager = AuthManager.shared
    @StateObject private var viewModel = AddQuestViewModel()
    @State private var selectedTab: Int = 0 // 0 = Create, 1 = Join

    @State private var isStartDateExpanded = false
    @State private var isEndDateExpanded = false
    @State private var showTaskInput = false
    @State private var newTaskTitle: String = ""
    @State private var newTaskPoints: String = "10"

    // Helper struct for task input
    struct TaskInput: Identifiable {
        let id = UUID()
        var title: String
        var points: Int
    }

    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }()

    var body: some View {
        NavigationStack {
            ZStack {
                // Background gradient
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

                ScrollView {
                    VStack(spacing: 24) {
                        Picker("Mode", selection: $selectedTab) {
                            Text("Create").tag(0)
                            Text("Join").tag(1)
                        }
                        .pickerStyle(.segmented)
                        .padding(.bottom, 8)

                        if selectedTab == 0 {
                            // Quest Name Input
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Quest Name")
                                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                                    .foregroundColor(.primary)

                                TextField("Enter quest name", text: $viewModel.questName)
                                    .font(.system(size: 17, design: .rounded))
                                    .padding(16)
                                    .background(Color.white)
                                    .cornerRadius(12)
                                    .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
                            }

                            // Start Date Picker
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Start Date")
                                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                                    .foregroundColor(.primary)

                                VStack(spacing: 0) {
                                    // Date display button
                                    Button(action: {
                                        withAnimation(.easeInOut(duration: 0.3)) {
                                            isStartDateExpanded.toggle()
                                            if isStartDateExpanded {
                                                isEndDateExpanded = false
                                            }
                                        }
                                    }) {
                                        HStack {
                                            Text(dateFormatter.string(from: viewModel.startDate))
                                                .font(.system(size: 17, design: .rounded))
                                                .foregroundColor(.primary)
                                            Spacer()
                                            Image(systemName: "chevron.down")
                                                .font(.system(size: 14, weight: .medium, design: .rounded))
                                                .foregroundColor(.secondary)
                                                .rotationEffect(.degrees(isStartDateExpanded ? 180 : 0))
                                        }
                                        .padding(16)
                                        .background(Color.white)
                                        .cornerRadius(isStartDateExpanded ? 12 : 12)
                                    }
                                    .buttonStyle(PlainButtonStyle())

                                    // Wheel picker
                                    if isStartDateExpanded {
                                        DatePicker(
                                            "",
                                            selection: $viewModel.startDate,
                                            displayedComponents: .date
                                        )
                                        .datePickerStyle(.wheel)
                                        .labelsHidden()
                                        .frame(maxHeight: 150)
                                        .padding(.horizontal, 8)
                                        .padding(.bottom, 12)
                                        .background(Color.white)
                                        .onChange(of: viewModel.startDate) { _, newValue in
                                            if viewModel.endDate < newValue {
                                                viewModel.endDate = newValue
                                            }
                                        }
                                    }
                                }
                                .background(Color.white)
                                .cornerRadius(12)
                                .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
                            }

                            // End Date Picker
                            VStack(alignment: .leading, spacing: 12) {
                                Text("End Date")
                                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                                    .foregroundColor(.primary)

                                VStack(spacing: 0) {
                                    // Date display button
                                    Button(action: {
                                        withAnimation(.easeInOut(duration: 0.3)) {
                                            isEndDateExpanded.toggle()
                                            if isEndDateExpanded {
                                                isStartDateExpanded = false
                                            }
                                        }
                                    }) {
                                        HStack {
                                            Text(dateFormatter.string(from: viewModel.endDate))
                                                .font(.system(size: 17, design: .rounded))
                                                .foregroundColor(.primary)
                                            Spacer()
                                            Image(systemName: "chevron.down")
                                                .font(.system(size: 14, weight: .medium, design: .rounded))
                                                .foregroundColor(.secondary)
                                                .rotationEffect(.degrees(isEndDateExpanded ? 180 : 0))
                                        }
                                        .padding(16)
                                        .background(Color.white)
                                        .cornerRadius(12)
                                    }
                                    .buttonStyle(PlainButtonStyle())

                                    // Wheel picker
                                    if isEndDateExpanded {
                                        DatePicker(
                                            "",
                                            selection: $viewModel.endDate,
                                            in: viewModel.startDate...,
                                            displayedComponents: .date
                                        )
                                        .datePickerStyle(.wheel)
                                        .labelsHidden()
                                        .frame(maxHeight: 150)
                                        .padding(.horizontal, 8)
                                        .padding(.bottom, 12)
                                        .background(Color.white)
                                    }
                                }
                                .background(Color.white)
                                .cornerRadius(12)
                                .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
                            }

                            // Daily Tasks Section
                            VStack(alignment: .leading, spacing: 12) {
                                HStack {
                                    Text("Daily Tasks")
                                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                                        .foregroundColor(.primary)

                                    Spacer()

                                    Text("\(viewModel.dailyTasks.count) tasks")
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(.secondary)
                                }

                                // Existing tasks list
                                if !viewModel.dailyTasks.isEmpty {
                                    VStack(spacing: 8) {
                                        ForEach(viewModel.dailyTasks) { task in
                                            HStack {
                                                VStack(alignment: .leading, spacing: 4) {
                                                    Text(task.title)
                                                        .font(.system(size: 15, weight: .medium, design: .rounded))
                                                        .foregroundColor(.primary)

                                                    Text("\(task.points) points")
                                                        .font(.system(size: 13))
                                                        .foregroundColor(.secondary)
                                                }

                                                Spacer()

                                                Button(action: {
                                                    viewModel.removeTask(id: task.id)
                                                }) {
                                                    Image(systemName: "trash")
                                                        .font(.system(size: 14))
                                                        .foregroundColor(.red)
                                                }
                                            }
                                            .padding(12)
                                            .background(Color.white)
                                            .cornerRadius(8)
                                        }
                                    }
                                    .padding(12)
                                    .background(Color(hex: "F8F9FA"))
                                    .cornerRadius(12)
                                }

                                // Add task input
                                if showTaskInput {
                                    VStack(spacing: 12) {
                                        TextField("Task name", text: $newTaskTitle)
                                            .font(.system(size: 15, design: .rounded))
                                            .padding(12)
                                            .background(Color.white)
                                            .cornerRadius(8)

                                        HStack(spacing: 12) {
                                            Text("Points:")
                                                .font(.system(size: 15, weight: .medium))
                                                .foregroundColor(.secondary)

                                            TextField("10", text: $newTaskPoints)
                                                .font(.system(size: 15, design: .rounded))
                                                .keyboardType(.numberPad)
                                                .padding(12)
                                                .background(Color.white)
                                                .cornerRadius(8)
                                                .frame(width: 80)

                                            Spacer()

                                            Button(action: addTask) {
                                                Text("Add")
                                                    .font(.system(size: 14, weight: .semibold))
                                                    .foregroundColor(.white)
                                                    .padding(.horizontal, 20)
                                                    .padding(.vertical, 10)
                                                    .background(Color(hex: "00B4D8"))
                                                    .cornerRadius(8)
                                            }
                                            .disabled(newTaskTitle.isEmpty)
                                            .opacity(newTaskTitle.isEmpty ? 0.5 : 1.0)
                                        }
                                    }
                                    .padding(12)
                                    .background(Color(hex: "E8F4FF"))
                                    .cornerRadius(12)
                                }

                                // Add task button
                                Button(action: {
                                    withAnimation {
                                        showTaskInput.toggle()
                                        if !showTaskInput {
                                            newTaskTitle = ""
                                            newTaskPoints = "10"
                                        }
                                    }
                                }) {
                                    HStack {
                                        Image(systemName: showTaskInput ? "minus.circle.fill" : "plus.circle.fill")
                                            .font(.system(size: 16))
                                        Text(showTaskInput ? "Cancel" : "Add Daily Task")
                                            .font(.system(size: 15, weight: .medium, design: .rounded))
                                    }
                                    .foregroundColor(Color(hex: "00B4D8"))
                                    .padding(12)
                                    .frame(maxWidth: .infinity)
                                    .background(Color.white)
                                    .cornerRadius(12)
                                    .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
                                }
                            }

                            // Error message
                            if let errorMessage = viewModel.errorMessage {
                                Text(errorMessage)
                                    .font(.system(size: 14))
                                    .foregroundColor(.red)
                                    .multilineTextAlignment(.center)
                            }

                            // Create Button
                            Button(action: createQuest) {
                                HStack(spacing: 12) {
                                    if viewModel.isCreating {
                                        ProgressView()
                                            .tint(.white)
                                    }
                                    Text(viewModel.isCreating ? "Creating..." : "Create Quest")
                                        .font(.system(size: 18, weight: .bold, design: .rounded))
                                }
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(
                                    LinearGradient(
                                        gradient: Gradient(colors: [
                                            Color(hex: "00D9B5"),
                                            Color(hex: "00B4D8"),
                                            Color(hex: "4C8BF5")
                                        ]),
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .cornerRadius(16)
                                .shadow(color: Color(hex: "00B4D8").opacity(0.4), radius: 10, x: 0, y: 4)
                            }
                            .disabled(viewModel.questName.isEmpty || viewModel.isCreating)
                            .opacity(viewModel.questName.isEmpty || viewModel.isCreating ? 0.6 : 1.0)

                            Spacer(minLength: 40)
                        } else {
                            VStack(alignment: .leading, spacing: 16) {
                                Text("Please enter quest sharing code")
                                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                                    .foregroundColor(.secondary)

                                HStack {
                                    TextField("9-digit code", text: $viewModel.joinCode)
                                        .keyboardType(.numberPad)
                                        .font(.system(size: 18, design: .rounded))
                                        .padding(16)
                                        .background(Color.white)
                                        .cornerRadius(12)
                                        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
                                }

                                if let errorMessage = viewModel.errorMessage {
                                    Text(errorMessage)
                                        .font(.system(size: 14))
                                        .foregroundColor(.red)
                                }

                                Button(action: joinQuest) {
                                    HStack(spacing: 12) {
                                        if viewModel.isJoining {
                                            ProgressView().tint(.white)
                                        }
                                        Text(viewModel.isJoining ? "Joining..." : "Join Quest")
                                            .font(.system(size: 18, weight: .bold, design: .rounded))
                                    }
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 16)
                                    .background(
                                        LinearGradient(
                                            gradient: Gradient(colors: [
                                                Color(hex: "00D9B5"),
                                                Color(hex: "00B4D8"),
                                                Color(hex: "4C8BF5")
                                            ]),
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .cornerRadius(16)
                                    .shadow(color: Color(hex: "00B4D8").opacity(0.4), radius: 10, x: 0, y: 4)
                                }
                                .disabled(viewModel.isJoining || viewModel.joinCode.filter { $0.isNumber }.count != 9)
                            }
                        }
                    }
                    .padding(24)
                }
            }
            .navigationTitle("New Quest")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.secondary)
                            .padding(8)
                            .background(Color.white)
                            .clipShape(Circle())
                            .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
                    }
                }
            }
        }
    }

    private func addTask() {
        guard !newTaskTitle.isEmpty else { return }
        viewModel.addTask(title: newTaskTitle, pointsString: newTaskPoints)
        withAnimation {
            newTaskTitle = ""
            newTaskPoints = "10"
            showTaskInput = false
        }
    }

    private func createQuest() {
        Task {
            do {
                _ = try await viewModel.createQuest()
                // Do not optimistically append; force HomeView to refresh from backend
                NotificationCenter.default.post(name: .questsShouldRefresh, object: nil)
                dismiss()
            } catch let error as AuthError {
                viewModel.errorMessage = error.localizedDescription
            } catch {
                viewModel.errorMessage = error.localizedDescription
            }
        }
    }

    private func joinQuest() {
        Task {
            do {
                _ = try await viewModel.joinQuest()
                // Do not optimistically append; force HomeView to refresh from backend
                NotificationCenter.default.post(name: .questsShouldRefresh, object: nil)
                dismiss()
            } catch let error as QuestError {
                viewModel.errorMessage = error.localizedDescription
            } catch let error as AuthError {
                viewModel.errorMessage = error.localizedDescription
            } catch {
                viewModel.errorMessage = error.localizedDescription
            }
        }
    }
}

#Preview {
    AddQuestView(quests: .constant([]))
}
