# Identifier App Boilerplate

This is a generic boilerplate for creating SwiftUI-based identifier apps. It provides a clean, reusable foundation for building apps that identify objects from images using the Gemini API.

## How to Use This Boilerplate

1.  **Clone the Repository**: Start by cloning this repository to your local machine.

2.  **Rename the Project**: Rename the `.xcodeproj` file and the main project folder from `IdentifierBoilerplate` to your new app's name (e.g., `RockIdentifier`).

3.  **Update Project Settings**: Open the `project.pbxproj` file in a text editor and replace all instances of `IdentifierBoilerplate` with your new project name. This is a critical step to ensure the project builds correctly.

4.  **Define Your Prompt**: The core of your new app's logic is the prompt you send to the Gemini API. In your main content view (or wherever you trigger the identification), you'll need to define a prompt that tells the API what to identify and what information to return.

    For example, for a rock identifier, your prompt might look like this:

    ```swift
    let prompt = """
    Identify the rock in this image. Provide its common name and a brief description.
    Format the response as a single, clean JSON object with the following keys: 'name' (string), 'description' (string), and 'details' (a dictionary of key-value pairs).
    The 'details' dictionary should include the following keys: 'Type', 'Hardness', 'Color', and 'Luster'.
    If the image does not contain a rock, the 'name' field should be 'Not a rock' and all other fields should be empty.
    """
    ```

5.  **Call the API**: With your prompt defined, you can call the `identifyItem` method on the `GeminiAPIService` singleton:

    ```swift
    GeminiAPIService.shared.identifyItem(imageData: imageData, prompt: prompt) { result in
        // Handle the result
    }
    ```

6.  **Customize the UI**: The boilerplate provides generic views for analyzing and displaying results. You can customize these views to match the look and feel of your new app. The `ResultsView` is designed to dynamically display the `details` dictionary, so it will automatically adapt to the data you request in your prompt.

7.  **Build and Run**: That's it! You're now ready to build and run your new identifier app.

## Project Structure

*   `IdentifierBoilerplate/`
    *   `Generic/`: Contains all the reusable, generic components of the app, such as the `GeminiAPIService`, `HistoryManager`, and the main views.
    *   `BugSpecific/`: This directory is now empty, but you can use it to house any code that is specific to your new app.
    *   `Assets.xcassets/`: Contains all the app's assets, such as icons and images.
    *   `IdentifierBoilerplateApp.swift`: The main entry point for the app.

## Dependencies

This boilerplate relies on the following dependencies:

*   **GoogleGenerativeAI**: For interacting with the Gemini API.
*   **RevenueCat**: For managing in-app purchases.
*   **Firebase**: For backend services like remote config and authentication.

Ensure you have these dependencies properly configured in your project.
