@tool
extends RichTextLabel
class_name scaleableText

@export var fontType : String = "normal_font"
@export var extraSpace : float = 1

func _on_resized():
	resizeFont()

func resizeFont():
	var lengthOfFont = getFontLength(get_theme_font_size(fontType+"_size"),"x")
	var lengthOfWindow = (size.x)*scale.x * extraSpace
	var lengthScaleAmount = lengthOfWindow/lengthOfFont
	
	var heightOfFont = getFontLength(get_theme_font_size(fontType+"_size"),"y")
	var heightOfWindow = (size.y)*scale.y * extraSpace
	var heightScaleAmount = heightOfWindow/heightOfFont
	
	var smallerMultiplier = min(heightScaleAmount,lengthScaleAmount)
	add_theme_font_size_override(fontType+"_size",get_theme_font_size(fontType+"_size") * smallerMultiplier)
	
	lengthOfFont = getFontLength(get_theme_font_size(fontType+"_size"),"x")
	lengthOfWindow = (size.x)*scale.x - extraSpace
	heightOfFont = getFontLength(get_theme_font_size(fontType+"_size"),"y")
	heightOfWindow = (size.y)*scale.y - extraSpace
	if lengthOfFont > lengthOfWindow or heightOfFont > heightOfWindow:
		#print("length: ",lengthOfWindow - lengthOfFont, "height: ",heightOfWindow - heightOfFont)
		add_theme_font_size_override(fontType+"_size",get_theme_font_size(fontType+"_size")-20)
	#print("length: ",lengthOfWindow - lengthOfFont, "height: ",heightOfWindow - heightOfFont)
	

func getFontLength(fontSize, axis : String):
	if axis == "x":
		return get_theme_font(fontType).get_string_size(text, horizontal_alignment,-1,fontSize).x
	else:
		return get_theme_font(fontType).get_string_size(text, horizontal_alignment,-1,get_theme_font_size(fontType+"_size")).y
