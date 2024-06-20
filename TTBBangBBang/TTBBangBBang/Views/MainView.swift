//
//  ContentView.swift
//  PushToTalkTest
//
//  Created by 박준우 on 6/12/24.
//

import SwiftUI

struct MainView: View {
    var body: some View {
        TabView {
            MyCarpoolListView()
                .tabItem {
                    Image(systemName: "car")
                    Text("내 카풀 채널")
                }
            Text("친구 목록")
                .tabItem {
                    Image(systemName: "person.2")
                    Text("친구 목록")
                }
            Text("계정")
                .tabItem {
                    Image(systemName: "person.circle")
                    Text("계정")
                }
        }
    }
}

#Preview {
    MainView()
}
