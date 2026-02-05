import SwiftUI

struct CherryLogo: View {
    let size: CGFloat

    var body: some View {
        Image("CherriesLogo")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: size, height: size)
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
