//
//  MyForm.swift
//  Flashcards App
//
//  Created by Maksim Gaiduk on 27/07/2023.
//

import SwiftUI

@resultBuilder
struct MyGroupBuilder {
    static func buildBlock(_ components: any View...) -> [AnyView] {
        components.map {component in
            AnyView(component)
        }
    }
}

// Transparent node, equivalent to just listing elements
struct MyGroup {
    var content: [AnyView]
    init(@MyGroupBuilder content: () -> [AnyView]) {
        self.content = content()
    }
}

@resultBuilder
struct MySectionBuilder {
    static func buildPartialBlock<C: View>(first: C) -> [AnyView] {
        return [AnyView(first)]
    }
    
    static func buildPartialBlock(accumulated: [AnyView], next: MyGroup) -> [AnyView] {
        var new = accumulated
        for value in next.content {
            new.append(value)
        }
        return new
    }
    
    static func buildPartialBlock<C1>(accumulated: [AnyView], next: C1) -> [AnyView] where C1: View {
        var new = accumulated
        new.append(AnyView(next))
        return new
    }
}

class MySection {
    var content: [AnyView]
    var header: AnyView?
    var zindex = 0.0
    init(@MySectionBuilder content: () -> [AnyView]) {
        self.content = content()
    }
    init<H: View>(@MySectionBuilder content: () -> [AnyView], @ViewBuilder header: () -> H) {
        self.content = content()
        self.header = AnyView(header())
    }
    init(content: [AnyView]) {
        self.content = content
    }
    func zIndex(_ value: Double) -> Self {
        self.zindex = value
        return self
    }
}

class MyFormAccumulator {
    var sections: [MySection] = []
    var isLastSectionOpen = false

    func AddElement(element: MySection) {
        isLastSectionOpen = false
        sections.append(element)
    }

    func AddElement(element: MyGroup) {
        if !isLastSectionOpen {
            sections.append(MySection(content: []))
        }
        let section = sections.last!
        isLastSectionOpen = true
        section.content.append(contentsOf: element.content)
    }

    func AddElement<Content: View>(element: Content) {
        if !isLastSectionOpen {
            sections.append(MySection(content: []))
        }
        let section = sections.last!
        isLastSectionOpen = true
        section.content.append(AnyView(element))
    }
}

@resultBuilder
struct MyFormBuilder {
    static func buildPartialBlock(first: MyGroup) -> MyFormAccumulator {
        let accumulated = MyFormAccumulator()
        accumulated.AddElement(element: first)
        return accumulated
    }

    static func buildPartialBlock(first: MySection) -> MyFormAccumulator {
        let accumulated = MyFormAccumulator()
        accumulated.AddElement(element: first)
        return accumulated
    }
    
    static func buildPartialBlock<T: View>(first: T) -> MyFormAccumulator {
        let accumulated = MyFormAccumulator()
        accumulated.AddElement(element: first)
        return accumulated
    }
    
    static func buildPartialBlock(accumulated: MyFormAccumulator, next: MySection) -> MyFormAccumulator {
        accumulated.AddElement(element: next)
        return accumulated
    }
    
    static func buildPartialBlock(accumulated: MyFormAccumulator, next: MyGroup) -> MyFormAccumulator {
        accumulated.AddElement(element: next)
        return accumulated
    }
    
    static func buildPartialBlock<T: View>(accumulated: MyFormAccumulator, next: T) -> MyFormAccumulator {
        accumulated.AddElement(element: next)
        return accumulated
    }
}

private let grey = Color(red: 0.95, green: 0.95, blue: 0.96)

struct MyForm: View {
    var content: MyFormAccumulator
    init(@MyFormBuilder content: () -> MyFormAccumulator) {
        self.content = content()
    }
    var body: some View {
        VStack {
            ForEach(0..<content.sections.count, id: \.self) {idx in
                let section = content.sections[idx]
                VStack(alignment: .leading, spacing: 0) {
                    if let header = section.header {
                        header
                            .textCase(.uppercase)
                            .padding(10)
                            .foregroundColor(Color.gray)
                    }
                    VStack(alignment: .leading, spacing: 0) {
                        ForEach(0..<section.content.count, id: \.self) {idx2 in
                            section.content[idx2]
                                .padding(10)
                            if idx2 != section.content.count - 1 {
                                Divider()
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.white.cornerRadius(10))
                }.zIndex(section.zindex)
            }
            .padding(20)
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .background(grey)
    }
//    var body: some View {
//        VStack {
//            ForEach(0..<content.sections.count, id: \.self) {idx in
//                let section = content.sections[idx]
//                VStack(alignment: .leading, spacing: 0) {
//                    if let header = section.header {
//                        header
//                            .textCase(.uppercase)
//                            .padding(10)
//                            .foregroundColor(Color.gray)
//                    }
//                    VStack(alignment: .leading, spacing: 0) {
//                        section.content[0]
//                    }
//                    .frame(maxWidth: .infinity, alignment: .leading)
//                        .background(Color.white.cornerRadius(10))
////
//                }
//            }.padding(20)
//            Spacer()
//        }
//        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
//        .background(grey)
//    }
}

struct MyForm_Previews: PreviewProvider {
    static var previews: some View {
        MyForm {
            MySection {
                Text("SectionText1")
                    .zIndex(1)
                    .overlay {
                        Text("OverlayContent1\nOverlayContent2\nOverlayContent3\nOverlayContent4\nOverlayContent5\nOverlayContent6\nOverlayContent7\nOverlayContent8\nOverlayContent9\nOverlayContent10")
                            .frame(height: 500)
                            .background(Color.blue)
                            .offset(x: 60, y: 220)
                    }
//                Text("SectionText2")
            } header:  {
                Text("Section header")
            }.zIndex(1)
            Text("Text ouside of section")
            
//            MyGroup {
//                Text("Text in group1")
//                Text("Text in group2")
//            }
//            MySection {
//                Text("new section")
//                    .overlay {
//                        Text("OverlayContent1\nOverlayContent2\nOverlayContent3")
//                            .offset(x: 60, y: 50)
//                            .frame(height: 200)
//                    }
//            }
//            Text("Text ouside of section again")
        }
    }
}
