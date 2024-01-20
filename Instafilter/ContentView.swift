//
//  ContentView.swift
//  Instafilter
//
//  Created by Oleg Gavashi on 20.01.2024.
//

import SwiftUI

struct ContentView: View {
    @State private var processedImage: Image?
    @State private var filterIntensity = 0.5
    
    var body: some View {
        NavigationStack {
            VStack {
                Spacer()
                
//                if let processedImage {
//                    processedImage
//                        .resizable()
//                        .scaledToFit()
//                } else {
//                    ContentUnavailableView("No Picture", systemImage: "photo.badge.plus", description: Text("Tap to import a photo"))
//                }
                
                Spacer()
                
                HStack {
                    Text("Intensity")
                    Slider(value: $filterIntensity)
                }
                .padding(.vertical)
                
                HStack {
                    Button("Change filter", action: changeFilter)
                    
                    Spacer()
                    
                    //Share
                }
                
            }
            .padding([.horizontal, .bottom])
            .navigationTitle("Instafilter")
        }
    }
    
    func changeFilter() {
        
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
