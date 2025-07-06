import SwiftUI
import PhotosUI
import FirebaseFunctions

// MARK: - Main View

struct CameraGalleryView: View {
    @Binding var showPaywall: Bool

    init(showPaywall: Binding<Bool>) {
        self._showPaywall = showPaywall
    }

    // State Properties
    @State private var showingCamera = false
    @State private var inputImage: UIImage?
    @State private var selectedItem: PhotosPickerItem?
    @State private var navigateToResults = false
    @State private var isIdentifying = false
    @State private var identificationResult: RockIdentificationResult?
    @State private var errorMessage: String?
    @State private var showErrorAlert = false
    @State private var showImageSourceSelector = false
    @State private var showPhotoPicker = false
    @EnvironmentObject private var userManager: UserManager

    var body: some View {
        NavigationStack {
            ZStack {
                ThemeColors.background.edgesIgnoringSafeArea(.all)

                VStack(spacing: 20) {
                    Spacer()

                    if let inputImage = inputImage {
                        ImagePreview(image: inputImage, onClear: clearImage)
                            .transition(.asymmetric(insertion: .scale(scale: 0.8).combined(with: .opacity), removal: .opacity))
                    } else {
                        placeholder
                            .transition(.asymmetric(insertion: .opacity, removal: .scale(scale: 0.8).combined(with: .opacity)))
                    }

                    Spacer()

                    if inputImage != nil {
                        identifyButton
                            .transition(.asymmetric(insertion: .move(edge: .bottom).combined(with: .opacity), removal: .opacity))
                    }
                }
                .padding(.horizontal)
                .padding(.bottom)
                .animation(.spring(response: 0.5, dampingFraction: 0.8, blendDuration: 0), value: inputImage)

                // Overlays
                if isIdentifying {
                    AnalyzingView()
                }
                
                // Navigation
                if let result = identificationResult, let image = inputImage {
                    NavigationLink(destination: ResultsView(result: result, image: image), isActive: $navigateToResults) {
                        EmptyView()
                    }
                }
            }
            .navigationTitle("Crystara")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showPaywall = true }) {
                        Image(systemName: "crown.fill")
                            .foregroundColor(ThemeColors.primaryAction)
                    }
                }
            }
            .fullScreenCover(isPresented: $showingCamera) {
                ImagePicker(sourceType: .camera, selectedImage: $inputImage)
                    .ignoresSafeArea()
            }
            .onChange(of: selectedItem, perform: loadImage)
            .confirmationDialog("Select a Photo", isPresented: $showImageSourceSelector, titleVisibility: .visible) {
                Button("Camera") { showingCamera = true }
                Button("Photo Library") { showPhotoPicker = true }
            }
            .photosPicker(isPresented: $showPhotoPicker, selection: $selectedItem, matching: .images)
            .alert(isPresented: $showErrorAlert) {
                Alert(
                    title: Text("Identification Failed"),
                    message: Text(errorMessage ?? "An unknown error occurred."),
                    dismissButton: .default(Text("OK"))
                )
            }
        }
    }
}

// MARK: - View Components

private extension CameraGalleryView {
    var placeholder: some View {
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
    }

    var identifyButton: some View {
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
    }
}

// MARK: - Logic Methods

private extension CameraGalleryView {
    func clearImage() {
        inputImage = nil
        selectedItem = nil
        identificationResult = nil
    }

    func loadImage(from newItem: PhotosPickerItem?) {
        Task {
            guard let newItem = newItem, let data = try? await newItem.loadTransferable(type: Data.self) else { return }
            if let newImage = UIImage(data: data) {
                inputImage = newImage
            }
        }
    }

    func performIdentification() {
        isIdentifying = true

        guard let image = inputImage else {
            errorMessage = "Could not process the selected image."
            showErrorAlert = true
            isIdentifying = false
            return
        }

        guard let historyImageData = image.jpegData(compressionQuality: 1.0) else {
            errorMessage = "Could not process the selected image for history."
            showErrorAlert = true
            isIdentifying = false
            return
        }

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

// MARK: - Helper Views

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

// MARK: - Preview

struct CameraGalleryView_Previews: PreviewProvider {
    static var previews: some View {
        CameraGalleryView(showPaywall: .constant(false))
            .environmentObject(UserManager())
    }
}

