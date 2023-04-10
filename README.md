# Summarly

Summarly is a powerful iOS app built with Swift and SwiftUI that allows you to load web articles or PDFs, analyze the content, prepare summaries, and engage in Q/A sessions with the content. The app leverages Pinecone, a vector database, for its memory feature to provide a seamless user experience.

## Features

- Load web articles and PDFs.
- Content analysis and summarization.
- Interactive Q/A sessions with the content.
- Utilizes Pinecone for memory features.
- Built using Swift and SwiftUI for iOS.

## Installation

To get started with Summarly, clone this repository and open the project in Xcode. Ensure that you have the latest version of Xcode installed to avoid compatibility issues.

```bash
git clone https://github.com/username/summarly.git
```

Open Summarly.xcodeproj in Xcode and run the app on the iOS simulator or a physical device.

Before building the project, make sure to:

- Add your OpenAI API key to the info.plist file.
- Update the Pinecone URL to the index and API key in the Defaults.swift file.

##Usage

- Launch the Summarly app on your iOS device.
- Choose to load a web article or a PDF file.
- The app will analyze the content and generate a summary for you.
- Engage in a Q/A session by asking questions related to the article or PDF.
- Explore the Pinecone-powered memory feature for an enhanced experience.

##Dependencies

- Pinecone: A vector database used for the memory feature.
- Swift: The programming language used for the project.
- SwiftUI: The user interface toolkit used to build the app.
- SwiftSoup: A library for loading and parsing web content.

##Contributing

Contributions are welcome!

##License

Summarly is available under the MIT license. See the LICENSE file for more details.
