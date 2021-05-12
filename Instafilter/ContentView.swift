//
//  ContentView.swift
//  Instafilter
//
//  Created by Esben Viskum on 08/05/2021.
//

import SwiftUI
import CoreImage
import CoreImage.CIFilterBuiltins


struct ContentView: View {
/*    @State private var blurAmount: CGFloat = 0
    
    @State private var showingActionSheet = false
    @State private var backgroundColor = Color.white */
    
/*    @State private var image: Image?
    
    @State private var showingImagePicker = false
    
    @State private var inputImage: UIImage? */
/*
    func loadImage() {
        guard let inputImage = UIImage(named: "solsol") else { return }
        let beginImage = CIImage(image: inputImage)
        
        let context = CIContext()
//        let currentFilter = CIFilter.sepiaTone()
//        currentFilter.inputImage = beginImage
//        currentFilter.intensity = 1
//        let currentFilter = CIFilter.pixellate()
//        currentFilter.inputImage = beginImage
//        currentFilter.scale = 50
//        let currentFilter = CIFilter.crystallize()
//        currentFilter.inputImage = beginImage
//        currentFilter.radius = 200
//        currentFilter.setValue(beginImage, forKey: kCIInputImageKey)
//        currentFilter.radius = 20
        guard let currentFilter = CIFilter(name: "CITwirlDistortion") else { return }
        currentFilter.setValue(beginImage, forKey: kCIInputImageKey)
        currentFilter.setValue(200, forKey: kCIInputRadiusKey)
        currentFilter.setValue(CIVector(x: inputImage.size.width / 2, y: inputImage.size.height / 2), forKey: kCIInputCenterKey)
        
        guard let outputImage = currentFilter.outputImage else { return }
        if let cgimage = context.createCGImage(outputImage, from: outputImage.extent) {
            let uiImage = UIImage(cgImage: cgimage)
            image = Image(uiImage: uiImage)
        }
        
//        image = Image("solsol")
    }
*/
    
    @State private var image: Image?
    @State private var filterIntensity = 0.5
    @State private var filterRadius = 100.0
    @State private var filterScale = 5.0

    @State private var showingAlert = false
    @State private var showingFilterSheet = false
    @State private var showingImagePicker = false
    @State private var inputImage: UIImage?
    @State private var processedImage: UIImage?
    
    @State private var currentFilter: CIFilter = CIFilter.sepiaTone()
    let context = CIContext()

    @State private var alertTitle = ""
    @State private var alertMessage = ""
    
    @State private var selectedFilterName = "Change filter"
    
    @State private var disableIntensity = true
    @State private var disableRadius = true
    @State private var disableScale = true
    
    var body: some View {
        let intensity = Binding<Double>(
            get: {
                self.filterIntensity
            },
            set: {
                self.filterIntensity = $0
                self.applyProcessing()
            }
        )
        let radius = Binding<Double>(
            get: {
                self.filterRadius
            },
            set: {
                self.filterRadius = $0
                self.applyProcessing()
            }
        )
        let scale = Binding<Double>(
            get: {
                self.filterScale
            },
            set: {
                self.filterScale = $0
                self.applyProcessing()
            }
        )

        NavigationView {
            VStack {
                ZStack {
                    Rectangle()
                        .fill(Color.secondary)
                    
                    if image != nil {
                        image?
                            .resizable()
                            .scaledToFit()
                    } else {
                        Text("Tap to select a picture")
                            .foregroundColor(.white)
                            .font(.headline)
                    }
                }
                .onTapGesture {
                    // select an image
                    self.showingImagePicker = true
                }
                
                HStack {
                    Text("Intensity")
                    Slider(value: intensity)
                        .disabled(disableIntensity)
                }
                .padding(.top)

                HStack {
                    Text("Radius")
                    Slider(value: radius, in: 10...200)
                        .disabled(disableRadius)
                }
//                .padding(.vertical)

                HStack {
                    Text("Scale")
                    Slider(value: scale, in: 1...10)
                        .disabled(disableScale)
                }
                .padding(.bottom)

                HStack {
                    Button(selectedFilterName) {
                        // change filter
                        self.showingFilterSheet = true
                    }
                    
                    Spacer()
                    
                    Button("Save") {
                        // save the picture
                        if image == nil {
                            alertTitle = "Unable to save"
                            alertMessage = "No image selected"
                            showingAlert = true
                            return
                        }
                        
                        guard let processedImage = self.processedImage else { return }
                        
                        let imageSaver = ImageSaver()
                        
                        imageSaver.successHandler = {
                            print("Succes!")
                        }
                        
                        imageSaver.errorHandler = {
                            print("Oops: \($0.localizedDescription)")
                        }
                        
                        imageSaver.writeToPhotoAlbum(image: processedImage)
                    }
                }
            }
        }
        .padding([.horizontal, .bottom])
        .navigationBarTitle("Instafilter")
        .sheet(isPresented: $showingImagePicker, onDismiss: loadImage, content: {
            ImagePicker(image: self.$inputImage)
        })
        .actionSheet(isPresented: $showingFilterSheet, content: {
            ActionSheet(title: Text("Select a filter"), buttons: [
                .default(Text("Crystallize")) {
                    self.setFilter(CIFilter.crystallize())
                    selectedFilterName = "Crystallize"
                },
                .default(Text("Edges")) {
                    self.setFilter(CIFilter.edges())
                    selectedFilterName = "Edges"
                },
                .default(Text("Gaussian Blur")) {
                    self.setFilter(CIFilter.gaussianBlur())
                    selectedFilterName = "Gaussian Blur"
                },
                .default(Text("Pixellate")) {
                    self.setFilter(CIFilter.pixellate())
                    selectedFilterName = "Pixellate"
                },
                .default(Text("Sepia Tone")) {
                    self.setFilter(CIFilter.sepiaTone())
                    selectedFilterName = "Sephia Tone"
                },
                .default(Text("Unsharp Mask")) {
                    self.setFilter(CIFilter.unsharpMask())
                    selectedFilterName = "Unsharp Mask"
                },
                .default(Text("Vignette")) {
                    self.setFilter(CIFilter.vignette())
                    selectedFilterName = "Vignette"
                },
                .cancel()
            ])
        })
        .alert(isPresented: $showingAlert, content: {
            Alert(title: Text(alertTitle), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        })
        
        
/*        VStack {
            image?
                .resizable()
                .scaledToFit()
            
            Button("Select Image") {
                self.showingImagePicker = true
            }
        }
        .sheet(isPresented: $showingImagePicker, onDismiss: loadImage) {
            ImagePicker(image: self.$inputImage)
        } */
        
        
        
/*        VStack {
            image?
                .resizable()
                .scaledToFit()
        }
        .onAppear(perform: loadImage) */
        
        
        
/*        Text("Hello World")
            .frame(width: 300, height: 300)
            .background(backgroundColor)
            .onTapGesture {
                self.showingActionSheet = true
            }
            .actionSheet(isPresented: $showingActionSheet, content: {
                ActionSheet(title: Text("Change background"), message: Text("Select a colour"), buttons: [
                    .default(Text("Red")) { self.backgroundColor = .red},
                    .default(Text("Green")) { self.backgroundColor = .green},
                    .default(Text("Blue")) { self.backgroundColor = .blue},
                    .cancel()
                ])
            }) */
        
        
/*        let blur = Binding<CGFloat>(
            get: {
                self.blurAmount
            },
            set: {
                self.blurAmount = $0
                print("New value is \(self.blurAmount)")
            })
        
        VStack {
            Text("Hello, world!")
                .blur(radius: blurAmount)
                .padding()
            
            Slider(value: blur, in: 0...20)
        } */
    }

/*    func loadImage() {
        guard let inputImage = inputImage else { return }
        image = Image(uiImage: inputImage)
        let imageSaver = ImageSaver()
        imageSaver.writeToPhotoAlbum(image: inputImage)
//        UIImageWriteToSavedPhotosAlbum(inputImage, nil, nil, nil)
    } */


}

extension ContentView {
    func loadImage() {
        guard let inputImage = inputImage else { return }
//        image = Image(uiImage: inputImage)
        let beginImage = CIImage(image: inputImage)
        currentFilter.setValue(beginImage, forKey: kCIInputImageKey)
        applyProcessing()
    }
    
    func applyProcessing() {
//        currentFilter.intensity = Float(filterIntensity)
//        currentFilter.setValue(filterIntensity, forKey: kCIInputIntensityKey)
        disableRadius = true
        disableIntensity = true
        disableScale = true
        print("Disable all")
        let inputKeys = currentFilter.inputKeys
        if inputKeys.contains(kCIInputIntensityKey) {
            currentFilter.setValue(filterIntensity, forKey: kCIInputIntensityKey)
            disableIntensity = false
            print("Enable intensity")
        }
        if inputKeys.contains(kCIInputRadiusKey) {
            currentFilter.setValue(filterRadius, forKey: kCIInputRadiusKey)
            disableRadius = false
            print("Enable radius")
        }
        if inputKeys.contains(kCIInputScaleKey) {
            currentFilter.setValue(filterScale, forKey: kCIInputScaleKey)
            disableScale = false
            print("Enable scale")
        }

        guard let outputImage = currentFilter.outputImage else { return }
        
        if let cgimg = context.createCGImage(outputImage, from: outputImage.extent) {
            let uiImage = UIImage(cgImage: cgimg)
            image = Image(uiImage: uiImage)
            processedImage = uiImage
        }
    }
    
    func setFilter(_ filter: CIFilter) {
        currentFilter = filter
        loadImage()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
