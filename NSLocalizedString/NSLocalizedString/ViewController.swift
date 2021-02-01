//
//  ViewController.swift
//  NSLocalizedString
//
//  Created by delegate on 2021/1/22.
//

import Cocoa


enum Language:Int {
    case English = 0
    case Chinese_Traditional
    case Chinese_Simple
    case Japanese
    case French
    case Koreach
    case German
    case Spanish
    case Portugal
    case Russia
    case Arab
    case Italy
    case Thai
}

class LocalizedModel:NSObject {
    var strings:Array<String>!
    var type:Language!
    var localizedFileIdentifier:String {
        get {
            let subfix = ".lproj/Localizable.strings"
            var prefix = "en"
            switch type {
            case .English:
                prefix = "en"
            case .Chinese_Traditional:
                prefix = "zh-Hant"
            case .Chinese_Simple:
                prefix = "zh-Hans"
            case .Japanese:
                prefix = "ja"
            case .French:
                prefix = "fr"
            case .Koreach:
                prefix = "ko"
            case .German:
                prefix = "de"
            case .Spanish:
                prefix = "es"
            case .Portugal:
                prefix = "pt-PT"
            case .Russia:
                prefix = "ru"
            case .Arab:
                prefix = "ar"
            case .Italy:
                prefix = "it"
            case .Thai:
                prefix = "th"
            default:
                prefix  = "none"
            }
            return prefix + subfix
        }
    }
}

class ViewController: NSViewController {
    @IBOutlet weak var keysTextView: NSScrollView!
    @IBOutlet weak var firstTextView: NSScrollView!
    @IBOutlet weak var secondTextView: NSScrollView!
    @IBOutlet weak var thirdTextView: NSScrollView!
    @IBOutlet weak var forthTextView: NSScrollView!
    @IBOutlet weak var fifthTextView: NSScrollView!
    @IBOutlet weak var sixthTextView: NSScrollView!
    @IBOutlet weak var seventhTextView: NSScrollView!
    
    @IBOutlet weak var firstBox: NSComboBox!
    @IBOutlet weak var secondBox: NSComboBox!
    @IBOutlet weak var thirdBox: NSComboBox!
    @IBOutlet weak var forthBox: NSComboBox!
    @IBOutlet weak var fifthBox: NSComboBox!
    @IBOutlet weak var sixthBox: NSComboBox!
    @IBOutlet weak var seventhBox: NSComboBox!
    let centerNextRowString:String = "%&$$%^^$"
    
    @IBOutlet weak var folderLabel: NSTextField!
    @IBOutlet weak var folderBtn: NSButtonCell!
    var localizedTextViews:Array<NSScrollView>!
    var boxs:Array<NSComboBox>!
    var keys:Array<String>!
    
    var boxItems:Array<String>!
    
    var projectPath:String!

    var loadingView:NSView!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.loadingView = NSView.init(frame: self.view.bounds)
        self.loadingView.wantsLayer = true
        self.loadingView.layer?.backgroundColor = NSColor.init(red: 0, green: 1, blue: 0, alpha: 0.4).cgColor
        self.loadingView.isHidden = true
        let label = NSTextField.init()
        label.isEnabled = false
        label.stringValue = "处理中...."
        label.backgroundColor = .clear
        label.font = NSFont.systemFont(ofSize: 30, weight: .medium)
        label.setContentHuggingPriority(.required, for: .horizontal)
        label.frame = CGRect.init(x: 400, y: 400, width: 300, height: 50)
        self.loadingView.addSubview(label)
        self.view.addSubview(self.loadingView)
        self.config()
    }
    
    func config() {
        self.localizedTextViews = [self.firstTextView,self.secondTextView,self.thirdTextView,self.forthTextView,self.fifthTextView,self.sixthTextView,self.seventhTextView];
        self.boxs = [self.firstBox,self.secondBox,self.thirdBox,self.forthBox,self.fifthBox,self.sixthBox,self.seventhBox];
        boxItems = ["English","Chinese Traditional","Chinese Simple","Janpanese",
                        "French","Korea","German","Spanish","Portugal","Runssia","Thai(泰语)","Arab(阿拉伯语)","Italy(意大利语)"]
        for (index, box) in self.boxs.enumerated() {
            box.addItems(withObjectValues: boxItems)
            box.selectItem(at: index)
        }
    }
    ///key值处理
    func handleLocalizedKey(content:String) -> Array<String>{
        var newContent = content.replacingOccurrences(of: "\"", with: "")
        newContent = newContent.replacingOccurrences(of: "%", with: "%")
        let keys:Array = newContent.components(separatedBy: "\n")
        return keys
    }
    
    func handleLocalizedString(content:String) -> Array<String>{
        if content.count == 0 {
            return Array<String>()
        }
        let strings:Array = content.components(separatedBy: "\n")
        return strings
    }
    
    func combineLocalizedString(strings:Array<String>) -> Array<String> {
        let newArray = NSMutableArray.init()
        if strings.count == 0 {
            return newArray as! Array<String>
        }
        for index in 0..<self.keys.count {
            let key = self.keys[index]
            let value = strings[index]
            let localizedString = "\"\(key)\"" + "=" + "\"\(value)\"" + ";"
            newArray.add(localizedString)
        }
        return newArray as! Array<String>
    }
    
    @IBAction func startDo(_ sender: NSButton) {
        if self.projectPath == nil {
            let alert = NSAlert.init()
            alert.messageText = "请选择项目文件夹路径"
            let action = alert.runModal()
            if action == .alertFirstButtonReturn {
                
            }
            return;
        }
        if getTextViewContent(view: self.keysTextView).count == 0 {
            let alert = NSAlert.init()
            alert.messageText = "请配置多语言的key"
            let action = alert.runModal()
            if action == .alertFirstButtonReturn {
                
            }
            return;
        }
        self.loadingView.isHidden = false
        let key = getTextViewContent(view: self.keysTextView)
        self.keys = handleLocalizedKey(content: key);
        
        for (index,box) in boxs.enumerated() {
            let view:NSScrollView = self.localizedTextViews[index];
            let string = getTextViewContent(view: view)
            if string.count == 0 {
                continue
            }
            let contentArr = handleLocalizedString(content: string)
            let combineArr = combineLocalizedString(strings: contentArr)
            let lanuageType:Language = Language.init(rawValue: box.indexOfSelectedItem) ?? .English
            let model = LocalizedModel.init()
            model.type = lanuageType
            model.strings = combineArr
            writeFile(model: model)
        }
        self.loadingView.isHidden = true
    }
    @IBAction func configProjecrFolder(_ sender: Any) {
        let panel = NSOpenPanel.init()
        panel.resolvesAliases = false
        panel.canChooseDirectories = true
        panel.canChooseFiles = false
        let result = panel.runModal()
        if result == .OK {
            if panel.url != nil {
                self.projectPath = panel.url!.path
                self.folderLabel.stringValue = self.projectPath
            }
        }
    }
    
    func writeFile(model:LocalizedModel) {
        let subPaths:Array<String>? = FileManager.default.subpaths(atPath: self.projectPath)
        guard let paths = subPaths else {
            return
        }
        var isFindDirctory = false
        for path in paths {
            if path.contains(model.localizedFileIdentifier) && !path.contains("Pod") {
                isFindDirctory = true
                let fullPath = self.projectPath + "/" + path
                let url = URL.init(fileURLWithPath: fullPath)
                let writeHandler = try? FileHandle(forWritingTo: url)
                for string in model.strings {
                    let data = string.data(using: .utf8, allowLossyConversion: true)
                    writeHandler?.seekToEndOfFile()
                    writeHandler?.write(data!)
                    let next = "\n".data(using: .utf8, allowLossyConversion: true)
                    writeHandler?.seekToEndOfFile()
                    writeHandler?.write(next!)
                }
            }
        }
        if !isFindDirctory {
            print("没有找到\(self.projectPath + "\\" + model.localizedFileIdentifier),可能不存在对应的多语言")
        }
    }
    
    func getTextViewContent(view:NSScrollView) -> String {
        for view in view.contentView.subviews {
            if view.isKind(of: NSTextView.self) {
                return (view as! NSTextView).string
            }
        }
        return ""
    }
    
    func clearContent(view:NSScrollView) {
        for view in view.contentView.subviews {
            if view.isKind(of: NSTextView.self) {
                (view as! NSTextView).string = ""
            }
        }
    }
    @IBAction func clear(_ sender: NSButton) {
        let tag = sender.tag
        if tag == 0 {
            clearContent(view: self.keysTextView)
        }else {
            let scrollView:NSScrollView? = self.localizedTextViews[tag-1]
            if scrollView != nil {
                clearContent(view: scrollView!)
            }
            clearContent(view: scrollView!)
        }
    }
    
    @IBAction func allClear(_ sender: NSButton) {
        clearContent(view: self.keysTextView)
        for view in self.localizedTextViews {
            clearContent(view: view)
        }
    }
}



//        var newContent = content.replacingOccurrences(of: "\\n", with: centerNextRowString)
//        let keys:Array = content.components(separatedBy: "\n")
//        let newArray = NSMutableArray.init()
//        for key in keys {
//            let newKey = key.replacingOccurrences(of: centerNextRowString, with: "\\n")
//            newArray.add(newKey)
//        }

//
//let clipboard = Clipboard()
//clipboard.startListening()
//clipboard.onNewCopy { (content) in
//    print(content)
//    self.handleLocalizedString(content: content);
//}

//func changeFileAllowWrited(isAllow:Bool,filePath:String) {
//    let pie = Pipe.init()
//    var args = ["-R","555",filePath]
//    if isAllow {
//        args = ["-R","777",filePath]
//    }
//    let task = Process.init()
//    task.launchPath = "/bin/chmod";
//    task.arguments = args
//    task.standardInput = pie
//    task.launch()
//    task.waitUntilExit()
//}



