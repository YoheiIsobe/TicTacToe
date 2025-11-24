//
//  ContentView.swift
//  TicTacToe
//
//  Created by Takuma Nezu on 2025/11/22.
//

import SwiftUI
import GoogleMobileAds

struct ContentView: View {
    @State private var cells = Array(repeating: "", count: 9)   //セル
    @State private var playerFlg = true         // プレイヤーフラグ
    @State private var draw = false             // 引き分けフラグ
    @State private var winner: String? = nil    // 勝者を保存
    @State private var pulse = false
    let columns = Array(repeating: GridItem(.flexible()), count: 3) //マス

    //勝ちパターン
    let winPatterns = [
        [0,1,2], [3,4,5], [6,7,8],
        [0,3,6], [1,4,7], [2,5,8],
        [0,4,8], [2,4,6]
    ]


    var body: some View {
        ZStack {
            // -----------------------------
            // 広告+ゲーム画面（ZStack の最背面）
            // -----------------------------
            VStack {
                //広告表示
                //AdBannerView(adUnitID: "ca-app-pub-3940256099942544/2934735716")    //テスト広告
                AdBannerView(adUnitID: "ca-app-pub-4013798308034554/2995384805")  //本番広告
                    .frame(width: 320, height: 50)

                //スペース
                Spacer()

                //現在のプレイヤー表示
                HStack {
                    Text("Player:")
                    Text(playerFlg ? "◯" : "×")
                        .frame(width: 40)
                }
                .font(.system(size: 36, weight: .bold, design: .rounded))
                .padding(.top, 100)

                //スペース
                Spacer()

                //盤面表示
                VStack(spacing: 0) {
                    ForEach(0..<3) { row in
                        HStack(spacing: 0) {
                            ForEach(0..<3) { col in
                                let index = row * 3 + col

                                ZStack {
                                    Rectangle()
                                        .fill(Color(white: 0.97))

                                        .overlay(
                                            Rectangle()
                                                .stroke(Color.black.opacity(0.7), lineWidth: 2)
                                        )

                                    Text(cells[index])
                                        .font(.system(size: 60, weight: .bold, design: .rounded))
                                        .bold()
                                }
                                .aspectRatio(1, contentMode: .fit)
                                .onTapGesture {
                                    if winner == nil && cells[index].isEmpty {
                                        cells[index] = tapAction()

                                        //勝者判定実行
                                        if let win = checkWinner() {
                                            winner = win
                                            return
                                        }

                                        //引き分け判定実行
                                        checkDraw()

                                        //プレイヤー交代実行
                                        playerFlg.toggle()
                                    }
                                }
                            }
                        }
                    }
                }
                .padding(20)

                //スペース
                Spacer()
                    .frame(height: 50)

                //リセットボタン表示
                Button(action: {
                    resetGame()
                }) {
                    Text("Reset Game")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.vertical, 12)
                        .padding(.horizontal, 24)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill( (winner != nil || draw) ? Color.red : Color.gray )
                        )
                        .scaleEffect(pulse ? 1.02 : 0.98)   // ← ピクピク
                        .animation(
                            pulse ?
                            Animation.easeInOut(duration: 0.5).repeatForever(autoreverses: true)
                            : Animation.default,
                            value: pulse
                        )

                }
                .padding(.bottom, 100)
                .onChange(of: winner) {
                    pulse = (winner != nil || draw)
                }
                .onChange(of: draw) {
                    pulse = draw || winner != nil
                }
            }

            // -----------------------------
            // 勝敗 or 引き分け表示（ZStack の最前面）
            // -----------------------------
            if winner != nil || draw {
                Color.black.opacity(0.6)
                    .frame(height: 100)
                    .allowsHitTesting(false)

                VStack {
                    if let w = winner {
                        HStack {
                            Text("Winner")
                                .font(.system(size: 70, weight: .bold))
                                .foregroundColor(.yellow)
                                .shadow(color: .orange, radius: 10, x: 0, y: 0)
                            Text(w)
                                .font(.system(size: 70, weight: .bold))
                                .foregroundColor(.yellow)
                                .shadow(color: .orange, radius: 10, x: 0, y: 0)
                        }
                    } else if draw {
                        Text("Draw")
                            .font(.system(size: 70, weight: .bold))
                            .foregroundColor(.white)
                    }
                }
                .transition(.scale)
                .scaleEffect(winner != nil ? 1.1 : 1.0) // 勝者だけ少し弾む
                .animation(.interpolatingSpring(stiffness: 100, damping: 10), value: winner)
            }
        }
    }

    // ◯ × 切り替え
    func tapAction() -> String {
        return playerFlg ? "◯" : "×"
    }

    // 勝者判定
    func checkWinner() -> String? {
        for p in winPatterns {
            if cells[p[0]] != "" &&
                cells[p[0]] == cells[p[1]] &&
                cells[p[1]] == cells[p[2]] {
                return cells[p[0]]
            }
        }
        return nil
    }

    // 引き分け判定
    func checkDraw() {
        if cells.allSatisfy({ !$0.isEmpty }) {   // 全部埋まってる？
            draw = true
        }
    }

    // 全リセット
    func resetGame() {
        cells = Array(repeating: "", count: 9)
        playerFlg = true
        winner = nil
        draw = false
        pulse = false
    }
}


#Preview {
    ContentView()
}
