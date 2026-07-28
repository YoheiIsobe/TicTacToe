//
//  TitleView.swift
//  TicTacToe
//

import SwiftUI

struct TitleView: View {
    var body: some View {
        NavigationStack {
            ZStack {
                Color.white.ignoresSafeArea()

                VStack(spacing: 32) {
                    Spacer()

                    Text("〇×ゲーム")
                        .font(.system(size: 48, weight: .heavy, design: .rounded))
                        .foregroundColor(.black)

                    VStack(spacing: 16) {
                        NavigationLink(destination: GameView(mode: .twoPlayer)) {
                            TitleMenuButton(title: "2人対戦", color: .blue)
                        }

                        Text("CPU対戦")
                            .font(.system(size: 20, weight: .bold, design: .rounded))
                            .foregroundColor(.gray)
                            .padding(.top, 16)

                        NavigationLink(destination: GameView(mode: .vsCPU(difficulty: .easy))) {
                            TitleMenuButton(title: "弱い", color: .green)
                        }
                        NavigationLink(destination: GameView(mode: .vsCPU(difficulty: .normal))) {
                            TitleMenuButton(title: "普通", color: .orange)
                        }
                        NavigationLink(destination: GameView(mode: .vsCPU(difficulty: .hard))) {
                            TitleMenuButton(title: "強い", color: .red)
                        }
                    }

                    Spacer()
                }
                .padding()
            }
        }
    }
}

private struct TitleMenuButton: View {
    let title: String
    let color: Color

    var body: some View {
        Text(title)
            .font(.system(size: 24, weight: .bold, design: .rounded))
            .foregroundColor(.white)
            .frame(width: 220)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(color)
            )
    }
}

#Preview {
    TitleView()
}
