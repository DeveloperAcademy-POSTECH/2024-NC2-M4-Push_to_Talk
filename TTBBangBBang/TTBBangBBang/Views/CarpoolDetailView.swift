//
//  CarpoolDetailView.swift
//  PushToTalkTest
//
//  Created by 박준우 on 6/18/24.
//

import SwiftUI
import MapKit
import PushToTalk
import AVFoundation


struct Place: Identifiable {
    let id = UUID()
    let name: String
    let coordinate: CLLocationCoordinate2D
    let img: String
    
    static let examples: [Place] =
    [Place(name: "Lemony", coordinate: CLLocationCoordinate2D(latitude: 36.00565, longitude: 129.32330), img: "LemonyCar"),
     Place(name: "Arthur", coordinate: CLLocationCoordinate2D(latitude: 36.00811, longitude: 129.32879), img: "Arthur"),
     Place(name: "Keenie", coordinate: CLLocationCoordinate2D(latitude: 36.00633, longitude: 129.32594), img: "Keenie"),
     Place(name: "Nagi", coordinate: CLLocationCoordinate2D(latitude: 36.00741, longitude: 129.32911), img: "Nagi"),
    ]
}

struct CarpoolDetailView: View {
    @StateObject var pttChannelManagerInstance = PTTChannelManager()
    var channelDescriptor: PTChannelDescriptor = PTChannelDescriptor(name: "Channel Name", image: UIImage(systemName: "car"))
    var channelUUID: UUID = UUID(uuidString: "8A03D9B0-0CEC-43C5-AEB2-B23E0214D9A9")!
    
    @Environment(\.dismiss) private var dismiss
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 36.005, longitude: 129.32594),
        span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
    )
    @State private var isSendPushToTalk: Bool = false
    @State private var isSendPushToTalkOnToggle: Bool = false
    @State private var isCarpoolDetailSheet: Bool = false
    @State var borderGradientAnimation: Double = 0
    
    var body: some View {
        NavigationStack{
            ZStack{
                Map(coordinateRegion: $region, annotationItems: Place.examples) { place in
                    MapAnnotation(coordinate: place.coordinate) {
                        Image("\(place.img)")
                            .resizable()
                            .frame(width: place.name == "Lemony" ? 30 : 50, height: 50)
                    }
                }
                .ignoresSafeArea(edges: .bottom)
                VStack{
                    Spacer()
                    if(isSendPushToTalkOnToggle){
                        PushToTalkOnToggle()
                    }
                    else{
                        PushToTalkOnPush()
                    }
                }
            }
        }
        .onAppear{
            if (!isPreview()){
                requestAudioPermission()
                Task{
                    await pttChannelManagerInstance.setupChannelManager()
                    pttChannelManagerInstance.joinChannel(channelUUID: self.channelUUID)
                }
            }
        }
        .onChange(of: isSendPushToTalk, {
            if (!isPreview()){
                if isSendPushToTalk {
                    pttChannelManagerInstance.startTransmitting(self.channelUUID)
                } else {
                    pttChannelManagerInstance.stopTransmitting(self.channelUUID)
                }
            }
        })
        .background(Color(hex: "0xF3F3F3"))
        .navigationBarBackButtonHidden(true)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar{
            ToolbarItem(placement: .cancellationAction) {
                Button(action: {
                    dismiss()
                }, label: {
                    Image(systemName: "chevron.left")
                })
            }
        }
        .toolbar {
            ToolbarItem(placement: .principal) {
                VStack(spacing: 0) {
                    Text("레모니와 피크민들")
                        .bold()
                        .font(.title3)
                    Button(action: {
                        isCarpoolDetailSheet.toggle()
                    }, label: {
                        Text("5 people Online >")
                            .foregroundStyle(.gray)
                            .font(.system(size: 12))
                    })
                }
            }
        }
        .sheet(isPresented: $isCarpoolDetailSheet, content: {
            CarpoolDetailSheet()
                .presentationDragIndicator(.visible)
        })
    }
    
    func requestAudioPermission(){
        AVCaptureDevice.requestAccess(for: .audio, completionHandler: { (granted: Bool) in
            if granted {
                print("Audio: 권한 허용")
            } else {
                print("Audio: 권한 거부")
            }
        })
    }
}

extension CarpoolDetailView{
    
    @ViewBuilder
    func PushToTalkOnPush() -> some View{
        RoundedRectangle(cornerRadius: 36)
            .shadow(radius: 5)
            .foregroundStyle(.thinMaterial)
            .frame(width: 350,height: 350)
            .overlay{
                if (isSendPushToTalk){
                    RoundedRectangle(cornerRadius: 36, style: .circular)
                        .frame(width: 480, height: 480)
                        .foregroundStyle(LinearGradient(gradient: Gradient(colors: [.red,.blue,.purple,.pink,.red,.blue,.purple,.pink]), startPoint: .top, endPoint: .bottom))
                        .rotationEffect(.degrees(self.borderGradientAnimation))
                        .mask {
                            RoundedRectangle(cornerRadius: 36)
                                .stroke(lineWidth: 4)
                                .frame(width: 350,height: 350)
                        }
                        .onAppear(perform: {
                            withAnimation(.linear(duration: 4).repeatForever(autoreverses: false)) {
                                borderGradientAnimation = 360
                            }
                        })
                }
            }
            .overlay {
                if(isSendPushToTalk){
                    VStack{
                        Spacer()
                        Text("레모니, 나기,\n아서, 윈터")
                            .bold()
                            .font(.system(size: 24))
                        Text("에게 전달되고 있어요.")
                        Spacer()
                        Image(systemName: "waveform")
                            .resizable()
                            .frame(width: 49, height: 40)
                            .symbolEffect(.variableColor,options: .speed(2))
                            .foregroundStyle(.blue)
                        Spacer()
                        Text("메세지를 다 보낸 후에는 꼭\n손가락을 떼주세요.")
                            .foregroundStyle(.gray)
                            .padding(.bottom, 40)
                    }
                    .multilineTextAlignment(.center)
                }
                else{
                    VStack{
                        Spacer()
                        Text("🎙️")
                            .font(.system(size: 60))
                            .frame(width: 60,height: 60)
                        Spacer()
                        Text("메세지를 보내고 싶으시면\n여기를 누르며 말해주세요.")
                            .multilineTextAlignment(.center)
                            .foregroundStyle(.gray)
                            .padding(.bottom, 40)
                    }
                }
            }
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { _ in
                        withAnimation {
                            self.isSendPushToTalk = true
                        }
                    }
                    .onEnded { _ in
                        withAnimation {
                            self.isSendPushToTalk = false
                        }
                    }
            )
    }
    
    @ViewBuilder
    func PushToTalkOnToggle() -> some View{
        Button(action: {
            isSendPushToTalk.toggle()
        }, label: {
            RoundedRectangle(cornerRadius: 36)
                .shadow(radius: 5)
                .foregroundStyle(.thinMaterial)
                .frame(width: 350,height: 350)
                .overlay{
                    if (isSendPushToTalk){
                        RoundedRectangle(cornerRadius: 36, style: .circular)
                            .frame(width: 480, height: 480)
                            .foregroundStyle(LinearGradient(gradient: Gradient(colors: [.red,.blue,.purple,.pink,.red,.blue,.purple,.pink]), startPoint: .top, endPoint: .bottom))
                            .rotationEffect(.degrees(self.borderGradientAnimation))
                            .mask {
                                RoundedRectangle(cornerRadius: 36)
                                    .stroke(lineWidth: 3)
                                    .frame(width: 350,height: 350)
                            }
                            .onAppear(perform: {
                                withAnimation(.linear(duration: 1).repeatForever(autoreverses: false)) {
                                    borderGradientAnimation = 90
                                }
                            })
                    }
                }
                .overlay {
                    if(isSendPushToTalk){
                        VStack{
                            Spacer()
                            Text("레모니, 나기,\n아서, 윈터")
                                .bold()
                                .font(.system(size: 24))
                            Text("에게 전달되고 있어요.")
                            Spacer()
                            Image(systemName: "waveform")
                                .resizable()
                                .frame(width: 49, height: 40)
                                .symbolEffect(.variableColor,options: .speed(2))
                                .foregroundStyle(.blue)
                            Spacer()
                            Text("하고싶은 말이 끝나면\n여기를 한 번 더 터치해주세요.")
                            
                                .foregroundStyle(.gray)
                                .padding(.bottom, 40)
                        }
                        .multilineTextAlignment(.center)
                    }
                    else{
                        VStack{
                            Spacer()
                            Text("🎙️")
                                .font(.system(size: 60))
                                .frame(width: 60,height: 60)
                            Spacer()
                            Text("메세지를 보내고 싶으시면\n여기를 터치해주세요.")
                                .multilineTextAlignment(.center)
                                .foregroundStyle(.gray)
                                .padding(.bottom, 40)
                        }
                    }
                }
        })
    }
    
    @ViewBuilder
    func CarpoolDetailSheet() -> some View{
        NavigationStack{
            VStack{
                Circle().foregroundStyle(.white).frame(width: 80, height: 80)
                    .overlay {
                        Text("🚘")
                            .frame(width: 60,height: 60)
                            .font(.system(size: 35))
                            .padding(.horizontal)
                    }
                Text("레모니와 피크민들")
                    .bold()
                    .font(.title3)
                Button(action: {
                    
                }, label: {
                    Text("그룹 설정하기")
                })
                List {
                    Section {
                        HStack {
                            Circle().foregroundStyle(Color(hex: "FFF2C6")).frame(width: 40, height: 40)
                                .overlay{
                                    Image("Lemony")
                                        .resizable()
                                        .frame(width: 30, height: 30)
                                }
                                .overlay(alignment: .bottomTrailing) {
                                    Circle().foregroundStyle(.green).frame(width: 14,height: 14)
                                }
                            Text("레모니")
                        }
                    } header: {
                        Text("운전자").font(.system(size: 17))
                    }
                    .bold()
                    .foregroundStyle(.black)
                    
                    Section {
                        HStack {
                            Circle().foregroundStyle(Color(hex: "D5E39E")).frame(width: 40, height: 40)
                                .overlay{
                                    Image("Nagi")
                                        .resizable()
                                        .frame(width: 30, height: 30)
                                }
                                .overlay(alignment: .bottomTrailing) {
                                    Circle().foregroundStyle(.green).frame(width: 14,height: 14)
                                }
                            Text("나기")
                        }
                        HStack {
                            Circle().foregroundStyle(Color(hex: "FFDFDF")).frame(width: 40, height: 40)
                                .overlay{
                                    Image("Winter")
                                        .resizable()
                                        .frame(width: 30, height: 30)
                                }
                                .overlay(alignment: .bottomTrailing) {
                                    Circle().foregroundStyle(.gray).frame(width: 14,height: 14)
                                }
                            Text("윈터")
                        }
                        HStack {
                            Circle().foregroundStyle(Color(hex: "80C9C5")).frame(width: 40, height: 40)
                                .overlay{
                                    Image("Arthur")
                                        .resizable()
                                        .frame(width: 30, height: 30)
                                }
                                .overlay(alignment: .bottomTrailing) {
                                    Circle().foregroundStyle(.green).frame(width: 14,height: 14)
                                }
                            Text("아서")
                        }
                        HStack {
                            Circle().foregroundStyle(Color(hex: "FFD698")).frame(width: 40, height: 40)
                                .overlay{
                                    Image("Keenie")
                                        .resizable()
                                        .frame(width: 30, height: 30)
                                }
                                .overlay(alignment: .bottomTrailing) {
                                    Circle().foregroundStyle(.green).frame(width: 14,height: 14)
                                }
                            Text("키니")
                        }
                    } header: {
                        Text("멤버").bold().font(.system(size: 17))
                    }
                    .bold()
                    .foregroundStyle(.black)
                    
                    Section {
                        Toggle(isOn: $isSendPushToTalkOnToggle, label: {
                            Text("토글로 보내기")
                        })
                    } header: {
                        Text("메세지 전송모드").bold().foregroundStyle(.black).font(.system(size: 17))
                    }
                }
            }
            .background(Color(hex: "0xF3F3F3"))
            .toolbar(content: {
                ToolbarItem {
                    Button(action: {
                        isCarpoolDetailSheet.toggle()
                    }, label: {
                        Text("닫기")
                    })
                }
            })
        }
    }
}

#Preview {
    CarpoolDetailView()
}
