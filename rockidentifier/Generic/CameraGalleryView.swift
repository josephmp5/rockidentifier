import SwiftUI
import PhotosUI
import FirebaseFunctions

struct CameraGalleryView: View {
    // Image & Navigation State
    @State private var showingCamera = false
    @State private var inputImage: UIImage?
    @State private var selectedItem: PhotosPickerItem?
    @State private var navigateToResults = false

    // API & Loading State
    @State private var isIdentifying = false
    @State private var identificationResult: RockIdentificationResult?
    @State private var errorMessage: String?
    @State private var showErrorAlert = false

    // Image Selection State
    @State private var showImageSourceSelector = false
    @State private var showPhotoPicker = false

    // Token & Paywall State
    @EnvironmentObject private var userManager: UserManager
    @State private var showPaywall = false

    private var greeting: String {
        return "Identify a New Rock"
    }

    var body: some View {
        ZStack {
            ThemeColors.background.edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 20) {


                Spacer()

                if let inputImage = inputImage {
                    ImagePreview(image: inputImage, onClear: clearImage)
                        .transition(.asymmetric(insertion: .scale(scale: 0.8).combined(with: .opacity), removal: .opacity))
                } else {
                    // Clickable Placeholder
                    VStack(spacing: 16) {
                        Image(systemName: "photo.on.rectangle.angled")
                            .font(.system(size: 60))
                            .foregroundColor(ThemeColors.primaryAction.opacity(0.8))
                        Text("Select a Photo to Begin")
                            .font(.system(size: 20, weight: .bold, design: .serif))
                            .foregroundColor(ThemeColors.primaryText)
                        Text("Choose an image from your gallery or take a new one with your camera.")
                            .font(.subheadline)
                            .foregroundColor(ThemeColors.secondaryText)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                    }
                    .padding(30)
                    .frame(maxWidth: .infinity)
                    .background(ThemeColors.surface)
                    .cornerRadius(20)
                    .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
                    .onTapGesture {
                        showImageSourceSelector = true
                    }
                    .transition(.asymmetric(insertion: .opacity, removal: .scale(scale: 0.8).combined(with: .opacity)))
                }

                Spacer()

                if inputImage != nil {
                    Button(action: performIdentification) {
                        Text("Identify This Rock")
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(ThemeColors.primaryAction)
                            .cornerRadius(16)
                    }
                    .disabled(isIdentifying)
                    .transition(.asymmetric(insertion: .move(edge: .bottom).combined(with: .opacity), removal: .opacity))
                }
            }
            .padding(.horizontal)
            .padding(.bottom)
            .animation(.spring(response: 0.5, dampingFraction: 0.8, blendDuration: 0), value: inputImage)
            
            // Loading Overlay
            if isIdentifying {
                Color.black.opacity(0.6).edgesIgnoringSafeArea(.all)
                AnalyzingView()
            }
            
            // Invisible navigation link
            if let result = identificationResult, let image = inputImage {
                NavigationLink(destination: ResultsView(result: result, image: image), isActive: $navigateToResults) {
                    EmptyView()
                }
            }
        }
        .fullScreenCover(isPresented: $showingCamera) {
            ImagePicker(sourceType: .camera, selectedImage: $inputImage)
                .ignoresSafeArea()
        }
        .onChange(of: selectedItem, perform: loadImage)
        .confirmationDialog("Select a Photo", isPresented: $showImageSourceSelector, titleVisibility: .visible) {
            Button("Camera") {
                showingCamera = true
            }
            Button("Photo Library") {
                showPhotoPicker = true
            }
        }
        .photosPicker(isPresented: $showPhotoPicker, selection: $selectedItem, matching: .images)
        .alert(isPresented: $showErrorAlert) {
            Alert(
                title: Text("Identification Failed"),
                message: Text(errorMessage ?? "An unknown error occurred."),
                dismissButton: .default(Text("OK"))
            )
        }
        .sheet(isPresented: $showPaywall) {
            PaywallView(isModal: true)
                .interactiveDismissDisabled()
        }
        .navigationBarHidden(true)
    }

    private func clearImage() {
        inputImage = nil
        selectedItem = nil
        identificationResult = nil
    }

    private func loadImage(from newItem: PhotosPickerItem?) {
        Task {
            guard let newItem = newItem, let data = try? await newItem.loadTransferable(type: Data.self) else { return }
            if let newImage = UIImage(data: data) {
                inputImage = newImage
            }
        }
    }

    private func performIdentification() {
        isIdentifying = true

        guard let image = inputImage else {
            errorMessage = "Could not process the selected image."
            showErrorAlert = true
            isIdentifying = false
            return
        }

        // High-quality data for history
        guard let historyImageData = image.jpegData(compressionQuality: 1.0) else {
            errorMessage = "Could not process the selected image for history."
            showErrorAlert = true
            isIdentifying = false
            return
        }

        // Resized, compressed data for the API call to make it fast
        guard let apiImageData = image.resized(to: CGSize(width: 1024, height: 1024), compressionQuality: 0.8) else {
            errorMessage = "Could not resize the image for identification."
            showErrorAlert = true
            isIdentifying = false
            return
        }

        guard let user = userManager.user else {
            errorMessage = "Could not verify your user profile. Please check your connection and try again."
            showErrorAlert = true
            isIdentifying = false
            return
        }

        if !user.hasAccess {
            showPaywall = true
            isIdentifying = false
            return
        }
        
        FirebaseAPIService.shared.identifyRock(imageData: apiImageData) { result in
            DispatchQueue.main.async {
                self.isIdentifying = false

                switch result {
                case .success(let identificationResult):
                    self.identificationResult = identificationResult
                    HistoryManager.shared.add(imageData: historyImageData, rockName: identificationResult.rockName)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        self.navigateToResults = true
                    }
                    
                case .failure(let error):
                    let nsError = error as NSError
                    if nsError.domain == FunctionsErrorDomain,
                       let code = FunctionsErrorCode(rawValue: nsError.code),
                       code == .failedPrecondition {
                        self.errorMessage = nsError.userInfo[FunctionsErrorDetailsKey] as? String ?? "You are out of tokens."
                        self.showPaywall = true
                    } else {
                        self.errorMessage = "An unexpected error occurred: \(error.localizedDescription)"
                        self.showErrorAlert = true
                    }
                }
            }
        }
    }
}

// MARK: - Redesigned Subviews

struct ImagePreview: View {
    let image: UIImage
    var onClear: () -> Void

    var body: some View {
        ZStack(alignment: .topTrailing) {
            Image(uiImage: image)
                .resizable()
                .scaledToFit()
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .shadow(color: .black.opacity(0.3), radius: 10, y: 5)

            Button(action: onClear) {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 32))
                    .symbolRenderingMode(.palette)
                    .foregroundStyle(.white, Color.black.opacity(0.6))
                    .shadow(color: .black.opacity(0.5), radius: 3, x: 0, y: 2)
            }
            .padding(8)
        }
    }
}

struct PlaceholderImageView: View {
    var body: some View {
        VStack {
            Image(systemName: "mountain.2.fill")
                .font(.system(size: 80))
                .foregroundColor(ThemeColors.accent)
            Text("Select a photo to begin")
                .font(.title3)
                .fontWeight(.medium)
                .foregroundColor(ThemeColors.secondaryText)
        }
        .frame(maxWidth: .infinity, maxHeight: 350)
        .background(ThemeColors.surface.opacity(0.5))
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(ThemeColors.accent, style: StrokeStyle(lineWidth: 2, dash: [10]))
        )
        .padding(.horizontal, 20)
    }
}

struct ActionButtonsView: View {
    @Binding var showingCamera: Bool
    @Binding var selectedItem: PhotosPickerItem?

    var body: some View {
        VStack(spacing: 16) {
            PhotosPicker(
                selection: $selectedItem,
                matching: .images,
                photoLibrary: .shared()
            ) {
                HStack {
                    Image(systemName: "photo.on.rectangle.angled")
                    Text("Choose from Library")
                }
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(ThemeColors.primaryText)
                .padding()
                .frame(maxWidth: .infinity)
                .background(ThemeColors.surface)
                .cornerRadius(12)
            }
            
            Button(action: { showingCamera = true }) {
                HStack {
                    Image(systemName: "camera.fill")
                    Text("Use Camera")
                }
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(ThemeColors.primaryText)
                .padding()
                .frame(maxWidth: .infinity)
                .background(ThemeColors.surface)
                .cornerRadius(12)
            }
        }
    }
}

struct PrimaryButton: View {
    let title: String
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 18, weight: .bold, design: .default))
                .foregroundColor(ThemeColors.background)
                .padding(.vertical, 15)
                .frame(maxWidth: .infinity)
                .background(ThemeColors.primaryText)
                .cornerRadius(12)
                .shadow(color: ThemeColors.primaryText.opacity(0.3), radius: 8, y: 4)
        }
    }
}

// ImagePicker remains the same
struct ImagePicker: UIViewControllerRepresentable {
    var sourceType: UIImagePickerController.SourceType = .photoLibrary
    @Binding var selectedImage: UIImage?
    @Environment(\.presentationMode) private var presentationMode

    func makeUIViewController(context: UIViewControllerRepresentableContext<ImagePicker>) -> UIImagePickerController {
        let imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = false
        imagePicker.sourceType = sourceType
        imagePicker.delegate = context.coordinator
        return imagePicker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: UIViewControllerRepresentableContext<ImagePicker>) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    final class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        var parent: ImagePicker

        init(_ parent: ImagePicker) {
            self.parent = parent
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
                parent.selectedImage = image
            }
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}

struct CameraGalleryView_Previews: PreviewProvider {
    static var previews: some View {
        CameraGalleryView()
    }
}

