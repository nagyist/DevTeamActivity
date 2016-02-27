//
//  main.swift
//  Canvas
//
//  Created by nst on 04/01/16.
//  Copyright © 2016 Nicolas Seriot. All rights reserved.
//

import Cocoa

var Crayons = NSColorList(named: "Crayons")!

extension NSColorList {
    subscript (key:String) -> NSColor {
        return self.colorWithKey(key)!
    }
}

infix operator * { associativity right precedence 155 }

func *(left:CGFloat, right:Int) -> CGFloat
{ return left * CGFloat(right) }

func *(left:Int, right:CGFloat) -> CGFloat
{ return CGFloat(left) * right }

func *(left:CGFloat, right:Double) -> CGFloat
{ return left * CGFloat(right) }

func *(left:Double, right:CGFloat) -> CGFloat
{ return CGFloat(left) * right }

infix operator + { associativity right precedence 145 }

func +(left:CGFloat, right:Int) -> CGFloat
{ return left + CGFloat(right) }

func +(left:Int, right:CGFloat) -> CGFloat
{ return CGFloat(left) + right }

func +(left:CGFloat, right:Double) -> CGFloat
{ return left + CGFloat(right) }

func +(left:Double, right:CGFloat) -> CGFloat
{ return CGFloat(left) + right }

infix operator - { associativity right precedence 145 }

func -(left:CGFloat, right:Int) -> CGFloat
{ return left - CGFloat(right) }

func -(left:Int, right:CGFloat) -> CGFloat
{ return CGFloat(left) - right }

func -(left:CGFloat, right:Double) -> CGFloat
{ return left - CGFloat(right) }

func -(left:Double, right:CGFloat) -> CGFloat
{ return CGFloat(left) - right }

//

func P(x:CGFloat, _ y: CGFloat) -> NSPoint {
    return NSMakePoint(x, y)
}

func R(x:CGFloat, _ y:CGFloat, _ w:CGFloat, _ h:CGFloat) -> NSRect {
    return NSMakeRect(x, y, w, h)
}

struct Bitmap {
    
    let bitmapImageRep : NSBitmapImageRep
    let context : NSGraphicsContext
    
    var cgContext : CGContext {
        return context.CGContext
    }
    
    var width : CGFloat {
        return bitmapImageRep.size.width
    }
    
    var height : CGFloat {
        return bitmapImageRep.size.height
    }
    
    func setAllowsAntialiasing(antialiasing : Bool) {
        CGContextSetAllowsAntialiasing(cgContext, antialiasing)
    }
    
    init(_ width:Int, _ height:Int, backgroundColor:NSColor? = nil) {
        
        self.bitmapImageRep = NSBitmapImageRep(bitmapDataPlanes:nil,
            pixelsWide:width,
            pixelsHigh:height,
            bitsPerSample:8,
            samplesPerPixel:4,
            hasAlpha:true,
            isPlanar:false,
            colorSpaceName:NSDeviceRGBColorSpace,
            bytesPerRow:0,
            bitsPerPixel:0)!
        
        self.context = NSGraphicsContext(bitmapImageRep: bitmapImageRep)!
        
        NSGraphicsContext.setCurrentContext(context)
        
        // setAllowsAntialiasing(true)
        
        if let color = backgroundColor {
            let rect = NSMakeRect(0, 0, CGFloat(width), CGFloat(height))
            rectangle(rect, strokeColor: color, fillColor: color)
        }
        
        // makes coordinates start upper left
        CGContextTranslateCTM(cgContext, 0, CGFloat(height))
        CGContextScaleCTM(cgContext, 1.0, -1.0)
    }
    
    func point(p:NSPoint, color:NSColor? = nil) {
        context.saveGraphicsState()
        
        // align to the pixel grid
        CGContextTranslateCTM(cgContext, -0.5, -0.5)
        
        if let existingColor = color {
            CGContextSetStrokeColorWithColor(cgContext, existingColor.CGColor);
        }
        CGContextSetLineCap(cgContext, .Square)
        CGContextMoveToPoint(cgContext, p.x, p.y)
        CGContextAddLineToPoint(cgContext, p.x, p.y)
        CGContextStrokePath(cgContext)
        
        context.restoreGraphicsState()
    }
    
    func line(p1:NSPoint, _ p2:NSPoint, color:NSColor? = NSColor.blackColor()) {
        context.saveGraphicsState()
        
        // align to the pixel grid
        CGContextTranslateCTM(cgContext, 0.5, 0.5)
        
        if let existingColor = color {
            CGContextSetStrokeColorWithColor(cgContext, existingColor.CGColor);
        }
        
        CGContextSetLineCap(cgContext, .Square)
        CGContextMoveToPoint(cgContext, p1.x, p1.y)
        CGContextAddLineToPoint(cgContext, p2.x, p2.y)
        CGContextStrokePath(cgContext)
        
        context.restoreGraphicsState()
    }
    
    func lineVertical(p1:NSPoint, height:CGFloat, color:NSColor? = nil) {
        let p2 = P(p1.x, p1.y + height)
        self.line(p1, p2, color:color)
    }
    
    func lineHorizontal(p1:NSPoint, width:CGFloat, color:NSColor? = nil) {
        let p2 = P(p1.x + width, p1.y)
        self.line(p1, p2, color:color)
    }
    
    func line(p1:NSPoint, deltaX:CGFloat, deltaY:CGFloat, color:NSColor? = nil) {
        let p2 = P(p1.x + deltaX, p1.y + deltaY)
        self.line(p1, p2)
    }
    
    func rectangle(t:(x:CGFloat, y:CGFloat, w:CGFloat, h:CGFloat)) {
        return rectangle(NSMakeRect(t.x, t.y, t.w, t.h))
    }
    
    func rectangle(rect:NSRect) {
        rectangle(rect, fillColor: nil)
    }
    
    func rectangle(rect:NSRect, strokeColor:NSColor? = NSColor.blackColor(), fillColor:NSColor? = nil) {
        
        context.saveGraphicsState()
        
        // align to the pixel grid
        CGContextTranslateCTM(cgContext, 0.5, 0.5)
        
        if let existingFillColor = fillColor {
            existingFillColor.setFill()
            NSBezierPath.fillRect(rect)
        }
        
        if let existingStrokeColor = strokeColor {
            existingStrokeColor.setStroke()
            NSBezierPath.strokeRect(rect)
        }
        
        context.restoreGraphicsState()
    }
    
    private func degreesToRadians(x:CGFloat) -> CGFloat {
        return (M_PI * x / 180.0)
    }
    
    func save(path:String) -> Bool {
        guard let data = bitmapImageRep.representationUsingType(NSBitmapImageFileType.NSPNGFileType, properties: [:]) else {
            print("\(__FILE__) \(__FUNCTION__) cannot get PNG data from bitmap")
            return false
        }
        return data.writeToFile(path, atomically: false)
    }
    
    private func textWidth(text:NSString, font:NSFont) -> CGFloat {
        let maxSize : CGSize = CGSizeMake(CGFloat.max, font.pointSize)
        let textRect : CGRect = text.boundingRectWithSize(
            maxSize,
            options: NSStringDrawingOptions.UsesLineFragmentOrigin,
            attributes: [NSFontAttributeName: font],
            context: nil)
        return textRect.size.width
    }
    
    func image(fromPath path:String, _ p:NSPoint) {
        
        guard let data = NSData(contentsOfFile:path) else {
            print("\(__FILE__) \(__FUNCTION__) cannot read data at \(path)");
            return
        }
        
        guard let imgRep = NSBitmapImageRep(data: data) else {
            print("\(__FILE__) \(__FUNCTION__) cannot create bitmap image rep from data at \(path)");
            return
        }
        
        context.saveGraphicsState()
        
        CGContextScaleCTM(cgContext, 1.0, -1.0)
        CGContextTranslateCTM(cgContext, 0.0, -2.0 * p.y - imgRep.pixelsHigh)
        
        let rect = NSMakeRect(p.x, p.y, CGFloat(imgRep.pixelsWide), CGFloat(imgRep.pixelsHigh))
        
        imgRep.drawInRect(rect)
        
        context.restoreGraphicsState()
    }
    
    func text(text:String, _ p:NSPoint, rotationRadians:CGFloat?, font : NSFont = NSFont(name: "Monaco", size: 10)!, color : NSColor = NSColor.blackColor()) {
        
        let attr = [
            NSFontAttributeName:font,
            NSForegroundColorAttributeName:color
        ]
        
        context.saveGraphicsState()
        
        if let radians = rotationRadians {
            CGContextTranslateCTM(cgContext, p.x, p.y);
            CGContextRotateCTM(cgContext, radians)
            CGContextTranslateCTM(cgContext, -p.x, -p.y);
        }
        
        CGContextScaleCTM(cgContext, 1.0, -1.0)
        CGContextTranslateCTM(cgContext, 0.0, -2.0 * p.y - font.pointSize)
        
        CGContextSetAllowsAntialiasing(cgContext, false)
        
        text.drawAtPoint(p, withAttributes: attr)
        
        CGContextSetAllowsAntialiasing(cgContext, true)
        
        context.restoreGraphicsState()
    }
    
    func text(text:String, _ p:NSPoint, rotationDegrees degrees:CGFloat = 0.0, font : NSFont = NSFont(name: "Monaco", size: 10)!, color : NSColor = NSColor.blackColor()) {
        self.text(text, p, rotationRadians: degreesToRadians(degrees), font: font, color: color)
    }
}
