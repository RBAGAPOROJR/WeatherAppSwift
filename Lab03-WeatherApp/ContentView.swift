//
//  ContentView.swift
//  Lab03-WeatherApp
//
//  Created by RNLD on 2023-11-15.
//
import SwiftUI


struct ContentView : View {
    var body : some View {
        ScrollView {
            VStack( spacing : 10 ) {
                ForEach( 0..<10 ) {
                    Text( "Item \($0)" )
                        .font( .title )
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
