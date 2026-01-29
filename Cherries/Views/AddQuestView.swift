import SwiftUI

struct AddQuestView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var quests: [Quest]

    @State private var questName: String = ""
    @State private var startDate: Date = Date()
    @State private var endDate: Date = Date()
    @State private var isStartDateExpanded = false
    @State private var isEndDateExpanded = false

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
                        // Quest Name Input
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Quest Name")
                                .font(.system(size: 16, weight: .semibold, design: .rounded))
                                .foregroundColor(.primary)

                            TextField("Enter quest name", text: $questName)
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
                                        Text(dateFormatter.string(from: startDate))
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
                                        selection: $startDate,
                                        displayedComponents: .date
                                    )
                                    .datePickerStyle(.wheel)
                                    .labelsHidden()
                                    .frame(maxHeight: 150)
                                    .padding(.horizontal, 8)
                                    .padding(.bottom, 12)
                                    .background(Color.white)
                                    .onChange(of: startDate) { _, newValue in
                                        if endDate < newValue {
                                            endDate = newValue
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
                                        Text(dateFormatter.string(from: endDate))
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
                                        selection: $endDate,
                                        in: startDate...,
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

                        // Create Button
                        Button(action: createQuest) {
                            Text("Create Quest")
                                .font(.system(size: 18, weight: .bold, design: .rounded))
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
                        .disabled(questName.isEmpty)
                        .opacity(questName.isEmpty ? 0.6 : 1.0)

                        Spacer(minLength: 40)
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

    private func createQuest() {
        let newQuest = Quest(
            id: UUID(),
            title: questName,
            subtitle: formatDateRange(),
            progress: 0,
            isActive: true
        )
        quests.append(newQuest)
        dismiss()
    }

    private func formatDateRange() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return "\(formatter.string(from: startDate)) - \(formatter.string(from: endDate))"
    }
}

#Preview {
    AddQuestView(quests: .constant([]))
}
