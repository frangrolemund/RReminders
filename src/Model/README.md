# Overview
The model is implemented with [SwiftData](https://developer.apple.com/documentation/swiftdata) because I wanted to take it for a spin with a small app.

## Pros

- Minimal syntactic sugar on top of Swift class to create Core Data database models.
- Plugs into SwiftUI reasonably well.
- Supports custom types for persistence without transformable conversions used for Core Data. 


## Cons

- You can't automatically get singletons and have to play games to manage them.
- The @Model instances don't invoke property observers (eg. `didSet`) like an @Observable or ObservedObject class will.
- Arrays are surprisingly unordered, which changes the semantics of the fundamental collection type.
- The automatic behavior for maintaining relationships is not well-documented and it isn't clear what happens when it is mismanaged.  Can managed objects be leaked easily and how would you know?
- Debugging isn't much easier than Core Data and could be argued to be harder because of the additional 'magic' happening in code you can't step-into.  For example, there appears to be an incomplete Decoder implementation for custom types.  One of the model types (Reminder.RemindOn) is an enumeration with associated values of custom types that can be encoded/decoded ok with a standard JSONEncoder/JSONDecoder but either (a) hits a hard breakpoint in SwiftData when using Codable synthesis or (b) just doesn't get assigned with a custom Codable implementation.  This is obviously a weird corner case, but the error message (EXC_BREAKPOINT) is incredibly unhelpful and highlights the pitfalls of a leaky abstraction over existing language semantics.


# Conclusion
Not sure I'd use SwiftData for anything significant and am surprised that after two years the fundamental behavior feels unstable.  This use case is fairly simple and isn't even one of the more complicated ones described in the documentation.  It is probably not a bad option for a network cache, but it is tough to get precise behavior for non-trivial things. 
