
import SwiftUI

struct ListeningModeToggleStyle: ToggleStyle {
   @Environment(\.colorScheme) var colorScheme
    
    func makeBody(configuration: Configuration) -> some View {
        Rectangle()
            .foregroundColor(colorScheme == .dark ? .gray.opacity(0.3) : .white)
            .frame(width: width, height: height, alignment: .center)
            .cornerRadius(cornerRadius)
            .overlay(
                Circle()
                    .foregroundColor(.blue)
                    .offset(x: configuration.isOn ? -circleOffset : circleOffset, y: 0)
                    .padding(.all, circlePadding)
            )
            .overlay {
                ZStack {
                    Image(systemName: "headphones")
                        .foregroundColor(configuration.isOn ? .white : .primary)
                        .offset(x: headPhonesIconOffset)
                        .padding(.all, circlePadding)
                    Image(systemName: "text.alignleft")
                        .foregroundColor(configuration.isOn ? .primary : .white)
                        .offset(x: textIconOffset)
                        .padding(.all, circlePadding)
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .stroke(.secondary.opacity(0.2))
                }
            }
            .animation(.linear(duration: 0.1), value: configuration.isOn)
            .onTapGesture { configuration.isOn.toggle() }
    }

}

// MARK: - LayoutCalculations

extension ListeningModeToggleStyle {

    var width: CGFloat { 101 }
    var height: CGFloat { 51 }
    
    var cornerRadius: CGFloat { 40 }
    
    var circlePadding: CGFloat { 3 }
    var circleOffset: CGFloat { 25 }
    var headPhonesIconOffset: CGFloat { -circleOffset }
    var textIconOffset: CGFloat { circleOffset }
    
}
