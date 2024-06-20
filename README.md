# 2024-NC2-M4-Push_to_Talk
Apple Developer Academy 3rd Morning Session NC2 <br>Pair4(Arthur&amp;Keenie)'s Push to Talk<br>
**<span style="color:orange">TTBBANGBBANG🚘</span>**

## 🎥 Youtube Link
(추후 만들어진 유튜브 링크 추가)

## 💡 About Push To Talk

### Push To Talk이란?
**iOS의 오디오 커뮤니케이션 class**로 iOS 앱에서 워키토키 통신을 통해<br>빠른 커뮤니케이션 진행하도록 도와주는 Framework (무전기 기능)<br><span style="color:gray">(watchOS5.3, iOS16 이상부터 사용 가능)


### Push To Talk의 기능
* 실시간으로 정보 공유가 가능하다
* 같은 채널에 있는 참가자들에게 동시에 정보 전달이 가능하다
* 백그라운드에서 실행하고 있어도 배터리 소모가 적다
* 여러 명이 채널에 있을 시 한 번에 한 참가자만 말할 수 있다.
* 어떤 참가자가 이야기를 하고 있고, 어떤 참가자가 듣고 있는지 보여주어야 한다.
* 앱 실행 시 마이크 접근 권한에 대한 허용을 요청해야 한다.


## 🎯 What we focus on?
PushToTalk을 이용하면 채널 내에 있는 사용자들과 간단하게 소통이 가능하다. 백그라운드에서 소모되고 있어도 배터리 소모가 적고 즉각적인 정보전달과 습득이 가능하다.

## 💼 Use Case
매일 카풀을 하는 그룹의 구성원들끼리 카풀 전 쉽게 실시간 정보(도착시간과 위치)를 공유할 수 있게 해주자. 

## 🖼️ Prototype

![NC2 Act 아서and키니 001](https://github.com/DeveloperAcademy-POSTECH/2024-NC2-M4-Push_to_Talk/assets/166780563/597306a8-fd9f-4ab1-b261-13b5e9ecf44e)
![NC2 Act 아서and키니 002](https://github.com/DeveloperAcademy-POSTECH/2024-NC2-M4-Push_to_Talk/assets/166780563/e341ef03-c1b5-401f-b802-7e7c12ccd928)

## 🛠️ About Code
##### PTT Channel Manager & Channel UUID & Channel Descriptor 선언
```
var channelManager: PTChannelManager!

let channelUUID = UUID()

let channelDescriptor = PTChannelDescriptor(name: "Channel Name", image: UIImage(systemName: "person"))
```
##### PTT Channel Manager 설정
```
channelManager = try await PTChannelManager.channelManager(delegate: self, restorationDelegate: self)
```
##### Channel 참가 요청 메서드
```
channelManager.requestJoinChannel(channelUUID: channelUUID, descriptor: channelDescriptor)
```
##### Channel 오디오 전송 요청 메서드
```
channelManager.requestBeginTransmitting(channelUUID: channelUUID)
```
##### Channel 오디오 전송 메서드의 호출이 성공적이었을 때, 콜백되는 메서드
```
func channelManager(_ channelManager: PTChannelManager,
                    channelUUID: UUID,
                    didBeginTransmittingFrom source: PTChannelTransmitRequestSource) {        
                    
}
```
##### 오디오의 활성화되었을 때, 콜백되는 메서드
```
func channelManager(_ channelManager: PTChannelManager,
                    didActivate audioSession: AVAudioSession) {        

}
```
##### 서버에서 PTT Notification을 받았을 때(다른 유저의 Audio를 받았을 때), 콜백되는 메서드
```
func incomingPushResult(channelManager: PTChannelManager, channelUUID: UUID, pushPayload: [String : Any]) -> PTPushResult {
	
	let activeSpeakerName = pushPayload[“activeSpeaker”]
	let activeSpeakerImage = getActiveSpeakerImage(name: activeSpeakerName)
	return .activeRemoteParticipant(PTParticipant(name: activeSpeakerName,
                                    image: activeSpeakerImage))
}
```
