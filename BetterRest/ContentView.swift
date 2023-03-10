//
//  ContentView.swift
//  BetterRest
//
//  Created by David OH on 09/03/2023.
//
import CoreML
import SwiftUI

struct ContentView: View {
    @State private var wakeUp = defaultWakeTime
    @State private var sleepAmt = 8.0
    @State private var coffeeAmt = 1
    @State private var alertTitle = ""
    @State private var alertMsg = ""
    @State private var showAlert = false
    static var defaultWakeTime : Date{
        var components = DateComponents()
        components.hour = 8
        components.minute = 0
        return Calendar.current.date(from: components) ??  Date.now
    }
    
    //find better method of handling nullable errors here
    var calculatedValue: String{
        let config = MLModelConfiguration()
        let model = try! SleepModel(configuration: config)
        let components = Calendar.current.dateComponents([.hour,.minute],from: wakeUp)
        let hour = (components.hour ?? 0) * 60 * 60
        let minute = (components.minute ?? 0) * 60
        let prediction = try! model.prediction(wake: Double(hour + minute), estimatedSleep: Double(sleepAmt), coffee: Double(coffeeAmt))
        return (wakeUp - prediction.actualSleep).formatted(date: .omitted, time: .shortened)
        
    }
    
    
    func calculateBedTime(){
        do {
            let config = MLModelConfiguration()
            let model = try SleepModel(configuration: config)
            let components = Calendar.current.dateComponents([.hour,.minute],from: wakeUp)
            let hour = (components.hour ?? 0) * 60 * 60
            let minute = (components.minute ?? 0) * 60
            let prediction = try model.prediction(wake: Double(hour + minute), estimatedSleep: Double(sleepAmt), coffee: Double(coffeeAmt))
            let sleeptime = wakeUp - prediction.actualSleep
                alertTitle = "Your ideal bedtime is ....."
            alertMsg = sleeptime.formatted(date: .omitted, time: .shortened)
        } catch{
            alertTitle = "Error"
            alertMsg = "Sorry couldn't display your bedtime results"
        }
        showAlert = true
    }
    
    
    var body: some View {
NavigationView{
    Form{
        Section{
            VStack(alignment: .center, spacing: 20){
                Text("when do you want to wake up")
                    .font(.headline)
                    .frame(maxWidth: .infinity, alignment: .center)
                
                DatePicker("Please enter a time", selection: $wakeUp, displayedComponents: .hourAndMinute)
                    .labelsHidden()
            }
        }
        Section{
            VStack(alignment: .leading, spacing: 20){
                Text("Desired Amount of sleep")
                    .font(.headline)
                Stepper("\(sleepAmt.formatted()) hours", value: $sleepAmt,in:  4...12,step: 0.25)
            }
        }
        Section{
            VStack(alignment: .leading, spacing: 20){
                Text("Daily coffee intake")
                    .font(.headline)
                Stepper(coffeeAmt == 1 ? "1 cup" : "\(coffeeAmt) cups", value: $coffeeAmt,in:  1...20)
            }
            
        }
            
            Section{
                VStack( spacing: 20){
                    Text("Your ideal bedtime is .....")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .center)
                    
                    Text(calculatedValue)
                        .font(.title)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .foregroundColor(.gray)
                        .bold()
                }
                
            }
            
        
    }
    .navigationTitle("Better Rest")
                .toolbar{
                    Button("Calculate", action: calculateBedTime)
                }
                .alert(alertTitle,isPresented: $showAlert){
                    Button("Ok"){}
                } message: {
                    Text(alertMsg)
                }
}
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
