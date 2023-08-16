import UIKit

var greeting:String = "Hello, playground"
let greetding="Hello world"

func getUpperCase(_ name:String)-> Bool{
    return name == name.uppercased();
}

func greet( person:String="Mr", formal:Bool=false){
    if(formal){
        print("Welcome \(person)")
    }else{
        print("hy \(person)")
    }
}

//greet(formal:false);


enum PasswordErrors:Error {
    case short, obvious;
}

func checkPassword(_ password:String) throws  {
    if password.count<5 {
        throw PasswordErrors.short
    }
    if password=="12345" {
        throw PasswordErrors.obvious
    }
    if password.count<10 {
//        return ("Ok");
    }else{
//        return ("Strong");
    }
}

do{
    try checkPassword("12345");
} catch PasswordErrors.short {
//    print("Short Password Error");
} catch PasswordErrors.obvious {
//    print("Password obvious");
} catch {
//    print("Password Error");
}



let sayHello = { (name:String , gentelmen:Bool)->String in
    print("hello there \(name)")
    return "hello there \(name)"
}
//print(sayHello("Haider",false))

let team:Array=["ctalcs","ats","ags","pks"];
let onlyT = team.filter{ (name:String) -> Bool in
     name.hasPrefix("t")
};

//print(onlyT);

let onlyA = team.filter{$0.hasPrefix("a")}
//print(onlyA);

struct album{
    let title:String
    let artist:String
    var isReleased:Bool=true
    var vacationAllowed=10
    var vacationTaken=4
    var vacationRemaining:Int {
        get{
            vacationAllowed-vacationTaken
        }
        set{
            vacationAllowed-vacationTaken
        }
    }
    
    func showAlbum() {
        print(title,"by",artist,"released",isReleased);
    }
    
   mutating func removeFromSale(){
        isReleased=false;
    }
    
}
var first = album(title: "hy hy", artist: "taylor swift")
first.removeFromSale();

//first.showAlbum();
//print(first.vacationRemaining);



struct Game{
    var score:Int {
        didSet{
            print("new Score is \(score)")
        }
        willSet{
            print("prev Score is \(score)")
        }
    }
}

var game=Game(score: 10);
//game.score+=10;


struct player {
    private(set) var name:String;
    private(set) var age:Int
    
    init(name:String) {
        self.name=name
        self.age=Int.random(in:1...10)
    }
   mutating func changeAge(age:Int){
        self.age=age;
    }
}

var p = player(name: "Haider")
p.changeAge(age: 10)



struct AppData{
    static let version:String="1.2.3"
    
}

//print(AppData.version)



class Employee{
    let name:String;
    
    init(name:String){
        self.name=name;
    }
    func printSummary(){
        print("working hard as an employee");
    }
}

class Programmer{
    let hours:Int;
    init(hours:Int) {
        self.hours=hours
        print("initializing the object")
    }
    deinit{
        print("de initializing the object")
    }
}

for _ in 1...3{
//    let haider=Programmer( hours: i)
}

class Practice{
    var hours:Int
    init(hours:Int){
        self.hours=hours
    }
    
}

// Protocols

protocol Vehacle{
    var name:String {get}
    var passengerCount:Int {get}
    func estametedTime(for distance:Int)->Int
    func Travel(distance:Int)
}

struct Car: Vehacle {
    var name: String
    var passengerCount:Int
    
    init(name:String, passengerCount:Int){
        self.name=name
        self.passengerCount=passengerCount
    }
    
    func estametedTime(for distance:Int)->Int {
        distance/50
    }
    func Travel(distance:Int) {
        print("i am traveling \(distance)km in my \(name)")
    }
    func openSunroof(){
        print("its a very nice day")
    }
}

func commute(distance:Int,Vehacle:Car){
    
    if(Vehacle.estametedTime(for: distance)>100){
        print("Too slow",Vehacle.passengerCount );
    }else{
        Vehacle.Travel(distance: distance)
    }
}
var car = Car(name: "Bmw", passengerCount: 2)

//commute(distance: 100000, Vehacle: car)


//Extentions
extension String{
    func trimmed()-> String{
        self.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    mutating func trim(){
        self = self.trimmed()
    }
    var trimmedString:String{
        self.replacingOccurrences(of: "\n+", with: "",options: .regularExpression).trimmingCharacters(in: .whitespacesAndNewlines)
    }
    var lines:[String]{
        self.components(separatedBy: .newlines)
    }
}

var quote="  the truth is simple and pure    ";
var trimmedQuote=quote.trimmed()
//print(trimmedQuote)

let lyrics="""
        i hate you
 when you call me swift

"""
//print(lyrics.trimmedString)


extension Collection{
    var isNotEmpty:Bool{
     return   isEmpty == false
    }
    
}
let arr=["asdf","asdf","ddf"]
var st=""
//print(st.isNotEmpty)

let opposites=[
    "1":"value1",
    "2":"value2"
]

//if let ten = opposites["1"] {
//    print(ten);
//}

// guard let

func printSquare(of number:Int?){
    guard let number=number else{
        print("number is missing")
        return
    }
    print("\(number) x \(number) is \(number * number)")
}
//printSquare(of: 10)

let tvShowes=["GOT","Sacred Games","witcher"]
let bestShow = tvShowes.randomElement() ?? "none"
//print(bestShow)

let str=""
let num=Int(str) ?? 0
print(num)
