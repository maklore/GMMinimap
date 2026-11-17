RESOLUTION.window_resize(RES.HD_1280x720);
RESOLUTION.camera_resize(RES.SD_640x360);
RESOLUTION.camera_target(id);
RESOLUTION.camera_mode(CameraMODE.SPRINGY, 0.1);

GMMInit(self, objWalls);
GMMSet.walk(3, 0.32, 0.16);

dir = 0;