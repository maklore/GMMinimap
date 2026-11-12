if keyboard_check(vk_shift) {
	if mouse_wheel_up() {
		opacity = clamp(opacity + opacity_speed, 0.125, 1);	
	}
	if mouse_wheel_down() {
		opacity = clamp(opacity - opacity_speed, 0.125, 1);
	}
} else {
	if mouse_wheel_up() {
		zoom = clamp(zoom + zoom_speed, 0.125, 2);	
	}
	if mouse_wheel_down() {
		zoom = clamp(zoom - zoom_speed, 0.125, 2);
	}
}