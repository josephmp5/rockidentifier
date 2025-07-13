import SwiftUI
import PhotosUI
import FirebaseFunctions

struct ViewFrameKey: PreferenceKey {
    static var defaultValue: CGRect = .zero
    static func reduce(value: inout CGRect, nextValue: () -> CGRect) {
        value = nextValue()
    }
}

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
    @State private var placeholderFrame: CGRect = .zero
    @EnvironmentObject private var userManager: UserManager

    var body: some View {
        VStack(spacing: 20) {
            // Always show header
            headerView
            
            if isIdentifying {
                AnalyzingView()
            } else if let inputImage = inputImage {
                // Show image with some spacing
                Spacer(minLength: 20)
                ImagePreview(image: inputImage, onClear: clearImage)
                    .transition(.asymmetric(insertion: .scale(scale: 0.8).combined(with: .opacity), removal: .opacity))
                
                // Keep some informational text
                Text("Ready to identify your rock?")
                    .font(.system(size: 18, weight: .medium, design: .serif))
                    .foregroundColor(ThemeColors.secondaryText)
                    .padding(.top, 10)
                
                identifyButton
                Spacer()
            } else {
                Spacer()
                placeholder
                Spacer()
            }
        }
        .padding(.horizontal)
        .background(ThemeColors.background.edgesIgnoringSafeArea(.all))
        .animation(.spring(response: 0.5, dampingFraction: 0.8, blendDuration: 0), value: inputImage)
        .background(
            Group {
                if let result = identificationResult, let image = inputImage {
                    NavigationLink(
                        destination: ResultsView(result: result, image: image)
                            .onDisappear {
                                // Clear the result when coming back from ResultsView
                                identificationResult = nil
                                navigateToResults = false
                            },
                        isActive: $navigateToResults
                    ) {
                        EmptyView()
                    }
                }
            }
        )
        .onChange(of: navigateToResults) { isActive in
            if !isActive {
                // Also clear result when navigation becomes inactive
                identificationResult = nil
            }
        }
        .fullScreenCover(isPresented: $showingCamera) {
            ImagePicker(sourceType: .camera, selectedImage: $inputImage)
                .ignoresSafeArea()
        }
        .onChange(of: selectedItem, perform: loadImage)
        .onPreferenceChange(ViewFrameKey.self) { frame in
            placeholderFrame = frame
        }
        .sheet(isPresented: $showImageSourceSelector) {
            PhotoSourceSelectionView(
                onCameraSelected: {
                    showImageSourceSelector = false
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        showingCamera = true
                    }
                },
                onPhotoLibrarySelected: {
                    showImageSourceSelector = false
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        showPhotoPicker = true
                    }
                },
                onCancel: {
                    showImageSourceSelector = false
                }
            )
            .presentationDetents([.height(200)])
            .presentationDragIndicator(.visible)
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

// MARK: - View Components

private extension CameraGalleryView {
    var headerView: some View {
        VStack {
            Text("Rock Identifier")
                .font(.system(size: 32, weight: .bold, design: .serif))
                .foregroundColor(ThemeColors.primaryText)
            Text("Discover the world around you.")
                .font(.system(size: 16, weight: .medium, design: .serif))
                .foregroundColor(ThemeColors.secondaryText)
        }
    }

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
        .background(GeometryReader { geometry in
            Color.clear.preference(key: ViewFrameKey.self, value: geometry.frame(in: .global))
        })
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
            isIdentifying = false
            showPaywall = true
            return
        }
        
        print("Consuming token for user. Current tokens: \(user.tokens ?? 0), isPremium: \(user.isPremium ?? false)")
        userManager.consumeToken { result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    // Token consumed successfully, proceed with identification
                    print("Token consumption successful, proceeding with identification")
                    self.performRockIdentification(imageData: apiImageData, historyImageData: historyImageData)
                    
                case .failure(let error):
                    // Token consumption failed
                    print("Token consumption failed: \(error.localizedDescription)")
                    self.isIdentifying = false
                    let nsError = error as NSError
                    if nsError.domain == FunctionsErrorDomain,
                       let code = FunctionsErrorCode(rawValue: nsError.code),
                       code == .failedPrecondition {
                        // Out of tokens - show paywall directly without error message
                        print("Out of tokens, showing paywall")
                        self.showPaywall = true
                    } else {
                        // Other errors - show paywall instead of error alert
                        print("Token consumption error, showing paywall")
                        self.showPaywall = true
                    }
                }
            }
        }
    }
    
    private func performRockIdentification(imageData: Data, historyImageData: Data) {
        FirebaseAPIService.shared.identifyRock(imageData: imageData) { result in
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

// MARK: - Photo Source Selection Sheet

struct PhotoSourceSelectionView: View {
    let onCameraSelected: () -> Void
    let onPhotoLibrarySelected: () -> Void
    let onCancel: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            // Handle
            RoundedRectangle(cornerRadius: 2.5)
                .fill(Color.gray.opacity(0.3))
                .frame(width: 40, height: 5)
                .padding(.top, 8)
            
            // Title
            Text("Select a Photo")
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(ThemeColors.primaryText)
            
            // Buttons
            HStack(spacing: 40) {
                // Camera Button
                Button(action: onCameraSelected) {
                    VStack(spacing: 8) {
                        Image(systemName: "camera.fill")
                            .font(.system(size: 24))
                            .foregroundColor(.white)
                            .frame(width: 50, height: 50)
                            .background(ThemeColors.primaryAction)
                            .clipShape(Circle())
                        
                        Text("Camera")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(ThemeColors.primaryText)
                    }
                }
                
                // Photo Library Button
                Button(action: onPhotoLibrarySelected) {
                    VStack(spacing: 8) {
                        Image(systemName: "photo.fill")
                            .font(.system(size: 24))
                            .foregroundColor(.white)
                            .frame(width: 50, height: 50)
                            .background(ThemeColors.accent)
                            .clipShape(Circle())
                        
                        Text("Photo Library")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(ThemeColors.primaryText)
                    }
                }
            }
            
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .background(ThemeColors.background)
    }
}

// MARK: - Preview

struct CameraGalleryView_Previews: PreviewProvider {
    static var previews: some View {
        CameraGalleryView(showPaywall: .constant(false))
            .environmentObject(UserManager())
    }
}

