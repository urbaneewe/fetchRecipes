# Steps to Run the App
The code is organized into packages. There is no need for any additional setup so you can just CMD + R and run the app!
Also in the `RecipesView` you can find Previews for all the different states the app has.

# Focus Areas: What specific areas of the project did you prioritize? Why did you choose to focus on these areas?
The RecipesViewStore class is a key component that manages the state and actions for the recipes view. 
It implements the ViewStore protocol, which separates the view-specific logic from the rendering. 
View Store is an architecture pattern and a protocol used in SwiftUI development inspired by The Composable Architecture (TCA). 
A view store is an ObservableObject that allows us to separate view-specific logic and the rendering of a corresponding view in a way that is repeatable, prescriptive, flexible, and testable by default.

What makes this area complex and worth focusing on:

- State Management: The `viewState` property on the `ViewStore` protocol is the single source of truth for data that the corresponding View uses. It should always be declared as a `@Published` property. Similar to a view model, the properties on `ViewState` should not require the corresponding View to perform any additional transformation logic or formatting for display (e.g. text, numbers, and dates).
- Asynchronous Operations: Actions can be performed by the corresponding View using the `send(_ action:)` API. Action is typically modeled as an `enum`. When an action is performed, it typically has an effect on the view state. For example, `.refresh` might be an action that a View triggers on a view store, resulting in it re-fetching data and updating its corresponding viewState.
- Error Handling: The store incorporates error handling within the state management, allowing for graceful degradation of the UI when errors occur.
- Dependency Injection: The `RecipeService` is injected into the `RecipesViewStore`, promoting loose coupling and making the code more testable and flexible.
- MainActor Usage: The `@MainActor` attribute ensures that UI updates occur on the main thread, preventing potential race conditions and UI inconsistencies.

# Time Spent: Approximately how long did you spend working on this project? How did you allocate your time?
Around ~5-6 hours, the main focus was on the architecture and the data flow, namely the implemetations of `RecipesViewStore` and `RecipeService`

# Trade-offs and Decisions: Did you make any significant trade-offs in your approach?
A significant trade-off in this project was the decision not to use TCA. Instead, a custom, lightweight state management solution was implemented. This choice was made primarily for simplicity, given the app's small requirements.
The custom `ViewStore` protocol and its implementation provide a streamlined approach to state management.

While this trade-off means foregoing some benefits of TCA, it aligns well with the project's scope and allows for a clear demonstration of architectural design skills. This approach effectively balances simplicity with functionality for an app with limited requirements.

# Weakest Part of the Project: What do you think is the weakest part of your project?
The weakest part of this project is likely the error handling and user feedback mechanism, particularly in the `RecipesView` and `RecipesViewStore`. While there is a basic error state, the implementation could be more robust and user-friendly.
To improve this area, we could:

- Implement more detailed error types and user-friendly error messages.
- Add a proper logging system for better error tracking and debugging.
- Implement more sophisticated retry logic for network requests.
- Provide more actionable feedback to users when errors occur.

# External Code and Dependencies: Did you use any external code, libraries, or dependencies?
I've used some of the existing implementations from my past experiences such as the `BackgroundColorManager` along with the `findAverageColor` function.

The implementation details around those are quite interesting and I'd be more than happy to talk more about it :)

# Additional Information: Is there anything else we should know? Feel free to share any insights or constraints you encountered.
There are some interesting pieces of code around the UI (that I mentioned in the section above) but also more around the `CachingAsyncImage` that I think you might find interesting.

