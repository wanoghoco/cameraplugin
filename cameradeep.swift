import Flutter
import UIKit
import DeepAR
 
 
 
public class DeepArCameraView : NSObject,FlutterPlatformView,DeepARDelegate{
 
    enum Mode: String, CaseIterable {
        case masks
        case effects
        case filters
    }

    enum RecordingMode : String, CaseIterable {
        case photo
        case video
        case lowQualityVideo
    }
    
    enum Masks: String, CaseIterable {
        case none
        case aviators
        case bigmouth
        case dalmatian
        case fatify
        case flowers
        case grumpycat
        case koala
        case lion
        case mudMask
        case pug
        case slash
        case sleepingmask
        case smallface
        case teddycigar
        case tripleface
        case twistedFace
        case beard
        case obama
        case kanye
        case topology
        case scuba
        case manly_face
        case frankenstein
        case flower_crown
        case fairy_lights
        case ball_face

        
    }

    enum Effects: String, CaseIterable {
        case fire
        case heart
        case blizzard
        case rain
        case background_segmentation
    }

    enum Filters: String, CaseIterable {
        case beauty
        case tv80
        case drawingmanga
        case sepia
        case bleachbypass
        case realvhs
        case filmcolorperfection
        case fxdrunk
        case plastic_ocean
    }

    
    private var maskIndex: Int = 0
      private var maskPaths: [String?] {
          return Masks.allCases.map { $0.rawValue.path }
      }
      
      private var effectIndex: Int = 0
      private var effectPaths: [String?] {
          return Effects.allCases.map { $0.rawValue.path }
      }
      
      private var filterIndex: Int = 0
      private var filterPaths: [String?] {
          return Filters.allCases.map { $0.rawValue.path }
      }
    
    
    let messenger: FlutterBinaryMessenger
    var frame: CGRect
    let viewId: Int64
    let channel: FlutterMethodChannel
    var licenceKey: String
    var modeValue: String
    var directionValue: String
    private var deepAR: DeepAR!
    private var arView: ARView!
    private var active:Bool;
    private var cameraController: CameraController!
    private var currentMode: Mode! {
        didSet {
            //updateModeAppearance()
        }
    }
    

  init(messenger: FlutterBinaryMessenger, frame: CGRect, viewId: Int64, args: Any?){
      self.messenger=messenger
      self.frame=frame
      self.viewId=viewId
      deepAR = DeepAR()
      self.cameraController = CameraController()
      self.licenceKey="fda5892e0677c0754b236919a60748bec18447cc3270525a8cfd872f5dea4fc69a5d1d8323368b9c"
      self.modeValue=""
      self.active=true;
      self.directionValue=""
      self.channel = FlutterMethodChannel(name: "camerachannel", binaryMessenger: messenger)
      super.init()
      currentMode = .masks
      initCameraDeepAR()
      self.channel.setMethodCallHandler ({(call : FlutterMethodCall, result : @escaping FlutterResult)-> Void in
          if(call.method=="prev"){
              self.didTapPreviousButton()
              print("changing effect prev");
              //deepAR.switchEffect(withSlot: .mask, path: path)
          }
          if(call.method=="next"){
              self.didTapNextButton()
              print("changing effect next");
              //deepAR.switchEffect(withSlot: .mask, path: path)
          }
          if(call.method=="mask")
          {
              self.mask()
          }
          if(call.method=="filter")
          {
           self.filter()
          }
          if(call.method=="effect")
          {
          self.effect()
          }
          if(call.method=="dispose"){
              //self.cameraController.stopCamera()
               self.deepAR.shutdown()
          }
          if(call.method=="start"){
              
              self.cameraController.startCamera()
              self.arView.resume();
            
          }
        
      })
    }
    
    public func didFinishShutdown() {
        print("finish sutdown");
    }
  
    public func view() -> UIView {
        return arView;
    }

    @objc func  initCameraDeepAR(){
         
        self.deepAR.delegate = self
        self.deepAR.setLicenseKey(self.licenceKey)
        cameraController.deepAR = self.deepAR
        print("initailizing");
        self.arView = self.deepAR.createARView(withFrame:frame) as? ARView
        self.cameraController.arview =  self.arView
        self.arView.translatesAutoresizingMaskIntoConstraints = false
        cameraController.startCamera()
      
    }
    
    
    func changeFilter(){
       // cameraController.deepAR.switchEffect(withSlot: "masks", data: Masks.bigmouth.rawValue)
      self.deepAR.switchEffect(withSlot:"masks", path: Masks.bigmouth.rawValue)
    }
    private func mask(){
        currentMode=Mode.masks
    }
    private func filter(){
        currentMode=Mode.filters
    }
    private func effect(){
        currentMode=Mode.effects
    }
    private func switchCamera(){
       // self.cameraController.
    }
    
    private func switchMode(_ path: String?) {
        self.deepAR.switchEffect(withSlot: currentMode.rawValue, path: path);
      
      }
   // let frame = CGRect(x: 0, y: 0, width: 1, height: 1)
         
    
    
    @objc
      private func didTapPreviousButton() {
          var path: String?
          
          switch currentMode! {
          case .effects:
              effectIndex = (effectIndex - 1 < 0) ? (effectPaths.count - 1) : (effectIndex - 1)
              path = effectPaths[effectIndex]
          case .masks:
              maskIndex = (maskIndex - 1 < 0) ? (maskPaths.count - 1) : (maskIndex - 1)
              path = maskPaths[maskIndex]
          case .filters:
              filterIndex = (filterIndex - 1 < 0) ? (filterPaths.count - 1) : (filterIndex - 1)
              path = filterPaths[filterIndex]
          }
          
          switchMode(path)
      }
    
    @objc
       private func didTapNextButton() {
           var path: String?
           
           switch currentMode! {
           case .effects:
               effectIndex = (effectIndex + 1 > effectPaths.count - 1) ? 0 : (effectIndex + 1)
               path = effectPaths[effectIndex]
           case .masks:
               maskIndex = (maskIndex + 1 > maskPaths.count - 1) ? 0 : (maskIndex + 1)
               path = maskPaths[maskIndex]
           case .filters:
               filterIndex = (filterIndex + 1 > filterPaths.count - 1) ? 0 : (filterIndex + 1)
               path = filterPaths[filterIndex]
           }
           print(maskPaths.count)
           switchMode(path)
       }
       
}

extension String {
    var path: String? {
       
        let filePath = Bundle.main.resourcePath!+"/Effects/\(self)"
        return filePath;
        //return Bundle.main.path(forResource: self, ofType: nil)
    }
}
 

