session=${1:-default}
case $session in
hdmi )
	# xset s off
	xset s off -dpms
	# xset s noblank
	SDL_VIDEODRIVER=x11 DISPLAY=:0 /home/picosh/pico-8/pico8_dyn -splore -draw_rect 32,0,258,224 &
	slstatus 2>&1 >/dev/null &
	shutdown-observer pico8_dyn &
	exec dwm
	;;
default )
	# xset s off
	xset s off -dpms
	# xset s noblank
	feh --bg-center /home/picosh/.wallpapers/pico-8.png
	SDL_VIDEODRIVER=x11 DISPLAY=:0 /home/picosh/pico-8/pico8_dyn -splore -draw_rect 32,0,258,224 &
	slstatus 2>&1 >/dev/null &
	shutdown-observer pico8_dyn &
	exec dwm
	;;
*) 
	exec $1;;
esac
