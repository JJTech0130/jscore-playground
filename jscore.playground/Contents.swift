import UIKit
import PlaygroundSupport

Bundle(path: "/System/Library/Frameworks/JavaScriptCore.framework")?.load()
let JSContextClass = NSClassFromString("JSContext") as? NSObject.Type

struct Log {
    public let text: String
    public let backgroundColor: UIColor?
}

class ViewController: UIViewController, UITextFieldDelegate, UITableViewDataSource {
    var context: NSObject = {
        guard let instance = JSContextClass?.init() as? NSObject else { fatalError() }
        return instance
    }()
    private var results: [Log] = [];
    private let tableView: UITableView = {
        let tableView = UITableView()
        return tableView
    }()
    private let prompt: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Type JavaScript code here"
        textField.backgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        textField.font = UIFont(name: "Menlo", size: 14)
        textField.autocapitalizationType = .none
        textField.smartDashesType = .no
        textField.smartQuotesType = .no
        textField.autocorrectionType = .no
        textField.spellCheckingType = .no
        textField.clearButtonMode = .always
        textField.enablesReturnKeyAutomatically = true
        return textField
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.context.setValue({ (_, exception: NSObject!) in
            guard let string = exception.perform(Selector("toString")).takeUnretainedValue() as? String else { fatalError() }
            self.appendCell(string, color: #colorLiteral(red: 0.95686274766922, green: 0.658823549747467, blue: 0.545098066329956, alpha: 1.0))
        } as @convention(block) (NSObject?, NSObject?) -> Void, forKey: "exceptionHandler")
        
        self.prompt.delegate = self
        
        self.tableView.dataSource = self
        
        let stackView = UIStackView(arrangedSubviews: [self.tableView, self.prompt])
        stackView.axis = .vertical
        self.view = stackView
    }
    
    func appendCell(_ text: String, color: UIColor?) {
        let log = Log(text: text, backgroundColor: color)
        self.results.append(log)
        self.tableView.reloadData()
        self.tableView.scrollToRow(at: IndexPath(row: self.results.count - 1, section: 0), at: .top, animated: true)
    }
    
    // MARK: UITextFieldDelegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        guard let script = textField.text else { fatalError() }
        
        self.appendCell("> \(script)", color: nil)
        
        textField.text?.removeAll()
        let jsValue = self.context.perform(Selector("evaluateScript:"), with: script).takeUnretainedValue()
        guard let result = jsValue.perform(Selector("toString")).takeRetainedValue() as? String else { fatalError() }
        
        self.appendCell(result, color: nil)
        
        return false
    }
    
    // MARK: UITableViewDataSource
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = self.results[indexPath.row]
        let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
        cell.backgroundColor = item.backgroundColor ?? #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        cell.textLabel?.font = UIFont(name: "Menlo", size: 14)
        cell.textLabel?.text = item.text
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.results.count
    }
}

PlaygroundPage.current.liveView = ViewController()
