//
//  ViewController.swift
//  YouTubeCoreDataPractice
//
//  Created by MAC on 2023/09/08.
//

import UIKit
import CoreData

class ViewController: UIViewController {
    
    var context: NSManagedObjectContext {
        guard let app = UIApplication.shared.delegate as? AppDelegate else {
            fatalError() // app로 바인딩하고 안될경우 중단시킴, 바인딩성공시 return 구문으로 넘어감
        }
        
        return app.persistentContainer.viewContext
       
        
    }
    
    
    
    
    
    
    
    
    @IBOutlet var nameField: UITextField!
    
    
    @IBOutlet var ageField: UITextField!
    
    
    @IBAction func creatEntity(_ sender: UIButton) { // 입력된 이름과나이를 저장하는기능 구현
        
        guard let name = nameField.text else {return}
        
//        guard let age = ageField.text else {return} << 원래 이걸로적었으나 setValue는 any타입을 받기때문에 코드상에선 어떤타입을넣어도 오류를 일으키지않음. 하지만 우리는 age 는 int로 저장했기때문에 age를 int화 시켜주는 작업이 필요함. 그래서 다음과같음.
        guard let val = ageField.text , let age = Int(val) else {return}
        
        
        
        
        //⬇️ 새로운 Entity를 생성해주는 메서드
        let newEntity = NSEntityDescription.insertNewObject(forEntityName: "Person", into: context) // Entity를 생성하면 바로 저장소에저장되는것이아님. context를 통해 저장해야 영구저장소에저장되기 떄문에 into: 부분에 context를 작성해줌.
        
        //⬇️ 새로 Entity를 만들땐 이미우리가만들어줬던 name과 age 속성이없는 쌩Entity 기 때문에 setValue를 통하여 값을 만들어줘야함.
        newEntity.setValue(name, forKey: "name")
        newEntity.setValue(age, forKey: "age")
        
        //⬇️hasChanges 를 통하여 저장되지않은 변경사항이있는지 확인. 이걸하는이유는 아무데이터없이 무언가 저장되면 메모리를 낭비하기떄문.
        if context.hasChanges {
            do {
                try context.save()
                print("nice saved")
            } catch {
                print(error)
            }
        }
        
        //⬇️위와같은일들이 다 벌어졌다면 텍스트필드 초기화
        nameField = nil
        ageField = nil
        
        
        
        
    }
    
    
    @IBAction func readEntity(_ sender: UIButton) { // read(읽다) 라고 표현했지만 coreData에서는 읽어오는것을 (가져오다. )fetch 라고 표현한다.
        //⬇️ fetch는 fetchRequest를 불러오는거부터 시작이다. 그리고 NSFetchRequest는 제네릭클래스인데 (제네릭공부해야함 뭔지모름) 이클래스는 읽어올데이터형식을 형식파라미터로 지정해줘야함. 그래서 <> 모양 안에 내가불러올형식인 NSManagedObject 를 작성해준것임. 지금생각해보면 투두앱에서 userDefaults 로 저장했다가 그것을 다시 loadData 하는 과정에서 애초에저장했던타입으로 다시 맞춰주는거랑 비슷한것같음.
        let request = NSFetchRequest<NSManagedObject>(entityName: "Person")
        
        //⬇️ 이과정은..
        do {
            let list = try context.fetch(request)
            //⬇️만약 list 에 값이있다면 첫번째값을 first상수에 할당하고 값이없다면 "아무것도없을" 을 프린팅
            if let first = list.first {
                nameField.text = first.value(forKey: "name") as? String
                //⬇️ 처음 age를 저장할때 setValue는 any타입이여서 String이였던 age 를 int 로 만들어줬었음. 이번엔 불러오는과정이기에 int로 저장이 되어있을테니 int로 불러와서 그것을 string으로 만들어줘야함.
                if let age = first.value(forKey: "age") as? Int {
                    ageField.text = "\(age)"
                }
                
                editTarget = first //‼️
            } else {
                print("아무것도없음")
            }
            
        } catch {
            
        }
        
        
        
    }
    
    //⬇️ update부분 하기 전에 속성하나를 추가해줌. editTarget 변수인데 아마 해석하자면 편집하는타겟을 갖고오기위함인것같음, 그리고 이 변수를 위에있는 first 변수로 할당시킴. (위에코드로 올라가보셈‼️추가)
    var editTarget: NSManagedObject?
    
    @IBAction func updateEntity(_ sender: UIButton) {
        
        guard let name = nameField.text else {return}
        guard let val = ageField.text , let age = Int(val) else {return}
        
        
        if let target = editTarget {
            target.setValue(name, forKey: "name")
            target.setValue(age, forKey: "age")
        }
        //⬇️위에코드중에 따온코드임. 이게 저장을 담당하는거래. context에 변화를 확인하고 하는 과정.
        if context.hasChanges {
            do {
                try context.save()
                print("nice saved")
            } catch {
                print(error)
            }
        }
        
       
        nameField = nil
        ageField = nil
        
        
    }
    
    
    
    
    @IBAction func deleteEntity(_ sender: UIButton) {
        if let target = editTarget {
            context.delete(target) // 이게 context를 통해 지우는것, 근데 영구저장소에선 안된다네? 이대로 지우고나서 다시 Context를통해 값을 덮어씌우듯 저장해야 지워지나봐.
            //⬇️위에코드중에 따온코드임. 이과정이 보다싶이 context.Save하는과정. 이렇게 다시 context를 변경된것확인하고 저장해줘야 영구저장소에서 값이 없어짐.
            if context.hasChanges {
                do {
                    try context.save()
                    print("nice saved")
                } catch {
                    print(error)
                }
            }
            
           
            nameField = nil
            ageField = nil
        }
        
    }
    
    
    
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }


}

