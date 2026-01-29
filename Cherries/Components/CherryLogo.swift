import SwiftUI

struct CherryLogo: View {
    let size: CGFloat

    var body: some View {
        ZStack {
            // Left Cherry
            Circle()
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color(hex: "FF5252"),
                            Color(hex: "E91E63")
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: size * 0.4, height: size * 0.4)
                .offset(x: -size * 0.12, y: size * 0.15)

            // Right Cherry
            Circle()
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color(hex: "FF5252"),
                            Color(hex: "E91E63")
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: size * 0.4, height: size * 0.4)
                .offset(x: size * 0.12, y: size * 0.15)

            // Stems
            Path { path in
                // Left stem
                path.move(to: CGPoint(x: size * 0.38, y: size * 0.15))
                path.addQuadCurve(
                    to: CGPoint(x: size * 0.5, y: size * 0.0),
                    control: CGPoint(x: size * 0.35, y: size * 0.05)
                )

                // Right stem
                path.move(to: CGPoint(x: size * 0.62, y: size * 0.15))
                path.addQuadCurve(
                    to: CGPoint(x: size * 0.5, y: size * 0.0),
                    control: CGPoint(x: size * 0.65, y: size * 0.05)
                )
            }
            .stroke(Color(hex: "4CAF50"), style: StrokeStyle(lineWidth: size * 0.04, lineCap: .round))

            // Leaf
            Path { path in
                path.move(to: CGPoint(x: size * 0.5, y: size * 0.0))
                path.addQuadCurve(
                    to: CGPoint(x: size * 0.7, y: size * 0.05),
                    control: CGPoint(x: size * 0.65, y: -size * 0.08)
                )
                path.addQuadCurve(
                    to: CGPoint(x: size * 0.5, y: size * 0.0),
                    control: CGPoint(x: size * 0.6, y: size * 0.1)
                )
            }
            .fill(Color(hex: "4CAF50"))
        }
        .frame(width: size, height: size * 0.6)
    }
}

#Preview {
    VStack(spacing: 40) {
        CherryLogo(size: 120)

        HStack(spacing: 8) {
            CherryLogo(size: 32)
            Text("Cherries")
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundColor(Color(hex: "E91E63"))
        }
    }
    .padding()
}
