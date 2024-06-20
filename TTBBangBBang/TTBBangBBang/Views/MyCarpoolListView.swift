//
//  MyCarpoolListView.swift
//  PushToTalkTest
//
//  Created by 박준우 on 6/17/24.
//

import SwiftUI

struct MyCarpoolListView: View {
    let carpoolListDummyDatas = [["레모니와 피크민들", "레모니, 키니, 나기, 윈터, 아서", "#평일"],["아서카", "아서, 온브, 스카일라, 트루디", "#맛집"]]
    
    var body: some View {
        NavigationStack{
            VStack{
                HStack{
                    Spacer()
                    Menu {
                        Button(action: {
                            
                        }, label: {
                            Text("새 카풀 검색하기")
                            Image(systemName: "magnifyingglass")
                        })
                        Button(action: {
                            
                        }, label: {
                            Text("새 카풀 만들기")
                            Image(systemName: "car.fill")
                        })
                    } label: {
                        Image(systemName: "plus")
                            .padding(.trailing, 20)
                    }
                    
                }
                ScrollView{
                    ForEach(carpoolListDummyDatas, id: \.self) { data in
                        NavigationLink {
                            CarpoolDetailView()
                                .toolbar(.hidden, for: .tabBar)
                        } label: {
                            RoundedRectangle(cornerRadius: 16).fill(.white)
                                .shadow(radius: 3)
                                .overlay {
                                    HStack{
                                        Text("🚘")
                                            .frame(width: 60,height: 60)
                                            .font(.system(size: 35))
                                            .padding(.horizontal)
                                        VStack(alignment: .leading){
                                            Text(data[0])
                                                .font(.title2)
                                                .bold()
                                            Text(data[1])
                                            Text(data[2])
                                                .foregroundStyle(Color(hex: "8E8E93"))
                                        }
                                        .foregroundStyle(.black)
                                        Spacer()
                                    }
                                    .padding(.vertical)
                                }
                        }
                        .frame(width: 360, height: 100)
                        .padding(.top)
                        .padding(.horizontal)
                    }
                }
                
                /*
                List(carpoolListDummyDatas, id: \.self){ data in
                    NavigationLink {
                        CarpoolDetailView()
                    } label: {
                        RoundedRectangle(cornerRadius: 16).fill(.white)
                            .shadow(radius: 5)
                            .overlay {
                                HStack{
                                    Text("🚘")
                                        .frame(width: 60,height: 60)
                                        .font(.system(size: 35))
                                        .padding(.horizontal)
                                    VStack(alignment: .leading){
                                        Text(data[0])
                                            .font(.title2)
                                            .bold()
                                        Text(data[1])
                                        Text(data[2])
                                    }
                                    .foregroundStyle(.black)
                                    Spacer()
                                }
                            }
                    }
                    .frame(width: 360, height: 100)
                    .listRowSeparator(.hidden)
                }
                .scrollContentBackground(.hidden)
                .listStyle(.inset)
                 */
                Spacer()
            }
            .navigationTitle("내 카풀")
        }
    }
}

#Preview {
    MyCarpoolListView()
}
