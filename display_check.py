#!/bin/python3

# NOT USING THIS SCRIPT ANY MORE

from Xlib import display
from Xlib.ext import randr
from sys import argv as a

# Make sure that params are correct
if len(a) != 3:
    print("ERROR: Invalid usage")
    print(f"Correct usage: {a[0]} OutputName HxV")
    exit()

output = a[1]
res_to_set = a[2]

# Get all the modes
def find_mode(id, modes):
    for mode in modes:
        if id == mode.id:
            return "{}x{}".format(mode.width, mode.height)

# Get info on all the screens
def get_display_info():
    d = display.Display(':0')
    screen_count = d.screen_count()
    default_screen = d.get_default_screen()
    result = []
    screen = 0
    info = d.screen(screen)
    window = info.root

    res = randr.get_screen_resources(window)
    for output in res.outputs:
        params = d.xrandr_get_output_info(output, res.config_timestamp)
        if not params.crtc:
            continue
        crtc = d.xrandr_get_crtc_info(params.crtc, res.config_timestamp)
        modes = set()
        for mode in params.modes:
            modes.add(find_mode(mode, res.modes))
        result.append({
            'name': params.name,
            'resolution': "{}x{}".format(crtc.width, crtc.height),
            'available_resolutions': list(modes)
        })

    return result

outputs = get_display_info()

monitor = ''

for dev in range(0, len(outputs)):
     if outputs[dev].get('name').lower() == a[1].lower():
         monitor = dev

if monitor == '':
    print("ERROR: Output is not active!")
else:
    dev_modes = outputs[monitor].get('available_resolutions')

    _set = False
        
    if res_to_set in dev_modes:
        _set = True

    print(_set)