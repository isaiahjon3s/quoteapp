//
//  UserAvatarView.swift
//  giftem
//

import SwiftUI

struct UserAvatarView: View {
    let user: User
    let size: CGFloat

    private var initials: String {
        let parts = user.displayName.split(separator: " ")
        let first = parts.first?.prefix(1) ?? ""
        let last = parts.dropFirst().first?.prefix(1) ?? ""
        return "\(first)\(last)".uppercased()
    }

    private var backgroundColor: Color {
        let palette: [Color] = [
            Color(red: 0.95, green: 0.42, blue: 0.37), // coral
            Color(red: 0.29, green: 0.56, blue: 0.89), // sky blue
            Color(red: 0.27, green: 0.70, blue: 0.56), // mint
            Color(red: 0.93, green: 0.63, blue: 0.22), // amber
            Color(red: 0.66, green: 0.38, blue: 0.87), // purple
            Color(red: 0.22, green: 0.69, blue: 0.76), // teal
            Color(red: 0.94, green: 0.42, blue: 0.61), // rose
            Color(red: 0.38, green: 0.62, blue: 0.30), // sage
            Color(red: 0.85, green: 0.35, blue: 0.35), // red
            Color(red: 0.24, green: 0.48, blue: 0.84), // indigo
        ]
        let hash = abs(user.username.unicodeScalars.reduce(0) { $0 &+ Int($1.value) })
        return palette[hash % palette.count]
    }

    var body: some View {
        Group {
            if let assetName = user.profileImageURL,
               let uiImage = UIImage(named: assetName) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: size, height: size)
                    .clipShape(Circle())
            } else {
                ZStack {
                    Circle()
                        .fill(backgroundColor)
                        .frame(width: size, height: size)
                    Text(initials)
                        .font(.system(size: size * 0.38, weight: .semibold, design: .rounded))
                        .foregroundStyle(.white)
                }
            }
        }
    }
}

#Preview {
    HStack(spacing: 16) {
        UserAvatarView(user: User(username: "alex_wonder", displayName: "Alex Wonder"), size: 50)
        UserAvatarView(user: User(username: "mamapeters75", displayName: "Fran Peters"), size: 50)
        UserAvatarView(user: User(username: "sarah_style", displayName: "Sarah Peterson"), size: 50)
        UserAvatarView(user: User(username: "mike_gadgets", displayName: "Mike Rodriguez"), size: 50)
    }
    .padding()
}
