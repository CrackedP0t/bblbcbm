extends EditorInspectorPlugin

func can_handle(object):
	# Here you can specify which object types (classes) should be handled by
	# this plugin. For example if the plugin is specific to your player
	# class defined with `class_name MyPlayer`, you can do:
	# `return object is MyPlayer`
	# In this example we'll support all objects, so:
	return object is CustomPlane

func parse_property(object, type, path, hint, hint_text, usage):
	# We will handle properties of type integer.
	false
