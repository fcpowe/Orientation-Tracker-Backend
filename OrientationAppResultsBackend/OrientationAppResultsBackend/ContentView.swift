//
//  ContentView.swift
//  OrientationAppResultsBackend
//
//  Created by Fiona Powers Beggs on 3/16/22.
//

import SwiftUI
import CoreData
import CloudKit


struct MyVariables {
    
    static var myArray: [CKRecord] = [ ]
    static var text = "Get Result"
    static var myString = ""
}
struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Item.timestamp, ascending: true)],
        animation: .default)
    private var items: FetchedResults<Item>

    var body: some View {
        VStack {
            Button(MyVariables.text){
                attempt()
            }
        }
       /* NavigationView {
            List {
                ForEach(items) { item in
                    NavigationLink {
                        Text("Item at \(item.timestamp!, formatter: itemFormatter)")
                    } label: {
                        Text(item.timestamp!, formatter: itemFormatter)
                    }
                }
                .onDelete(perform: deleteItems)
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
                ToolbarItem {
                    Button(action: addItem) {
                        Label("Add Item", systemImage: "plus")
                    }
                }
            }
            Text("Select an item")
        }*/
    }

    private func addItem() {
        withAnimation {
            let newItem = Item(context: viewContext)
            newItem.timestamp = Date()

            do {
                try viewContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            offsets.map { items[$0] }.forEach(viewContext.delete)

            do {
                try viewContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
}

private let itemFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .medium
    return formatter
}()



func attempt() {
   /*let username = ["8504", "AG6703", "EC4334", "SN3256", "IR4906", "NK9790", "LE7954",  "AB2164", "EE8803", "QP7117", "GX4904", "NM6974","MY6914", "AB4312", "HD2261"]*/
    //kinda hard-coded, add list you want to generate of usernames, archive to adhoc and download. Double click .ipa to create app, double click what is created and click get-result to run. To run on new usernames have to archive again after updating the below list. If queries on username that doesn't exist, it will crash.
    let username = ["AB2164", "EE8803", "QP7117", "GX4904", "NM6974","MY6914", "AB4312", "HD2261", "WQ7719",
    "YG4482", "AC2465", "JT3071","UN4308", "AF1478",  "XW6340", "LK8401", "LS1799", "UN8673", "EQ7405", "VD6533", "BS1526", "WH3803", "DU2291", "BA3774", "AY4959", "LG8176", "GS7932", "TX3141", "XB4202", "KU6652", "SU5322", "KL8564", "XH9540", "WL8066", "BD6628", "UK1063", "BY2246", "YD7654", "SY7798", "MX2282", "EP3737", "UT1490", "SX8924", "TM4099", "CH1626", "NG9894", "RA1887", "HE1548", "VA6022", "JK8941", "UN5896", "GD4788", "MZ8165", "SC9910", "HH8049", "BZ6588", "JE7782", "QJ9839", "YN1973" ]
    //let username = ["5529"]
    
    for item in username{
            query(inRecordType: "DirectionGuessSimple", withField : "userKey", equalTo : item  )
        let url = getDocumentsDirectory().appendingPathComponent("allResults.txt")
         MyVariables.text = url.description
        do {
            try (MyVariables.myString).write(to: url, atomically: false, encoding: .utf8)
            var input = try String(contentsOf: url)
            
            //print(input)
            print(url)
        } catch {
            print(error.localizedDescription)
        }
}
    func computeError(val1 : Double, val2: Double) -> Double {
        //actual direction can be negative, so abs val of that
        //direction guess shouldn't be negative - but maybe that's a potential issue
        let compareVal = min(abs(abs(val1)-val2), (abs(360 - abs(val1) - val2)))
      
        return compareVal
    }

    func computeAccuracy(val1 : Double, val2: Double) -> String {
        //actual direction can be negative, so abs val of that
        //direction guess shouldn't be negative - but maybe that's a potential issue
        let compareVal = min(abs(abs(val1)-val2), (abs(360 - abs(val1) - val2)))
      
        if (compareVal <= 30) {
            return ("Within Range")
        }
        else {
            return ("Out of Range")
        }
        /* debugging
         print("CompareVal")
         print(compareVal)
         print("dir degrres")
         print(val1)
         print("guess")
         print(val2)
         print("accuracy")
         print(MyVariables.accuracy)

         */
    }
   
}

func query(inRecordType: String, withField: String, equalTo: String) -> Bool {
    var returnVal = false
    let container = CKContainer(identifier: "iCloud.com.Fiona.OrientationTrackerPhone")
    let publicDatabase = container.publicCloudDatabase
    let pred = NSPredicate(format: "\(withField) == %@", equalTo)
    //let query = CKQuery(recordType: inRecordType, predicate: pred)
    
    let privateDatabase = container.publicCloudDatabase
    let predicate = NSPredicate(format: "\(withField) == %@", equalTo)
    let query = CKQuery(recordType: inRecordType, predicate: predicate)
    let sort = NSSortDescriptor(key: "creationDate", ascending: true)
    query.sortDescriptors = [sort]
    let op = CKQueryOperation(query: query)
    var recordCount = 0
    var Whistle = [CKRecord] ()

    var newWhistles = Whistle
    func getChunk(_ op: CKQueryOperation, _ chunkNum: Int) {
        op.recordFetchedBlock = { rec in
            recordCount += 1
            newWhistles.append(rec)
            print("Count", newWhistles.count)
            
        }
        op.queryCompletionBlock = { cursor, error in
            print("finished chunk \(chunkNum). Count so far: \(recordCount)")
            if let error = error {
                print(error)
            } else if let c = cursor {
                let op = CKQueryOperation(cursor: c)
                getChunk(op, chunkNum+1)
            } else {
                print("Done. Record count = \(recordCount)")
            }
        }
        privateDatabase.add(op)
    }
    getChunk(op, 1)



    //query.sortDescriptors = [NSSortDescriptor(key: "DegreesActual", ascending: true)]
   // print(query)
   /* publicDatabase.perform(query, inZoneWith: nil, completionHandler: {results, er in
            if results != nil {
                print(results!)
                for result in 0...((results?.count ?? 0) - 1) {
                    //print(results![result].value(forKey: "listOfTimes")!)
                    MyVariables.myArray.append(results![result])
                }

                    }
        
                })*/
    do {
        sleep(UInt32(5))
        for result in 0...(newWhistles.count - 1) {
            //print(results![result].value(forKey: "listOfTimes")!)
            MyVariables.myArray.append(newWhistles[result])
        }
        //gives time to check database, otherwise returnval will exit before query is finished
        print("My Array: ")
        //sort array by added date parameter
        var stringToSave = "The string I want to save"
        var userKey = ""
        let path = FileManager.default.urls(for: .documentDirectory,
                                            in: .userDomainMask)[0].appendingPathComponent("myFile")

        var longString = "User Key; Date; Location; Round; Range; Direction Guess; Actual Direction; Degrees Guess; Expected Actual Degrees; Real Actual Degrees; Starting Calibrate Angle; Ending Calibrate Angle; Change Angle; Degrees Moved Calibrate; ListOfTimes; Error"
        
               for value in MyVariables.myArray{
                   //let l4 = value["listOfTimes"].joined(separator: " ")
                  /* let l0 = value["listOfTimes"]!.description.index(0)
                   let l1 = value["listOfTimes"]!.description[1]
                   let l2 = value["listOfTimes"]!.description[2]
                   let l3 = value["listOfTimes"]!.description[3]
                   let stringToSaveE = "ListOfTimes " + l0 + " " +  l1 + " " + l2 + " " +  l3*/
                   var stringToSaveG = "None"
                   if (value["listOfTimes"] != nil){
                       stringToSaveG = value["listOfTimes"]!.description.replacingOccurrences(of: "\n", with: "")
                   }
                   let stringToSaveA = String(Double(value["calibrateStartDegrees"] ?? 0))
                   let stringToSaveB =  String(Double(value["calibrateEndDegrees"] ?? 0))
                   let stringToSaveC =  String(Double(value["calibrateAngle"] ?? 0))
                   let stringToSaveD =  String(Double(value["calibrateStartDegrees"] ?? 0) - Double(value["calibrateEndDegrees"] ?? 0))
                   let stringToSave2 = String(value["ActualGuess"] ?? "None")
                   let stringToSave3 =  value["DegreesActual"]!.description
                   let stringToSave4 =  value["DegreesActualStart"]!.description
                  let stringToSave5 =  value["DegreesGuess"]!.description
                   let val1 = Double(stringToSave3)
                   let val2 = Double(stringToSave5)
                   let stringToSave6 = String(value["DirectionG"] ?? "None")
                   userKey = String(value["userKey"] ?? "None")
                   //let location = value["Location"] ?? "None"
                   var stringToSave7 = ""
                   if (value["Location"] != nil){
                       let val = value["Location"]!.description
                       if (val == ""){
                           stringToSave7 = "Same"

                       }
                       else{
                       stringToSave7 = val
                       }
                   }
                   else {
                       stringToSave7 = "Same"
                   }
                   var stringToSave8 = ""
                   if (value["Date"] != nil){
                       stringToSave8 = value["Date"]!.description
                   }
                   else {
                       stringToSave8 = " None"
                   }
                   var stringToSave9 = ""
                   if (value["LogNum"] != nil){
                       stringToSave9 =  value["LogNum"]!.description
                   }
                   else {
                       stringToSave9 = " None"
                   }
                  
                   
                   let compareVal = min(abs(abs(val1 ?? 0)-abs(val2 ?? 0)), (abs(360 - abs(val1 ?? 0) - abs(val2 ?? 0))))
                   var stringToSave12 = ""
                   if (value["Date"] != nil){
                       stringToSave12 = value["Date"]!.description
                   }
                   else {
                       stringToSave12 = " None"
                  }
                   var stringToSave11 = ""
                   if (compareVal <= 30) {
                      stringToSave11 = ("Within Range")
                   }
                   else {
                       stringToSave11 = ("Out of Range")
                   }
                   
                   //stringToSave = "User Key " + userKey + "\n" + stringToSave8 + "\n" + stringToSave7 + "\n" + stringToSave9 + "\n" + "Range " + stringToSave11 + "\n" + stringToSave2 + "\n" + stringToSave6 + "\n" + stringToSave5 + "\n" + stringToSave4 + "\n" + stringToSave3 + "\n" + stringToSaveA + "\n" + stringToSaveB + "\n" + stringToSaveC + "\n" + stringToSaveD + "\n"  + "ListOfTimes " + stringToSaveG + "\n" + "NextRecord" + "\n" + "\n"
                   stringToSave = "\n" + userKey + ";" + stringToSave8 + ";" + stringToSave7 + ";" + stringToSave9 + ";" + stringToSave11 + ";" + stringToSave2 + ";" + stringToSave6 + ";" + stringToSave5 + ";" + stringToSave4 + ";" + stringToSave3 + ";" + stringToSaveA + ";" + stringToSaveB + ";" + stringToSaveC + ";" + stringToSaveD + ";" + stringToSaveG + ";" + String(compareVal) + ";"
                   //let stringToSave = stringToSave8 + "\n" + stringToSave9 + "\n" + stringToSave2 + "\n" + stringToSave3 + "\n" + stringToSave4 + "\n" + stringToSave5 + "\n" + stringToSave6 + "\n" + stringToSave7 + "\n" + stringToSaveG + "\n"
                  
                 //  print(value["Date"] ?? "None", "ListOfTimes", value["listOfTimes"] ?? "None", "ActualGuess", value["ActualGuess"] ?? "None", "DegreesActual", value["DegreesActual"] ?? "None", "DegreesActualStart", value["DegreesActualStart"] ?? "None", "DegreesGuess", value["DegreesGuess"] ?? "None", "DirectionG", value["DirectionG"] ?? "None", "userKey", value["userKey"] ?? "None",  "LogNum", value["LogNum"] ?? "None", "Location", value["Location"] ?? "None")
                   longString = longString + stringToSave
                   var str = longString
                           let url = getDocumentsDirectory().appendingPathComponent(userKey + "results.txt")
                            MyVariables.text = url.description
                           do {
                               try str.write(to: url, atomically: false, encoding: .utf8)
                               var input = try String(contentsOf: url)
                               
                               //print(input)
                               print(url)
                           } catch {
                               print(error.localizedDescription)
                           }
                   MyVariables.text =
                   url.absoluteString
               }
        MyVariables.myString = MyVariables.myString + longString

     
        if let stringData = stringToSave.data(using: .utf8) {
            try? stringData.write(to: path)
        }
       // print(MyVariables.myArray[0]["createdTimestamp"])
       
    }
    MyVariables.myArray = []
    return true
    
}

func getDocumentsDirectory() -> URL {
    let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
    return paths[0]
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
