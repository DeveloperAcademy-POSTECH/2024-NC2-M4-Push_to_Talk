//
//  PTTTestView.swift
//  PushToTalkTest
//
//  Created by 박준우 on 6/19/24.
//
import PushToTalk
import UIKit
import AVFoundation

class PTTChannelManager: NSObject, ObservableObject, PTChannelManagerDelegate, PTChannelRestorationDelegate{
    
    var channelManager: PTChannelManager!
    var channelDescriptor: PTChannelDescriptor = PTChannelDescriptor(name: "Channel Name", image: UIImage(systemName: "car"))
    
    // 채널 관리자 설정 메서드
    func setupChannelManager() async {
        print("setupChannelManager 채널 관리자 설정 메서드")
        do {
            channelManager = try await PTChannelManager.channelManager(delegate: self,
                                                                       restorationDelegate: self)
        } catch {
            print("Error initializing channel manager: \(error.localizedDescription)")
        }
    }
    
    // 채널 가입 요청 메서드
    func joinChannel(channelUUID: UUID) {
        print("joinChannel 채널 가입 메서드")
        // Ensure that your channel descriptor and UUID are persisted to disk for later use.
        channelManager.requestJoinChannel(channelUUID: channelUUID,
                                          descriptor: channelDescriptor)
    }
    
    // 채널 가입 후 호출되는 메서드(UUID)
    func channelManager(_ channelManager: PTChannelManager,
                        didJoinChannel channelUUID: UUID,
                        reason: PTChannelJoinReason) {
        // Process joining the channel
        print("didJoinChannel 채널 가입 후 자동 호출되는 메서드, UUID:\(channelUUID)")
    }
    
    
    // 채널 가입 후 호출되는 메서드(APNs)
    func channelManager(_ channelManager: PTChannelManager,
                        receivedEphemeralPushToken pushToken: Data) {
        // Send the variable length push token to the server
        print("receivedEphemeralPushToken 채널 가입 후 자동 호출되는 메서드, pushToken: \(pushToken)")
    }
    
    // 채널이 활성화 되어 있는 상태에서 다른 채널에 가입하려 하면 채널 가입 요청이 실패할 수도 있다.
    // 채널 가입 요청이 실패할 경우 호출되는 메서드
    func channelManager(_ channelManager: PTChannelManager,
                        failedToJoinChannel channelUUID: UUID,
                        error: Error) {
        print("failedToJoinChannel 채널 가입 요청 실패 후 자동 호출되는 메서드")
        let error = error as NSError
        
        switch error.code {
        case PTChannelError.channelLimitReached.rawValue:
            print("The user has already joined a channel")
        default:
            print("\(error.localizedDescription)")
            break
        }
    }
    
    // 채널을 떠난 후 호출되는 메서드
    func channelManager(_ channelManager: PTChannelManager,
                        didLeaveChannel channelUUID: UUID,
                        reason: PTChannelLeaveReason) {
        // Process leaving the channel
        print("didLeaveChannel 채널 떠난 후 자동 호출되는 메서드, UUID:\(channelUUID)")
    }
    
    // 앱을 종료하거나 장치를 재부팅하고 앱을 재시작할 때 이전 채널 복원 메서드(채널디스크립터를 return 해야한다)
    func channelDescriptor(restoredChannelUUID channelUUID: UUID) -> PTChannelDescriptor {
        print("restoredChannelUUID 앱 재시작 시 이전 채널을 복원하기 위해 자동 호출되는 메서드")
        return getCachedChannelDescriptor(channelUUID)
    }
    
    // 채널디스크립터를 return 하는 메서드
    func getCachedChannelDescriptor(_ channelUUID: UUID) -> PTChannelDescriptor {
        return channelDescriptor
    }
    
    // PTT 생명주기 세션의 생명주기 동안 채널 정보가 변경될 때마다 채널디스크립터에 대한 업데이트를 제공해야한다
    // 채널에 대한 디스크립터 업데이트 메서드(채널의 이름이나 이미지를 업데이트)
    func updateChannel(_ channelDescriptor: PTChannelDescriptor, _ channelUUID: UUID) async throws {
        try await channelManager.setChannelDescriptor(channelDescriptor,
                                                      channelUUID: channelUUID)
    }
    
    // PTT 생명주기 세션의 생명주기 동안 서비스 상태 개체를 통해 네트워크 연결이나 서버 가용성에 대한 변경 사항을 시스템에 알려야한다
    // 앱의 서버 연결이 '재연결' 상태임을 나타내기 위한 시스템에 업데이트 제공 메서드
    // 이 업데이트에 맞게 시스템UI가 알맞게 변한다(서비스 상태가 연결 중 혹은 끊긴 경우 사용자가 오디오를 전송하는 것을 막아준다)
    func reportServiceIsReconnecting(_ channelUUID: UUID) async throws {
        try await channelManager.setServiceStatus(.connecting, channelUUID: channelUUID)
    }
    
    // PTT 생명주기 세션의 생명주기 동안 서비스 상태 개체를 통해 네트워크 연결이나 서버 가용성에 대한 변경 사항을 시스템에 알려야한다
    // 앱의 서버 연결이 '준비' 상태임을 나타내기 위한 시스템에 업데이트 제공 메서드
    // 이 업데이트에 맞게 시스템UI가 알맞게 변한다(서비스 상태가 연결 중 혹은 끊긴 경우 사용자가 오디오를 전송하는 것을 막아준다)
    // 연결이 다시 설정되면 '준비' 상태로 업데이트 해야한다
    func reportServiceIsConnected(_ channelUUID: UUID) async throws {
        try await channelManager.setServiceStatus(.ready, channelUUID: channelUUID)
    }
    
    // 앱 내에서 오디오 전송을 시작하는 메서드
    // 앱이 전면에서 실행 중이거나 블루투스 주변 장치의 특성 변화에 반응해 호출할 수 있다
    func startTransmitting(_ channelUUID: UUID) {
        print("startTransmitting")
        channelManager.requestBeginTransmitting(channelUUID: channelUUID)
    }
    
    // PTChannelManagerDelegate
    // 시스템이 오디오 전송을 시작할 수 없는 경우(ex. 사용자가 통화중일 때 = 전송 시작 불가)에 호출되는 메서드
    func channelManager(_ channelManager: PTChannelManager,
                        failedToBeginTransmittingInChannel channelUUID: UUID,
                        error: Error) {
        let error = error as NSError
        
        switch error.code {
        case PTChannelError.callActive.rawValue:
            print("The system has another ongoing call that is preventing transmission.")
        default:
            print(error.localizedDescription)
            break
        }
    }
    
    // 오디오 전송을 중지하는 메서드
    func stopTransmitting(_ channelUUID: UUID) {
        print("stopTransmitting")
        channelManager.stopTransmitting(channelUUID: channelUUID)
    }
    
    //시스템이 오디오 전송을 중지할 수 없는 경우(ex. 사용자가 전송 상태가 아닐 때)에 호출되는 메서드
    func channelManager(_ channelManager: PTChannelManager,
                        failedToStopTransmittingInChannel channelUUID: UUID,
                        error: Error) {
        let error = error as NSError
        
        switch error.code {
        case PTChannelError.transmissionNotFound.rawValue:
            print("The user was not in a transmitting state")
        default:
            print(error.localizedDescription)
            break
        }
    }
    
    // 앱 내에서 전송을 하든 시스템UI에서 전송을 시작하든 호출되는 전송 시작 메서드
    // 전송이 어디서 시작됐는지 전달된다(시스템UI/API/하드웨어의 버튼 이벤트 등등)
    func channelManager(_ channelManager: PTChannelManager,
                        channelUUID: UUID,
                        didBeginTransmittingFrom source: PTChannelTransmitRequestSource) {
        print("didBeginTransmittingFrom 전송 시작 후 자동 호출되는 메서드, Did begin transmission from: \(source)")
    }
    
    // 전송이 시작되면 앱의 오디오 세션을 시스템이 활성화(녹음을 시작할 수 있다는 신호)되면 호출하는 메서드
    // 주의: 오디오 세션을 마음대로 시작/중지하면 안된다
    func channelManager(_ channelManager: PTChannelManager,
                        didActivate audioSession: AVAudioSession) {
        print("Did activate audio session")
        // Configure your audio session and begin recording
    }
    
    // 앱 내에서 전송이 끝나든 시스템UI에서 전송이 끝나든 호출되는 전송 시작 메서드
    // 전송이 어디서 끝났는지 전달된다(시스템UI/API/하드웨어의 버튼 이벤트 등등)
    func channelManager(_ channelManager: PTChannelManager,
                        channelUUID: UUID,
                        didEndTransmittingFrom source: PTChannelTransmitRequestSource) {
        print("didEndTransmittingFrom 전송 끝난 후 자동 호출되는 메서드,  Did end transmission from: \(source)")
    }
    
    // 전송이 중지되면 앱의 오디오 세션을 시스템이 비활성화(녹음을 할 수 없다는 신호)되면 호출하는 메서드
    // 주의: 오디오 세션을 마음대로 시작/중지하면 안된다
    // 전송이 활성화되어있을 때, 오디오 세션이 수신 전화나 FaceTime과 같은 것으로 인해 중단될 수 있다
    func channelManager(_ channelManager: PTChannelManager,
                        didDeactivate audioSession: AVAudioSession) {
        print("Did deactivate audio session")
        // Stop recording and clean up resources
    }
    
    // PPT 서버에 사용자가 수신할 새 오디오가 있는 경우, 채널을 가입할 때 받은 장치 푸시 토큰을 사용해 사용자에게 PTT 알림을 보내야 한다
    // 앱에서 보낸 푸시 알림을 받으면 활성 스피커를 프레임워크에 보고 해야한다, 활성 스피커는 스피커를 시켜 앱의 오디오 세션을 활성화하고 재생을 시작하게 한다
    // PTT 알림은 iOS의 다른 알림 유형과 유사, 앱으로 알림을 전달하기 위해 설정해야하는 속성이 있다
    // 먼저 요청 헤더에서 APNs 푸시 유형을 'pushtotalk'으로 설정해야한다
    // 그 다음 APNs 항목의 헤더 끝에 '.voip-ptt'를 추가하면서 앱의 번들 식별자로 설정해야한다
    // push payload에는 활성 스피커의 이름이나 세션이 종료돼서 앱이 채널을 떠나야한다는 표시처럼 앱과 관련된 사용자 지정 키가 포함될 수 있다
    // PTT payload는 APNs의 우선순위가 10이어야, 즉시 전달을 요청 가능
    // 관련 없어진 오래된 푸시들이 나중에 전달되는 걸 방지하기 위해 APNs의 만료가 0이어야한다
    // 서버에서 PTT 알림을 보내면 백그라운드에서 앱이 시작되고 다음 메서드가 호출된다
    // 푸시 payload를 받으면 푸시 알림의 결과로 수행할 작업을 나타내는 푸시 결과 유형을 구성해야한다
    func incomingPushResult(channelManager: PTChannelManager,
                            channelUUID: UUID,
                            pushPayload: [String : Any]) -> PTPushResult {
        
        // 서버가 사용자를 채널에서 내보내기로 한 경우 push payload에 표시됩니다
        // leaveChannel 푸시 결과를 반환하면 된다
        guard let activeSpeaker = pushPayload["activeSpeaker"] as? String else {
            // If no active speaker is set, the only other valid operation
            // is to leave the channel
            return .leaveChannel
        }
        
        // 원격 사용자가 말하려는 걸 나타내려면 활성 참가자의 정보(참가자의 이름과 선택한 이미지가 담겨 있는)가 포함된 푸시 결과를 반환
        // 그러면 시스템이 채널의 활성 참가자를 설정하고 채널이 수신 모드임을 나타낸다
        // 그 후 시스템이 오디오 세션 활성화하고 didActivate Audio Session 메서드를 호출
        // 재생을 시작하기 전에 이 메서드(didActivate Audio Session)의 호출을 기다려야한다
        let activeSpeakerImage = getActiveSpeakerImage(activeSpeaker)
        let participant = PTParticipant(name: activeSpeaker, image: activeSpeakerImage)
        return .activeRemoteParticipant(participant)
    }
    
    func getActiveSpeakerImage(_ activeSpeaker: String) -> UIImage{
        return UIImage(systemName: "car")!
    }
    
    // 원격 참가자가 말을 마치면 setActiveRemoteParticipant을 0으로 설정해야한다
    // 이렇게 하면 사용자가 채널에서 더 이상 오디오를 수신하지 않고 시스템이 오디오를 비활성화해야함을 나타낸다
    // 이러면 시스템 UI도 업데이트 된다, 사용자가 다시 오디오를 전송할 수도 있다
    func stopReceivingAudio(_ channelUUID: UUID) {
        channelManager.setActiveRemoteParticipant(nil, channelUUID: channelUUID)
    }
}
