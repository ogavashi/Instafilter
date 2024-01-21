//
//  ContentView.swift
//  Instafilter
//
//  Created by Oleg Gavashi on 20.01.2024.
//

import SwiftUI
import PhotosUI
import CoreImage
import CoreImage.CIFilterBuiltins
import StoreKit


struct FilterOption {
    let key: String
    let label: String
    let filter: CIFilter
}


struct ContentView: View {
    @AppStorage("filterCount") var filterCount = 0
    @Environment(\.requestReview) var requestReview
    
    @State private var selectedItem: PhotosPickerItem?
    @State private var processedImage: Image?
    @State private var beginImage: CIImage?
    @State private var filterIntensity = 0.5
    
    @State private var currentFilter: CIFilter = CIFilter.sepiaTone()
    let context = CIContext()
    
    @State private var showingFilters = false
    
    private let filterOptions: [FilterOption] = [
        FilterOption(key: "crystallize", label: "Crystallize", filter: CIFilter.crystallize()),
        FilterOption(key: "gaussianBlur", label: "Gaussian Blur", filter: CIFilter.gaussianBlur()),
        FilterOption(key: "pixellate", label: "Pixellate", filter: CIFilter.pixellate()),
        FilterOption(key: "sepiaTone", label: "Sepia Tone", filter: CIFilter.sepiaTone()),
        FilterOption(key: "unsharpMask", label: "Unsharp Mask", filter: CIFilter.unsharpMask()),
        FilterOption(key: "vignette", label: "Vignette", filter: CIFilter.vignette())
    ]
    
    var body: some View {
        NavigationStack {
            VStack {
                Spacer()
                PhotosPicker(selection: $selectedItem) {
                    if let processedImage {
                        processedImage
                            .resizable()
                            .scaledToFit()
                    } else {
                        ContentUnavailableView("No Picture", systemImage: "photo.badge.plus", description: Text("Tap to import a photo"))
                    }
                }
                .onChange(of: selectedItem, loadImage)
                
                Spacer()
                
                HStack {
                    Text("Intensity")
                    Slider(value: $filterIntensity)
                        .onChange(of: filterIntensity, applyFilter)
                        .disabled(beginImage == nil)
                }
                .padding(.vertical)
                
                HStack {
                    Button("Change filter", action: changeFilter)
                        .disabled(beginImage == nil)
                    
                    Spacer()
                    
                    if let processedImage {
                        ShareLink(item: processedImage, preview: SharePreview("Instafilter image", image: processedImage))
                    }
                }
                
            }
            .padding([.horizontal, .bottom])
            .navigationTitle("Instafilter")
            .confirmationDialog("Select a filter", isPresented: $showingFilters) {
                ForEach(filterOptions, id: \.key) { option in
                    Button(option.label) {setFilter(option.filter)}
                }
                Button("Cancel", role: .cancel) { }
            }
        }
    }
    
    func changeFilter() {
        showingFilters = true
    }
    
    func loadImage() {
        Task {
            guard let imageData = try await selectedItem?.loadTransferable(type: Data.self) else { return
            }
            guard let inputImage = UIImage(data: imageData) else {
                return
            }
            
            beginImage = CIImage(image: inputImage)
            applyFilter()
        }
    }
    
    func applyFilter() {
        currentFilter.setValue(beginImage, forKey: kCIInputImageKey)
        
        let inputKeys = currentFilter.inputKeys
        
        for key in inputKeys {
            switch key {
            case kCIInputIntensityKey:
                currentFilter.setValue(filterIntensity, forKey: key)
            case kCIInputRadiusKey:
                currentFilter.setValue(filterIntensity * 200, forKey: key)
            case kCIInputScaleKey:
                currentFilter.setValue(filterIntensity * 10, forKey: key)
            default:
                break
            }
        }
        
        guard let outputImage = currentFilter.outputImage else { return }
        guard let cgImage = context.createCGImage(outputImage, from: outputImage.extent) else { return }
        
        let uiImage = UIImage(cgImage: cgImage)
        processedImage = Image(uiImage: uiImage)
    }
    
    @MainActor func setFilter(_ filter: CIFilter) {
        currentFilter = filter
        applyFilter()
        
        filterCount += 1
        
        if filterCount >= 20 {
            requestReview()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
